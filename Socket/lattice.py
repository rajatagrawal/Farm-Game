# Copyright (c) 2007 Carnegie Mellon University
#
# You may copy and modify this freely under the same terms as
# Sphinx-III

"""
Word lattices for speech recognition.

Includes routines for loading lattices in Sphinx3 and HTK format,
searching them, and calculating word posterior probabilities.
"""

__author__ = "David Huggins-Daines <dhuggins@cs.cmu.edu>"
__version__ = "$Revision: 7544 $"

import gzip
import re
import math
import os
try:
    import numpy
except:
    pass

LOGZERO = -100000

def logadd(x,y):
    """
    For M{x=log(a)} and M{y=log(b)}, return M{z=log(a+b)}.

    @param x: M{log(a)}
    @type x: float
    @param y: M{log(b)}
    @type y: float
    @return: M{log(a+b)}
    @rtype: float
    """
    if x < y:
        return logadd(y,x)
    if y == LOGZERO:
        return x
    else:
        return x + math.log(1 + math.exp(y-x))

def is_filler(sym):
    """
    Returns true if C{sym} is a filler word.
    @param sym: Word string to test
    @type sym: string
    @return: True if C{sym} is a filler word (but not <s> or </s>)
    @rtype: boolean
    """
    if sym == '<s>' or sym == '</s>': return False
    return ((sym[0] == '<' and sym[-1] == '>') or
            (sym[0] == '+' and sym[-1] == '+'))

def baseword(sym):
    """
    Returns base word (no pronunciation variant) for sym.
    """
    paren = sym.rfind('(')
    if paren != -1:
        return sym[0:paren]
    else:
        return sym


def node_lmscore(v, u, lm, silpen=0, fillpen=0):
    if lm == None:
        return 0
    elif v.sym == '<sil>':
        return silpen, 1
    elif is_filler(v.sym):
        return fillpen, 1
    else:
        syms = [baseword(v.sym)]
        # Trace back to find previous non-filler word.
        hist = u
        while hist and is_filler(hist.sym):
            hist = hist.prev
        if hist:
            syms.append(baseword(hist.sym))
        # And the one before that too.
        hist = hist.prev
        while hist and is_filler(hist.sym):
            hist = hist.prev
        if hist:
            syms.append(baseword(hist.sym))
        return lm.score(*syms)

