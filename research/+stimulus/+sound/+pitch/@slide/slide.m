classdef slide < stimulus.sound.pitch
% stimulus.sound.pitch.slide
% 
% Description:	generate pitch sequence stimuli that default to pchip
%				interpolation, giving a smooth slide between pitches
% 
% Syntax: obj = stimulus.sound.pitch.slide([param1,val1,...,paramN,valN])
% 
% Methods:
%	generate:	generate a stimulus
%	validate:	validate a set of parameter values
% 
% Properties:
%	param:	a property collection of parameters that the generator function will
%			use to generate the stimulus. includes:
%				interp: ('pchip') the interpolation method for transitioning
%					between pitches.
%			<see also stimulus.sound.pitch>
% 
% In:
%	[paramK]	- the Kth parameter whose value should be set explicitly
%	[valK]		- the explicit value of parameter paramK (or empty to skip
%				  skip setting the value)
% 
% Updated:	2015-10-07
% Copyright 2015 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%METHODS------------------------------------------------------------------------
	%CONSTRUCTOR
		methods (Access=public)
			function obj = slide(varargin)
				obj = obj@stimulus.sound.pitch();
				
				%set some parameter defaults
					add(obj.param,'interp','generic',{'pchip'});
				
				%parse the inputs
					obj.parseInputs(varargin{:})
			end
		end
%/METHODS-----------------------------------------------------------------------

end
