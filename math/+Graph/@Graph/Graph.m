classdef Graph < handle
% Graph.Graph
% 
% Description:	a graph object, created indirectly by creating nodes and edges
% 
% Syntax:	g = Graph.Graph
% 
%			methods:
%				Render:	render an image of the graph
%
% 			properties:
%				node:	an array of the Graph.Nodes in the graph
%				edge:	an array of the Graph.Edges in the graph
%
% Updated: 2012-01-02
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

	%PUBLIC PROPERTIES---------------------------------------------------------%
	properties (Dependent)
		node;
		edge;
	end
	properties (Hidden)
		h_node	= Graph.Node.empty;
		h_edge	= Graph.Edge.empty;
	end
	%PUBLIC PROPERTIES---------------------------------------------------------%
	
	
	%PROPERTY GET/SET----------------------------------------------------------%
	methods
		%----------------------------------------------------------------------%
		function nd = get.node(g)
			nd	= g.h_node;
		end
		%----------------------------------------------------------------------%
		function set.node(g,nd)
			%prevent a node from showing up twice in a graph
				nd	= reshape(unique(nd),1,[]);
			%new and old nodes
				ndNew	= setdiff(nd,g.h_node);
				ndOld	= setdiff(g.h_node,nd);
				
				nNew	= numel(ndNew);
				nOld	= numel(ndOld);
			%set the new node list
				g.h_node	= nd;
			
			if nOld>0
				%remove the graph from the old nodes
					for kN=1:nOld
						ndOld(kN).h_graph	= setdiff(ndOld(kN).h_graph,g);
					end
				%remove edges with nodes not in the new list
					ndEdge				= reshape([g.h_edge.h_node],2,numel(g.h_edge));
					bOldEdge			= any(ismember(ndEdge,ndOld));
					g.edge(bOldEdge)	= [];
			end
			
			if nNew>0
				%add the graph to the new nodes
					for kN=1:nNew
						ndNew(kN).h_graph	= [ndNew(kN).h_graph g];
					end
			end
		end
		%----------------------------------------------------------------------%
		function ed = get.edge(g)
			ed	= g.h_edge;
		end
		%----------------------------------------------------------------------%
		function set.edge(g,ed)
			%prevent an edge from showing up twice in a graph
				ed	= reshape(unique(ed),1,[]);
			%new and old edges
				edNew	= setdiff(ed,g.h_edge);
				edOld	= setdiff(g.h_edge,ed);
				
				nNew	= numel(edNew);
				nOld	= numel(edOld);
			%set the new node list
				g.h_edge	= ed;
			
			if nOld>0
				%remove the graph from the old edges
					for kE=1:nOld
						edOld(kE).h_graph	= setdiff(edOld(kE).h_graph,g);
					end
			end
			
			if nNew>0
				%add the graph to the new edges
					for kE=1:nNew
						edNew(kE).h_graph	= [edNew(kE).h_graph g];
					end
				%add the new nodes
					ndNew	= setdiff(unique([edNew.node]),g.h_node);
					g.node	= [g.node ndNew];
			end
		end
		%----------------------------------------------------------------------%
	end
	%PROPERTY GET/SET----------------------------------------------------------%
	
	
	%PUBLIC METHODS------------------------------------------------------------%
	methods
		%----------------------------------------------------------------------%
		function g = Graph(varargin)
			
		end
		%----------------------------------------------------------------------%
		function Merge(g,G)
		%Graph.Graph.Merge
		%
		%merge g with an array of other graphs, deleting the other graphs in the
		%process
		%
		%g.Merge(G)
			if ~isempty(G) && ~all(G(:)==g)
				%get the nodes and edges to add
					ndMerge	= unique([G.h_node]);
					edMerge	= unique([g.h_edge]);
				%delete the old graphs
					delete(setdiff(G,g));
				%add nodes and edges
					g.h_node	= unique([g.h_node ndMerge]);
					g.h_edge	= unique([g.h_edge edMerge]);
				%add the graph to the nodes and edges
					if ~isempty(ndMerge)
						if isempty([ndMerge.h_graph])
							[ndMerge.h_graph]	= deal(g);
						else
							nNodeMerge	= numel(ndMerge);
							for kN=1:nNodeMerge
								ndMerge(kN).h_graph	= [setdiff(ndMerge(kN).h_graph,g) g];
							end
						end
					end
					
					if ~isempty(edMerge)
						if isempty([edMerge.h_graph])
							[edMerge.h_graph]	= deal(g);
						else
							nEdgeMerge	= numel(edMerge);
							for kE=1:nEdgeMerge
								edMerge(kE).h_graph	= [setdiff(edMerge(kE).h_graph,g) g];
							end
						end
					end
			end
		end
		%----------------------------------------------------------------------%
	end
	%PUBLIC METHODS------------------------------------------------------------%
	
	
	%OVERLOADED FUNCTIONS------------------------------------------------------%
	methods
		%----------------------------------------------------------------------%
		function delete(g)
			%remove the graph from its nodes and edges
				nNode	= numel(g.h_node);
				for kN=1:nNode
					g.h_node(kN).h_graph	= setdiff(g.h_node(kN).h_graph,g);
				end
				
				nEdge	= numel(g.h_edge);
				for kE=1:nEdge
					g.h_edge(kE).h_graph	= setdiff(g.h_edge(kE).h_graph,g);
				end
			
			delete@handle(g);
		end
		%----------------------------------------------------------------------%
	end
	%OVERLOADED FUNCTIONS------------------------------------------------------%
	
	
	%PRIVATE METHODS-----------------------------------------------------------%
	methods (Access=private)
		
	end
	%PRIVATE METHODS-----------------------------------------------------------%
	
end
