classdef Concatenater < SoundGen.Operation
% SoundGen.Concatenate.Concatenater
% 
% Description:	base class for SoundGen.Concatenate.* objects
% 
% Syntax:	c = SoundGen.Concatenate.Concatenater(parent,<options>)
% 
% 			subfunctions:
%				Run	- run the concatenate process
% 			 
% 			properties:
%				result			- a Px1 concatenated audio signal
%				intermediate	- a struct of intermediate processing results
%								  (read only)
%				ran				- true if the concatenation has already run
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
		function c = Concatenater(parent,varargin)
			c	= c@SoundGen.Operation(parent,'concatenater',varargin{:});
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
