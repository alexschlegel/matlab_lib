classdef Node < handle
% Graph.Node
% 
% Description:	a graph node
% 
% Syntax:	nd = Graph.Node([g]=<none>)
% 
%			methods:
%				path:	find a path to another node
%
% 			properties:
%				name:	the node name
% 				weight:	the node weight
%				color:	the node color ([r g b])
%				x:		the node x-position
%				y:		the node y-position
%
%				edge (get):	an array of Graph.Edges to other nodes
%				graph:		an array of Graph.Graphs to which the node belongs
%
% In:
%	[g]	- the graph to which to add the node
% 
% Updated: 2012-01-02
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

	%PUBLIC PROPERTIES---------------------------------------------------------%
	properties
		name		= '';
		weight		= 1;
		color		= [0 0 0];
		x			= NaN;
		y			= NaN;
	end
	properties (Dependent, SetAccess=protected)
		edge;
	end
	properties (Dependent)
		graph;
	end
	properties (Hidden)
		h_edge	= Graph.Edge.empty;
		h_graph	= Graph.Graph.empty;
	end
	%PUBLIC PROPERTIES---------------------------------------------------------%
	
	
	%PROPERTY GET/SET----------------------------------------------------------%
	methods
		%----------------------------------------------------------------------%
		function ed = get.edge(nd)
			ed	= nd.h_edge;
		end
		%----------------------------------------------------------------------%
		function g = get.graph(nd)
			g	= nd.h_graph;
		end
		%----------------------------------------------------------------------%
		function set.graph(nd,g)
			%prevent a graph from showing up twice
				g	= reshape(unique(g),1,[]);
			%new and old graphs
				gNew	= setdiff(g,nd.h_graph);
				gOld	= setdiff(nd.h_graph,g);
				
				nNew	= numel(gNew);
				nOld	= numel(gOld);
			
			%remove the node from the old graphs
				for kG=1:nOld
					gOld(kG).node	= setdiff(gOld(kG).node,nd);
				end
			%add the node to the new graphs
				for kG=1:nNew
					gNew(kG).node	= [gNew(kG).node nd];
				end
		end
		%----------------------------------------------------------------------%
	end
	%PROPERTY GET/SET----------------------------------------------------------%
	
	
	%PUBLIC METHODS------------------------------------------------------------%
	methods
		function nd = Node(varargin)
			if nargin>0
				nd.graph	= varargin{1};
			end
		end
	end
	%PUBLIC METHODS------------------------------------------------------------%
	
	
	%OVERLOADED FUNCTIONS------------------------------------------------------%
	methods
		%----------------------------------------------------------------------%
		function delete(nd)
		%Graph.Node destructor function
		%
		%delete(nd)
			
			%delete the node's edges
				delete(nd.edge);
			%remove the node from its graphs
				nd.graph	= Graph.Graph.empty;
			
			delete@handle(nd);
		end
		%----------------------------------------------------------------------%
	end
	%OVERLOADED FUNCTIONS------------------------------------------------------%
end
