classdef instrument < stimulus.sound.rhythm
% stimulus.sound.rhythm.instrument
% 
% Description:	generate rhythm stimuli with a regular sequence of random
%				instruments
% 
% Syntax: obj = stimulus.sound.rhythm.instrument([param1,val1,...,paramN,valN])
% 
% Methods:
%	generate:	generate a stimulus
%	validate:	validate a set of parameter values
% 
% Properties:
%	param:	a property collection of parameters that the generator function will
%			use to generate the stimulus. includes:
%				instrument: ({1,2}) see stimulus.sound.rhythm
%				pattern: ('uniform') see stimulus.sound.rhythm
%			<see also stimulus.sound.rhythm>
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
			function obj = instrument(varargin)
				obj = obj@stimulus.sound.rhythm();
				
				%set some parameter defaults
					add(obj.param,'instrument','generic',{{1,2}});
					add(obj.param,'pattern','generic',{'uniform'});
				
				%parse the inputs
					obj.parseInputs(varargin{:})
			end
		end
%/METHODS-----------------------------------------------------------------------

end
