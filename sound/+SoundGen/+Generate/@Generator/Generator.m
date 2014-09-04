classdef Generator < SoundGen.Operation
% SoundGen.Generate.Generator
% 
% Description:	base class for SoundGen.Generate.* objects
% 
% Syntax:	g = SoundGen.Generate.Generator(parent,<options>)
% 
% 			subfunctions:
%				Run	- run the generate process
% 			 
% 			properties:
%				result			- an Sx1 generated cluster string array assigned
%								  during a call to Run
%				intermediate	- a struct of intermediate processing results
%								  (read only)
%				ran				- true if the generator has already run
%				silent			- true if processes should be silent
% 
% In:
%	parent	- the parent SoundGen.System object
%	<options>:
%		silent:	(false) true if processes should be silent
%
% Updated: 2012-11-02
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
		function g = Generator(parent,varargin)
			g	= g@SoundGen.Operation(parent,'generator',varargin{:});
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
