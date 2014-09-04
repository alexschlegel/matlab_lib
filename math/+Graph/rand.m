function g = rand(nNode,nEdge)
% Graph.rand
% 
% Description:	create a random graph set
% 
% Syntax:	g = rand(nNode,nEdge)
% 
% In:
% 	nNode	- the number of nodes
%	nEdge	- the number of edges
% 
% Out:
% 	g	- a graph comprising the random nodes and edges
% 
% Updated: 2012-01-02
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%create the graph
	g	= Graph.Graph;
%create the nodes
	g.node(nNode)	= Graph.Node;
	
	cName			= arrayfun(@num2str,1:nNode,'UniformOutput',false);
	[g.node.name]	= deal(cName{:});
%create the edges
	%get all possible pairings
		kPair	= handshakes(1:nNode);
		nPair	= size(kPair,1);
		
		if nPair<nEdge
			error([num2str(nNode) ' nodes can have no more than ' num2str(nPair) ' edges.']);
		end
		
		cPair	= mat2cell(kPair,ones(nPair,1),2);
	%choose from among them
		cEdge	= randFrom(cPair,[nEdge 1]);
	%make the edges
		ed	= cellfun(@(x) Graph.Edge(g.node(x(1)),g.node(x(2))),cEdge,'UniformOutput',false);