class Dag(object):
    """
    Directed acyclic graph representation of a phone/word lattice.
    """
    class Node(object):
        """
        Node in a DAG representation of a phone/word lattice.

        @ivar sym: Word corresponding to this node.  All arcs out of
                   this node represent hypothesized instances of this
                   word starting at frame C{entry}.
        @type sym: string
        @ivar id: Numeric ID used to index this in external arrays
        @type fan: int
        @ivar entry: Entry frame for this node.
        @type entry: int
        @ivar exits: List of arcs out of this node.
        @type exits: list of Dag.Link
        @ivar entries: List of arcs into this node
        @type entries: list of Dag.Link
        @ivar score: Viterbi (or other) score for this node, used in
                     bestpath calculation.
        @type score: float
        @ivar prev: Backtrace pointer for this node, used in bestpath
                    calculation.
        @type prev: object
        """
        __slots__ = 'sym', 'entry', 'exits', 'entries', 'score', 'prev', 'fan', 'id'
        def __init__(self, sym, entry, id=-1):
            self.sym = sym
            self.id = id
            self.fan = 0
            self.entry = entry
            self.exits = []
            self.entries = []
            self.score = LOGZERO
            self.prev = None

    class Link(object):
        """
        Link in DAG representation of a phone/word lattice.

        @ivar src: Start node for this link.
        @type src: Dag.Node
        @ivar dest: End node for this link.
        @type dst: Dag.Node
        @ivar ascr: Acoustic score for this link.
        @type ascr: float
        @ivar lscr: Best language model score for this link
        @type lscr: float
        @type lback: Best language model backoff mode for this link
        @type lback: int
        @ivar pscr: Dijkstra path score for this link
        @type pscr: float
        @ivar alpha: Joint log-probability of all paths ending in this link
        @type alpha: float
        @ivar beta: Conditional log-probability of all paths following this link
        @type beta: float
        @ivar post: Posterior log-probability of this link
        @type post: float
        @ivar prev: Previous link in best path
        @type prev: Dag.Link
        """
        __slots__ = ('src', 'dest', 'ascr', 'lscr', 'pscr', 'alpha', 'beta',
                     'post', 'lback', 'prev')
        def __init__(self, src, dest, ascr,
                     lscr=LOGZERO, pscr=LOGZERO,
                     alpha=LOGZERO, beta=LOGZERO,
                     post=LOGZERO, lback=0):
            self.src = src
            self.dest = dest
            self.ascr = ascr
            self.lscr = lscr
            self.pscr = pscr
            self.alpha = alpha
            self.beta = beta
            self.post = post
            self.lback = lback
            self.prev = None

    def __init__(self, sphinx_file=None, htk_file=None, frate=100):
        """
        Construct a DAG, optionally loading contents from a file.

        @param frate: Number of frames per second.  This is important
                      when loading HTK word graphs since times in them
                      are specified in decimal.  The default is
                      probably okay.
        @type frate: int
        @param sphinx_file: Sphinx-III format word lattice file to
                            load (optionally).
        @type sphinx_file: string
        @param htk_file: HTK SLF format word lattice file to
                         load (optionally).
        @type htk_file: string
        """
        self.frate = frate
        if sphinx_file != None:
            self.sphinx2dag(sphinx_file)
        elif htk_file != None:
            self.htk2dag(htk_file)

    fieldre = re.compile(r'(\S+)=(?:"((?:[^\\"]+|\\.)*)"|(\S+))')
    def htk2dag(self, htkfile):
        """Read an HTK-format lattice file to populate a DAG."""
        fh = gzip.open(htkfile)
        self.header = {}
        self.n_frames = 0
        state='header'
        # Read everything
        for spam in fh:
            if spam.startswith('#'):
                continue
            fields = dict(map(lambda (x,y,z): (x, y or z), self.fieldre.findall(spam.rstrip())))
            # Number of nodes and links
            if 'N' in fields:
                nnodes = int(fields['N'])
                self.nodes = [None] * nnodes
                nlinks = int(fields['L'])
                self.links = [None] * nlinks
                state = 'items'
            if state == 'header':
                self.header.update(fields)
            else:
                # This is a node
                if 'I' in fields:
                    frame = int(float(fields['t']) * self.frate)
                    node = self.Node(fields['W'], frame, int(fields['I']))
                    self.nodes[int(fields['I'])] = node
                    if frame > self.n_frames:
                        self.n_frames = frame
                # This is a link
                elif 'J' in fields:
                    # Link up existing nodes
                    fromnode = int(fields['S'])
                    tonode = int(fields['E'])
                    ascr = float(fields['a'])
                    lscr = float(fields['n'])
                    self.nodes[int(fromnode)].exits.append(
                        self.Link(fromnode, tonode, ascr, lscr))
        # FIXME: Not sure if the first and last nodes are always the start and end?
        self.start = self.nodes[0]
        self.end = self.nodes[-1]
        # Snap links to nodes to point to the objects themselves
        self.snap_links()
        # Sort nodes to be in time order
        self.sort_nodes_forward()

    def snap_links(self):
        for n in self.nodes:
            for x in n.exits:
                x.src = self.nodes[int(x.src)]
                x.dest = self.nodes[int(x.dest)]
                x.dest.entries.append(x)

    def sort_nodes_forward(self):
        # Sort nodes by starting point
        self.nodes.sort(lambda x,y: cmp(x.entry, y.entry))
        # Sort edges by ending point
        for n in self.nodes:
            n.exits.sort(lambda x,y: cmp(x.dest.entry, y.dest.entry))

    headre = re.compile(r'# (-\S+) (\S+)')
    def sphinx2dag(self, s3file):
        """Read a Sphinx-III format lattice file to populate a DAG."""
        if s3file.endswith('.gz'): # DUMB
            fh = gzip.open(s3file)
        else:
            fh = open(s3file)
        self.header = {}
        self.getcwd = None
        state = 'header'
        logbase = math.log(1.0003)
        for spam in fh:
            spam = spam.rstrip()
            m = self.headre.match(spam)
            if m:
                arg, val = m.groups()
                self.header[arg] = val
                if arg == '-logbase':
                    logbase = math.log(float(val))
            if spam.startswith('# getcwd:'):
                self.getcwd = spam[len('# getcwd:'):].strip()
            if spam.startswith('#'):
                continue
            else:
                fields = spam.split()
                if fields[0] == 'Frames':
                    self.n_frames = int(fields[1])
                elif fields[0] == 'Nodes':
                    state='nodes'
                    nnodes = int(fields[1])
                    self.nodes = [None] * nnodes
                elif fields[0] == 'Initial':
                    state = 'crud'
                    self.start = self.nodes[int(fields[1])]
                elif fields[0] == 'Final':
                    self.end = self.nodes[int(fields[1])]
                elif fields[0] == 'Edges':
                    state='edges'
                elif fields[0] == 'End':
                    state='done'
                else:
                    if state == 'nodes':
                        nodeid, word, sf, fef, lef = fields
                        node = self.Node(word, int(sf), int(nodeid))
                        self.nodes[int(nodeid)] = node
                    elif state == 'edges':
                        fromnode, tonode, ascr = fields
                        ascr = float(ascr) * logbase
                        self.nodes[int(fromnode)].exits.append(
                            self.Link(fromnode, tonode, ascr))
        if self.getcwd == None:
            self.getcwd = os.getcwd()
        # Snap links to nodes to point to the objects themselves
        self.snap_links()
        # Sort nodes to be in time order
        self.sort_nodes_forward()

    def dag2sphinx(self, outfile, logbase=1.0003):
        if outfile.endswith('.gz'): # DUMB
            fh = gzip.open(outfile, "w")
        else:
            fh = open(outfile, "w")
        fh.write("# getcwd: %s\n" % self.getcwd)
        fh.write("# -logbase %e\n" % logbase)
        for arg, val in self.header.iteritems():
            if arg != '-logbase':
                fh.write("# %s %s\n" % (arg,val))
        fh.write("#\n")
        fh.write("Frames %d\n" % self.n_frames)
        fh.write("#\n")
        fh.write("Nodes %d (NODEID WORD STARTFRAME FIRST-ENDFRAME LAST-ENDFRAME)\n"
                 % self.n_nodes())
        links = []
        idmap = {}
        for i,n in enumerate(self.nodes):
            fef = self.n_frames
            lef = 0
            for x in n.exits:
                fr = x.dest.entry - 1
                if fr > lef: lef = fr
                if fr < fef: fef = fr
            if fef == self.n_frames: lef = fef = self.n_frames
            idmap[n] = i
            fh.write("%d %s %d %d %d\n" % (i, n.sym, n.entry, fef, lef))
        fh.write("#\n")
        fh.write("Initial %d\n" % idmap[self.start])
        fh.write("Final %d\n" % idmap[self.end])
        fh.write("BestSegAscr 0 (NODEID ENDFRAME ASCORE)\n#\n")
        fh.write("Edges (FROM-NODEID TO-NODEID ASCORE)\n")
        logfactor = 1./math.log(logbase)
        for u in self.nodes:
            for x in u.exits:
                fh.write("%d %d %d\n" % (idmap[u], idmap[x.dest],
                                         int(x.ascr * logfactor)))
        fh.write("End\n")
        fh.close()

    def dag2dot(self, outfile):
        fh = open(outfile, "w")
        fh.write("digraph lattice {\n\trankdir=LR;\n\t")
        nodeid = {}
        fh.write("\tnode [shape=circle];")
        for i,u in enumerate(self.nodes):
            nodeid[u] = '"%s/%d"' % (u.sym, u.entry)
            if u != self.end:
                fh.write(" %s" % nodeid[u])
        fh.write(";\n\tnode [shape=doublecircle]; %s;\n\n" % nodeid[self.end])
        for x in self.edges():
            fh.write("\t%s -> %s [label=\"%.2f\"];\n"
                     % (nodeid[x.src], nodeid[x.dest], x.ascr))
        fh.write("}\n")
        fh.close()

    def n_nodes(self):
        """
        Return the number of nodes in the DAG
        @return: Number of nodes in the DAG
        @rtype: int
        """
        return len(self.nodes)

    def n_edges(self):
        """
        Return the number of edges in the DAG
        @return: Number of edges in the DAG
        @rtype: int
        """
        return sum([len(n.exits) for n in self.nodes])

    def edges(self):
        """
        Return an iterator over all edges in the DAG
        """
        for n in self.nodes:
            for x in n.exits:
                yield x

    def bestpath_edges(self, lm=None, start=None, end=None):
        """
        Find best path through lattice over edges.

        It is assumed that filler words have been bypassed before this
        function is called.  You may also want to remove unreachable
        nodes, as it will run faster.

        This function does shortest-path search over edges rather than
        nodes, which makes it possible to do full trigram expansion.
        """
        if start == None:
            start = self.start
        if end == None:
            end = self.end
        # Initialize path scores for all links exiting start
        for e in start.exits:
            if is_filler(e.dest.sym) and e.dest != end:
                continue
            e.lscr, e.lback = lm.score(baseword(e.dest.sym),
                                       baseword(e.src.sym))
            e.pscr = e.ascr + e.lscr
        # Track the best link entering the end node
        bestend = None
        bestescr = LOGZERO
        for e in self.traverse_edges_breadth():
            # Skip filler nodes in traversal
            if is_filler(e.dest.sym) and e.dest != end:
                continue
            # Update scores for all paths exiting e.dest
            for f in e.dest.exits:
                # Skip filler nodes in update
                if is_filler(f.dest.sym) and f.dest != end:
                    continue
                lscr, lback = lm.score(baseword(f.dest.sym),
                                       baseword(e.dest.sym),
                                       baseword(e.src.sym))
                pscr = e.pscr + f.ascr + lscr
                # Update its score
                if pscr > f.pscr:
                    f.pscr = pscr
                    f.lscr = lscr
                    f.lback = lback
                    f.prev = e
                    if f.dest == end and f.pscr > bestescr:
                        bestend = f
                        bestescr = f.pscr
        return bestend

    def backtrace_edges(self, end):
        """
        Return a backtrace from an end link after bestpath.

        @param end: End link
        @type end: Dag.Link
        @return: Best path through lattice from start to end.
        @rtype: list of Dag.Node
        """
        backtrace = [end.dest]
        while end:
            backtrace.append(end.src)
            end = end.prev
        backtrace.reverse()
        return backtrace

    def bestpath(self, lm=None, start=None, end=None):
        """
        Find best path through lattice using Dijkstra's algorithm.

        It is assumed that filler words have been bypassed before this
        function is called.

        @param lm: Language model to use in search
        @type lm: sphinxbase.ngram_model (or equivalent)
        @param start: Node to start search from
        @type start: Dag.Node
        @param end: Node to end search at
        @type end: Dag.Node
        @return: Final node in search (same as C{end})
        @rtype: Dag.Node
        """
        # Reset all path scores and backpointers
        Q = self.nodes[:]
        for u in Q:
            u.score = LOGZERO
            u.prev = None
        if start == None:
            start = self.start
        if end == None:
            end = self.end
        start.score = 0
        while Q:
            bestscore = LOGZERO
            bestidx = 0
            for i,u in enumerate(Q):
                if is_filler(u.sym) and u != end:
                    continue
                if u.score > bestscore:
                    bestidx = i
                    bestscore = u.score
            u = Q[bestidx]
            del Q[bestidx]
            if u == end:
                return u
            for x in u.exits:
                v = x.dest
                # Recaculate the language model score based on the
                # best history (FIXME: This is an approximation, since
                # there might be a higher scoring trigram?)
                syms = [baseword(v.sym), baseword(u.sym)]
                if u.prev:
                    syms.append(baseword(u.prev.sym))
                x.lscr, x.lback = lm.score(*syms)
                x.pscr = u.score + x.ascr + x.lscr
                if x.pscr > v.score:
                    v.score = x.pscr
                    v.prev = u

    def backtrace(self, end=None):
        """
        Return a backtrace from an optional end node after bestpath.

        @param end: End node to backtrace from (default is final node in DAG)
        @type end: Dag.Node
        @return: Best path through lattice from start to end.
        @rtype: list of Dag.Node
        """
        if end == None:
            end = self.end
        backtrace = []
        while end:
            backtrace.append(end)
            end = end.prev
        backtrace.reverse()
        return backtrace

    def node_range(self, start, end):
        """Return all nodes starting in a certain time range."""
        return [n for n in self.nodes
                if n.entry >= start
                and n.entry < end]

    def edge_slice(self, time):
        """Return all edges active at a certain time point."""
        return self.edge_range(time, time)

    def edge_range(self, start, end):
        """Return all edges active in a certain time range."""
        return [e for e in self.edges()
                if e.src.entry <= end
                and e.dest.entry > start]

    def traverse_depth(self, start=None):
        """Depth-first traversal of DAG nodes"""
        if start == None:
            start = self.start
        # Initialize the agenda (set of root nodes)
        roots = [start]
        # Keep a table of already seen nodes
        seen = {start:1}
        # Repeatedly pop the first one off of the agenda and push
        # all of its successors
        while roots:
            r = roots.pop()
            for x in r.exits:
                if x.dest not in seen:
                    roots.append(x.dest)
                    seen[x.dest] = 1
            yield r

    def traverse_breadth(self, start=None):
        """Breadth-first traversal of DAG nodes"""
        if start == None:
            start = self.start
        # Initialize the agenda (set of active nodes)
        roots = [start]
        # Keep a table of already seen nodes
        seen = {start:1}
        # Repeatedly pop the first one off of the agenda and shift
        # all of its successors
        while roots:
            r = roots.pop()
            for x in r.exits:
                if x.dest not in seen:
                    roots.insert(0, x.dest)
                    seen[x.dest] = 1
            yield r

    def reverse_breadth(self, end=None):
        """Breadth-first reverse traversal of DAG nodes"""
        if end == None:
            end = self.end
        # Initialize the agenda (set of active nodes)
        roots = [end]
        # Keep a table of already seen nodes
        seen = {end:1}
        # Repeatedly pop the first one off of the agenda and shift
        # all of its successors
        while roots:
            r = roots.pop()
            for v in r.entries:
                if v.src not in seen:
                    roots.insert(0, v.src)
                seen[v.src] = 1
            yield r

    def update_link(self, src, dest, ascr):
        """Add a link from src to dest if none exists, or update the
        acoustic score if one does and ascr is better."""
        for x in src.exits:
            if x.dest == dest:
                if ascr > x.ascr:
                    x.ascr = ascr
                # Found a link, return
                return x.ascr
        link = self.Link(src, dest, ascr)
        src.exits.append(link)
        dest.entries.append(link)

    def bypass_fillers(self, lm=None, silprob=0.1, fillprob=0.1):
        """Add links to bypass filler nodes."""
        if lm:
            silpen = math.log(silprob) * lm.lw + math.log(lm.wip)
            fillpen = math.log(fillprob) * lm.lw + math.log(lm.wip)
        else:
            silpen = math.log(silprob)
            fillpen = math.log(fillprob)
        def fill_score(link):
            if link.dest.sym == '<sil>':
                return link.ascr + silpen
            else:
                return link.ascr + fillpen
        # Do transitive closure on filler nodes
        for n in self.nodes:
            if is_filler(n.sym) and n != self.start:
                continue
            # Traverse the outgoing filler links until all non-fillers
            # are reached.
            agenda = []
            leaves = []
            for nx in n.exits:
                if is_filler(nx.dest.sym) and nx.dest != self.end:
                    fscr = fill_score(nx)
                    agenda.append((nx, fscr))
            while len(agenda):
                link, fscr = agenda.pop()
                for nx in link.dest.exits:
                    if is_filler(nx.dest.sym) and nx.dest != self.end:
                        fscr2 = fill_score(nx)
                        agenda.append((nx, fscr + fscr2))
                    else:
                        self.update_link(n, nx.dest, fscr + nx.ascr)

    def remove_unreachable(self):
        """Remove unreachable nodes and dangling edges."""
        # Mark reachable nodes from the end
        for w in self.reverse_breadth():
            w.score = 42
        # Find and remove unreachable ones, renumber remaining ones
        begone = {}
        newnodes = []
        for i, w in enumerate(self.nodes):
            if w.score == 42:
                w.id = len(newnodes)
                newnodes.append(w)
            else:
                begone[w] = 1
        self.nodes = newnodes
        # Remove links to unreachable nodes
        for w in self.nodes:
            newexits = []
            for x in w.exits:
                if x.dest in begone:
                    pass
                else:
                    newexits.append(x)
            w.exits = newexits
            newentries = []
            for x in w.entries:
                if x.src in begone:
                    pass
                else:
                    newentries.append(x)
            w.entries = newentries

    def traverse_edges_breadth(self, start=None, end=None):
        """
        Traverse edges breadth-first, ensuring that all predecessors
        to a given edge have been traversed before that edge.
        """
        for w in self.nodes:
            w.fan = 0
        for x in self.edges():
            x.dest.fan += 1
        if start == None: start = self.start
        if end == None: end = self.end
        # Agenda of closed edges
        Q = start.exits[:]
        while Q:
            e = Q[0]
            del Q[0]
            yield e
            e.dest.fan -= 1
            if e.dest.fan == 0:
                if e.dest == end:
                    break
                Q.extend(e.dest.exits)
            
    def reverse_edges_breadth(self, start=None, end=None):
        """
        Traverse edges breadth-first in reverse, ensuring that all
        successors to a given edge have been traversed before that
        edge.
        """
        for w in self.nodes:
            w.fan = 0
        for x in self.edges():
            x.src.fan += 1
        if start == None: start = self.start
        if end == None: end = self.end
        # Agenda of closed edges
        Q = end.entries[:]
        while Q:
            e = Q[0]
            del Q[0]
            yield e
            e.src.fan -= 1
            if e.src.fan == 0:
                if e.src == start:
                    break
                Q.extend(e.src.entries)
            
    def forward(self, lm=None, lw=1.0, aw=1.0):
        """
        Compute forward variable for all arcs in the lattice.

        @param lm: Language model to use in computation
        @type lm: sphinxbase.ngram_model (or equivalent)
        """
        for wx in self.traverse_edges_breadth():
            # This is alpha_t(w)
            wx.alpha = LOGZERO
            # If wx.src has no predecessors the previous alpha is 1.0
            if len(wx.src.entries) == 0:
                wx.alpha = wx.ascr * aw
            # For each predecessor node to wx.src
            for vx in wx.src.entries:
                # Get unscaled language model score P(w|v) (bigrams only for now...)
                if lm:
                    lscr = lm.prob(baseword(wx.src.sym),
                                   baseword(vx.src.sym))[0] * lw
                else:
                    lscr = 0
                # Accumulate alpha for this arc
                wx.alpha = logadd(wx.alpha, vx.alpha + lscr + wx.ascr * aw)

    def backward(self, lm=None, lw=1.0, aw=1.0):
        """
        Compute backward variable for all arcs in the lattice.

        @param lm: Language model to use in computation
        @type lm: sphinxbase.ngram_model.NGramModel (or equivalent)
        """
        for vx in self.reverse_edges_breadth():
            # Beta for arcs into </s> = 1.0
            if vx.dest == self.end:
                vx.beta = 0
            else:
                vx.beta = LOGZERO
                # Get unscaled language model probability P(w|v) (bigrams only for now...)
                if lm:
                    lscr = lm.prob(baseword(vx.dest.sym),
                                   baseword(vx.src.sym))[0] * lw
                else:
                    lscr = 0
                # For each outgoing arc from vx.dest
                for wx in vx.dest.exits:
                    # Accumulate beta for this arc
                    vx.beta = logadd(vx.beta, wx.beta + lscr + wx.ascr * aw)

    def posterior(self, lm=None, lw=1.0, aw=1.0):
        """
        Compute arc posterior probabilities.

        @param lm: Language model to use in computation
        @type lm: sphinxbase.ngram_model.NGramModel (or equivalent)
        """
        # Clear alphas, betas, and posteriors
        for w in self.nodes:
            for wx in w.exits:
                wx.alpha = wx.beta = wx.post = LOGZERO
        # Run forward and backward
        self.forward(lm, lw, aw)
        self.backward(lm, lw, aw)
        # Sum over alpha for arcs entering the end node to get normalizer
        norm = LOGZERO
        for vx in self.end.entries:
            norm = logadd(norm, vx.alpha)
        # Iterate over all arcs and normalize
        for w in self.nodes:
            for wx in w.exits:
                wx.post = wx.alpha + wx.beta - norm

    def best_posterior(self, node, start=None, end=None, wlen=0.4):
        """
        Find the maximum local posterior probability estimate for node.
        """
        # If window is zero, just return the best exit for node
        if wlen == 0:
            return max([LOGZERO] + [x.post for x in node.exits])
        # Find start and end if not given
        if start == None:
            start = node.entry
        if end == None:
            if node.exits:
                end = max([x.dest.entry for x in node.exits])
            else:
                end = self.n_frames
        window = int((end - start) * wlen)
        ws = max(start - window, 0)
        we = min(end + window, self.n_frames)
        return max([LOGZERO]
                   + [x.post for x in self.edge_range(ws, we)
                      if (baseword(x.src.sym) == baseword(node.sym))])

    def minimum_error(self, hyp):
        """
        Find the minimum word error rate path through lattice,
        returning the number of errors and an alignment.
        @return: Tuple of (error-count, alignment of (hyp, ref) pairs)
        @rtype: (int, list(string, string))
        """
        # Initialize the alignment matrix
        align_matrix = numpy.ones((len(hyp),len(self.nodes)), 'i') * 999999999
        # And the backpointer matrix
        bp_matrix = numpy.zeros((len(hyp),len(self.nodes)), 'O')
        # Remove filler nodes from the reference
        hyp = filter(lambda x: not is_filler(x), hyp)
        # Bypass filler nodes in the lattice
        self.bypass_fillers()
        # Figure out the minimum distance to each node from the start
        # of the lattice, and construct a node to ID mapping
        nodeid = {}
        for i,u in enumerate(self.nodes):
            u.score = 999999999
            nodeid[u] = i
        self.start.score = 1
        for u in self.nodes:
            if is_filler(u.sym):
                continue
            for x in u.exits:
                dist = u.score + 1
                if dist < x.dest.score:
                    x.dest.score = dist
        def find_pred(ii, jj):
            bestscore = 999999999
            bestp = -1
            if len(self.nodes[jj].entries) == 0:
                return bestp, bestscore
            for e in self.nodes[jj].entries:
                k = nodeid[e.src]
                if align_matrix[ii,k] < bestscore:
                    bestp = k
                    bestscore = align_matrix[ii,k]
            return bestp, bestscore
        # Now fill in the alignment matrix
        for i, w in enumerate(hyp):
            for j, u in enumerate(self.nodes):
                # Insertion = cost(w, prev(u)) + 1
                if u == self.start: # start node
                    bestp = -1
                    inscost = i + 2 # Distance from start of ref
                else:
                    # Find best predecessor in the same reference position
                    bestp, bestscore = find_pred(i, j)
                    inscost = align_matrix[i,bestp] + 1
                # Deletion  = cost(prev(w), u) + 1
                if i == 0: # start symbol
                    delcost = u.score + 1 # Distance from start of hyp
                else:
                    delcost = align_matrix[i-1,j] + 1
                # Substitution = cost(prev(w), prev(u)) + (w != u)
                if i == 0 and bestp == -1: # Start node, start of ref
                    subcost = int(baseword(w) != baseword(u.sym))
                elif i == 0: # Start of ref
                    subcost = (self.nodes[bestp].score
                               + int(baseword(w) != baseword(u.sym)))
                elif bestp == -1: # Start node
                    subcost = i - 1 + int(baseword(w) != baseword(u.sym))
                else:
                    # Find best predecessor in the previous reference position
                    bestp, bestscore = find_pred(i-1, j)
                    subcost = (align_matrix[i-1,bestp]
                               + int(baseword(w) != baseword(u.sym)))
                align_matrix[i,j] = min(subcost, inscost, delcost)
                # Now find the argmin
                if align_matrix[i,j] == subcost:
                    bp_matrix[i,j] = (i-1, bestp)
                elif align_matrix[i,j] == inscost:
                    bp_matrix[i,j] = (i, bestp)
                else:
                    bp_matrix[i,j] = (i-1, j)
        # Find last node's index
        last = nodeid[self.end]
        # Backtrace to get an alignment
        i = len(hyp)-1
        j = last
        bt = []
        while True:
            ip,jp = bp_matrix[i,j]
            if ip == i: # Insertion
                bt.append(('INS', baseword(self.nodes[j].sym)))
            elif jp == j: # Deletion
                bt.append((hyp[i], 'DEL'))
            else:
                bt.append((hyp[i], baseword(self.nodes[j].sym)))
            # If we consume both ref and hyp, we are done
            if ip == -1 and jp == -1:
                break
            # If we hit the beginning of the ref, fill with insertions
            if ip == -1:
                while True:
                    bt.append(('INS', baseword(self.nodes[jp].sym)))
                    bestp, bestscore = find_pred(i,jp)
                    if bestp == -1:
                        break
                    jp = bestp
                break
            # If we hit the beginning of the hyp, fill with deletions
            if jp == -1:
                while ip >= 0:
                    bt.append((hyp[ip], 'DEL'))
                    ip = ip - 1
                break
            # Follow the pointer
            i,j = ip,jp
        bt.reverse()
        return align_matrix[-1,last], bt

