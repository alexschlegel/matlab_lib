function ndPath = path(nd,nd2)
% Graph.Node.path
% 
% Description:	find the shortest path to another node
% 
% Syntax:	ndPath = nd.path(nd2)
% 
% In:
% 	nd2	- the node to which to find a path
% 
% Out:
% 	ndPath	- an Nx1 array of Graph.Nodes that connect nd to nd2
% 
% Updated: 2012-01-01
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
ndSearch	= nd;
ndPath		= {nd};
nSearch		= 1;

ndSearched	= Graph.Node.empty;
kMatch		= [];
while true
	%do we have a match?
		kMatch	= find(ndSearch==nd2,1);
		if ~isempty(kMatch)
			break;
		end
	%nope, add the nodes to our searched list
		ndSearched	= [ndSearched ndSearch];
	%get the new children of all search nodes
		%get all children
			kPath	= [];
			ndChild	= Graph.Node.empty;
			for kS=1:nSearch
				ndChildCur	= [ndSearch(kS).edge.node];
				kPath		= [kPath repmat(kS,[1 numel(ndChildCur)])];
				ndChild		= [ndChild ndChildCur];
			end
		%keep only the new ones
			[ndSearch,kSearch]	= setdiff(ndChild,ndSearched);
			kPath				= kPath(kSearch);
			nSearch				= numel(ndSearch);
		%are we at the end of the road
			if nSearch==0
				break;
			end
		%update the path
			ndPathNew	= cell(nSearch,1);
			for kS=nSearch:-1:1
				ndPathNew{kS}	= [ndPath{kPath(kS)} ndSearch(kS)];
			end
			ndPath	= ndPathNew;
end

if ~isempty(kMatch)
	ndPath	= ndPath{kMatch};
else
	ndPath	= Graph.Node.empty;
end
