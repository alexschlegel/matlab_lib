classdef Edge < handle
% Graph.Edge
% 
% Description:	a graph edge
% 
% Syntax:	ed = Graph.Edge(nd1,nd2,[g]=<merged>)
% 
% 			properties:
%				name:		the edge name
% 				weight:		the edge weight
%				color:		the edge color ([r g b])
%				direction:	the edge direction:
%								-1:	node 2 to node 1
%								0:	undirected
%								1:	node 1 to node 2
% 
%				node (get):	a two-element Graph.Node array of the nodes joined by
%							the edge
%				graph:		an array of Graph.Graphs to which the edge belongs
%
% In:
%	nd1	- the first Graph.Node connected by the edge
%	nd2	- the second Graph.Node connected by the edge
%	[g]	- the graph to which to add the edge.  if unspecified, all the graphs
%		  from nd1 and nd2 are merged into a new one
% 
% Updated: 2012-01-02
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

	%PUBLIC PROPERTIES---------------------------------------------------------%
	properties
		direction	= 0;
		name		= '';
		weight		= 1;
		color		= [0 0 0];
	end
	properties (Dependent, SetAccess=protected)
		node;
	end
	properties (Dependent)
		graph;
	end
	properties (Hidden)
		h_node;
		h_graph;
	end
	%PUBLIC PROPERTIES---------------------------------------------------------%
	
	
	%PROPERTY GET/SET----------------------------------------------------------%
	methods
		%----------------------------------------------------------------------%
		function nd = get.node(ed)
			nd	= ed.h_node;
		end
		%----------------------------------------------------------------------%
		function g = get.graph(ed)
			g	= ed.h_graph;
		end
		%----------------------------------------------------------------------%
		function set.graph(ed,g)
			%prevent a graph from showing up twice
				g	= reshape(unique(g),1,[]);
			%new and old graphs
				gNew	= setdiff(g,ed.h_graph);
				gOld	= setdiff(ed.h_graph,g);
				
				nNew	= numel(gNew);
				nOld	= numel(gOld);
			
			%remove the edge from the old graphs
				for kG=1:nOld
					gOld(kG).edge	= setdiff(gOld(kG).edge,ed);
				end
			%add the edge to the new graphs
				for kG=1:nNew
					gNew(kG).edge	= [gNew(kG).edge ed];
				end
		end
		%----------------------------------------------------------------------%
	end
	%PROPERTY GET/SET----------------------------------------------------------%
	
	
	%PUBLIC METHODS------------------------------------------------------------%
	methods
		function ed = Edge(nd1,nd2,varargin)
			%construct the new graph
				if numel(varargin)>2
					g	= varargin{1};
				else
					G	= [[nd1.graph] [nd2.graph]];
					if isempty(G)
						g	= Graph.Graph;
					else
						G(1).Merge(G(2:end));
						
						g	= G(1);
					end
				end
			%does the edge already exist?
				[bSame,kSame]	= ismember(nd1.edge,nd2.edge);
				kSame			= kSame(bSame);
				
				if ~isempty(kSame)
				%edge exists, just return it
					ed	= nd2.edge(kSame);
				else
				%edge doesn't exist, create it
					ed.h_node			= [nd1 nd2];
					nd1.h_edge(end+1)	= ed;
					nd2.h_edge(end+1)	= ed;
					ed.graph			= g;
				end
		end
	end
	%PUBLIC METHODS------------------------------------------------------------%
	
	
	%OVERLOADED FUNCTIONS------------------------------------------------------%
	methods
		%----------------------------------------------------------------------%
		function delete(ed)
		%Graph.Edge destructor function
		%
		%delete(ed)
			
			%remove the edge from its nodes
				ed.h_node(1).h_edge(find(ed.h_node(1).h_edge==ed,1))	= [];
				ed.h_node(2).h_edge(find(ed.h_node(2).h_edge==ed,1))	= [];
			%remove the edge from its graphs
				ed.graph	= Graph.Graph.empty;
			
			delete@handle(ed);
		end
		%----------------------------------------------------------------------%
	end
	%OVERLOADED FUNCTIONS------------------------------------------------------%
end
