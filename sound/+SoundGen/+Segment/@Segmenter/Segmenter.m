classdef Segmenter < SoundGen.Operation
% SoundGen.Segment.Segmenter
% 
% Description:	base class for SoundGen.Segment.* objects
% 
% Syntax:	s = SoundGen.Segment.Segmenter(parent,<options>)
% 
% 			subfunctions:
%				Run	- run the segmenter process
% 			 
% 			properties:
%				result			- an Mx2 array of segment start and end indices
%								  that gets set during a call to Run
%				intermediate	- a struct of intermediate processing results
%								  (read only)
%				ran				- true if the segmenter has already run
%				silent			- true if processes should be silent
% 
% In:
%	parent	- the parent SoundGen.System object
%	<options>:
%		silent:	(false) true if processes should be silent
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
		function s = Segmenter(parent,varargin)
			s	= s@SoundGen.Operation(parent,'segmenter',varargin{:});
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
