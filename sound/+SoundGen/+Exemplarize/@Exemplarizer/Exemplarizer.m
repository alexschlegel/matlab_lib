classdef Exemplarizer < SoundGen.Operation
% SoundGen.Exemplarize.Exemplarizer
% 
% Description:	base class for SoundGen.Exemplarize.* objects
% 
% Syntax:	e = SoundGen.Exemplarize.Exemplarizer(parent,<options>)
% 
% 			subfunctions:
%				Run	- run the exemplarize process
% 			 
% 			properties:
%				result			- an Sx1 array of segment index exemplars
%				intermediate	- a struct of intermediate processing results
%								  (read only)
%				ran				- true if the exemplarizer has already run
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
		function e = Exemplarizer(parent,varargin)
			e	= e@SoundGen.Operation(parent,'exemplarizer',varargin{:});
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
