classdef pitch < stimulus.sound.base
% stimulus.sound.pitch
% 
% Description:	generate pitch sequence stimuli
% 
% Syntax: obj = stimulus.sound.pitch([param1,val1,...,paramN,valN])
% 
% Methods:
%	generate:	generate a stimulus
%	validate:	validate a set of parameter values
% 
% Properties:
%	param:	a property collection of parameters that the generator function will
%			use to generate the stimulus. includes:
%				n: (<from d>) the number of tones in the sequence
%				instrument: ('sin') the name of an instrument function to use.
%					the function should accept a t parameter and return a
%					periodic value with period 2*pi. note that this should be
%					the string name of the function, rather than a function
%					handle.
%				fmin: (200) the minimum frequency from which to choose
%				fmax: (2000) the maximum frequency from which to choose
%				f: (<random>) an array of pitch frequencies to step through.
%					overrides <n>, <fmin>, and <fmax>.
%				interp: ('nearest') the interpolation method for transitioning
%					between pitches.
%			<see also stimulus.sound.base>
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
			function obj = pitch(varargin)
				obj = obj@stimulus.sound.base();
				
				obj.difficulty_param		= 'n';
				obj.difficulty_param_min	= 3;
				obj.difficulty_param_max	= 40;
				obj.difficulty_param_round	= true;
				
				%set some parameter defaults
					add(obj.param,'n','generic',{@() obj.get_difficulty_param_value(obj.param.d)});
					add(obj.param,'instrument','generic',{'sin'});
					add(obj.param,'fmin','generic',{200});
					add(obj.param,'fmax','generic',{2000});
					%add(obj.param,'f','range',{@() [obj.param.fmin obj.param.fmax],'size',@() [obj.param.n 1]});
					add(obj.param,'f','generic',{@() get_pitches(obj)});
					add(obj.param,'interp','generic',{'nearest'});
				
				%parse the inputs
					obj.parseInputs(varargin{:})
			end
		end
	
	%PRIVATE
		methods (Access=protected)
			[stim,ifo] = generate_sound(obj,ifo)
			f = get_pitches(obj)
		end
%/METHODS-----------------------------------------------------------------------

end
