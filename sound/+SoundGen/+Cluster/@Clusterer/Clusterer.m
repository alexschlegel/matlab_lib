classdef Clusterer < SoundGen.Operation
% SoundGen.Cluster.Clusterer
% 
% Description:	base class for SoundGen.Cluster.* objects
% 
% Syntax:	c = SoundGen.Cluster.Clusterer(parent,<options>)
% 
% 			subfunctions:
%				Run	- run the cluster process
% 			 
% 			properties:
%				result			- an Mx1 cluster string array of clusters to
%								  which each segment was assigned during a call
%								  to Run
%				intermediate	- a struct of intermediate processing results
%								  (read only)
%				ran				- true if the clusterer has already run
%				silent			- true if processes should be silent
% 
% In:
%	parent	- the parent SoundGen.System object
%	<options>:
%		silent:	(<parent value>) true if processes should be silent

%
% Updated: 2012-11-03
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

	%PUBLIC PROPERTIES---------------------------------------------------------%
	properties
		
	end
	%PUBLIC PROPERTIES---------------------------------------------------------%
	
	
	%PRIVATE PROPERTIES--------------------------------------------------------%
	properties (SetAccess=protected, GetAccess=protected)
		
	end
	%PRIVATE PROPERTIES--------------------------------------------------------%
	
	
	%PROPERTY GET/SET----------------------------------------------------------%
	methods
		
	end
	%PROPERTY GET/SET----------------------------------------------------------%
	
	
	%PUBLIC METHODS------------------------------------------------------------%
	methods
		function c = Clusterer(parent,varargin)
			c	= c@SoundGen.Operation(parent,'clusterer',varargin{:});
		end
	end
	methods (Static)
		
	end
	%PUBLIC METHODS------------------------------------------------------------%
	
	
	%OVERLOADED FUNCTIONS------------------------------------------------------%
	methods
		
	end
	%OVERLOADED FUNCTIONS------------------------------------------------------%
	
	
	%PRIVATE METHODS-----------------------------------------------------------%
	methods (Access=private)
		
	end
	%PRIVATE METHODS-----------------------------------------------------------%
	
end
