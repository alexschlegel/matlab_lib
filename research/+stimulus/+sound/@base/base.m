classdef base < stimulus.base
% stimulus.sound.base
% 
% Description:	base class for sound stimulus generating classes
% 
% Syntax: obj = stimulus.sound.base([param1,val1,...,paramN,valN])
% 
% Methods:
%	generate:	generate a stimulus
%	validate:	validate a set of parameter values
% 
% Properties:
%	param:	a property collection of parameters that the generator function will
%			use to generate the stimulus. includes:
%				rate: (44100) the sampling rate, in Hz
%				dur: (2) the stimulus duration, in seconds (may be ignored by
%					subclasses)
%			<see also stimulus.base>
% 
% In:
%	[paramK]	- the Kth parameter whose value should be set explicitly
%	[valK]		- the explicit value of parameter paramK (or empty to skip
%				  skip setting the value)
% 
% Updated:	2015-11-17
% Copyright 2015 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%METHODS------------------------------------------------------------------------
	%CONSTRUCTOR
		methods (Access=public)
			function obj = base(varargin)
				obj = obj@stimulus.base();
				
				%set some parameter defaults
					add(obj.param,'rate','generic',{44100});
					add(obj.param,'dur','generic',{2});
				
				%parse the inputs
					obj.parseInputs(varargin{:})
			end
		end
	
	%PRIVATE
		methods (Access=protected)
			[stim,ifo] = generate_inner(obj,ifo)
			[stim,ifo] = generate_sound(obj,ifo)
		end
%/METHODS-----------------------------------------------------------------------

end