def forward_tg(self, lm=None, lw=1.0, aw=1.0):
    """
    Compute forward variable for all arcs in the lattice using trigrams.

    @param lm: Language model to use in computation
    @type lm: sphinxbase.ngram_model (or equivalent)
    """
    for wx in self.traverse_edges_breadth():
        # We keep a separate alpha for each trigram history
        # This is alpha_t(w)
        wx.alpha = LOGZERO
        # If wx.src has no predecessors the previous alpha is 1.0
        if len(wx.src.entries) == 0:
            wx.alpha = wx.ascr * aw
        # For each predecessor node to wx.src
        for vx in wx.src.entries:
            # Get unscaled language model score P(w|v) (bigrams only for now...)
            if lm:
                lscr = lm.prob(baseword(wx.src.sym),
                               baseword(vx.src.sym))[0] * lw
            else:
                lscr = 0
            # Accumulate alpha for this arc
            wx.alpha = logadd(wx.alpha, vx.alpha + lscr + wx.ascr * aw)

def backward_tg(self, lm=None, lw=1.0, aw=1.0):
    """
    Compute backward variable for all arcs in the lattice.

    @param lm: Language model to use in computation
    @type lm: sphinxbase.ngram_model.NGramModel (or equivalent)
    """
    for vx in self.reverse_edges_breadth():
        # Beta for arcs into </s> = 1.0
        if vx.dest == self.end:
            vx.beta = 0
        else:
            vx.beta = LOGZERO
            # Get unscaled language model probability P(w|v) (bigrams only for now...)
            if lm:
                lscr = lm.prob(baseword(vx.dest.sym),
                               baseword(vx.src.sym))[0] * lw
            else:
                lscr = 0
            # For each outgoing arc from vx.dest
            for wx in vx.dest.exits:
                # Accumulate beta for this arc
                vx.beta = logadd(vx.beta, wx.beta + lscr + wx.ascr * aw)