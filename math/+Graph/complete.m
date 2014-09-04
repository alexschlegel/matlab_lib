function g = complete(nNode)
% Graph.complete
% 
% Description:	create a complete graph with nNode nodes
% 
% Syntax:	g = complete(nNode)
% 
% In:
% 	nNode	- the number of nodes
% 
% Out:
% 	g	- the complete graph
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
		
		cPair	= mat2cell(kPair,ones(nPair,1),2);
	%make the edges
		ed	= cellfun(@(x) Graph.Edge(g.node(x(1)),g.node(x(2))),cPair,'UniformOutput',false);
