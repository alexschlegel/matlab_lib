classdef base < stimulus.base
% stimulus.image.base
% 
% Description:	base class for image stimulus generating classes
% 
% Syntax: obj = stimulus.image.base([param1,val1,...,paramN,valN])
% 
% Methods:
%	generate:	generate a stimulus
%	validate:	validate a set of parameter values
% 
% Properties:
%	param:	a property collection of parameters that the generator function will
%			use to generate the stimulus. includes:
%				size: (400) the figure size, in pixels
%				foreground: ([1 1 1]) the foreground color
%				background: ([0.5 0.5 0.5]) the background color
%			<see also stimulus.base>
% 
% In:
%	[paramK]	- the Kth parameter whose value should be set explicitly
%	[valK]		- the explicit value of parameter paramK (or empty to skip
%				  skip setting the value)
% 
% Updated:	2015-09-29
% Copyright 2015 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%METHODS------------------------------------------------------------------------
	%CONSTRUCTOR
		methods (Access=public)
			function obj = base(varargin)
				obj = obj@stimulus.base();
				
				%set some parameter defaults
					add(obj.param,'size','generic',{400});
					add(obj.param,'foreground','generic',{[1 1 1]});
					add(obj.param,'background','generic',{[0.5 0.5 0.5]});
				
				%parse the inputs
					obj.parseInputs(varargin{:})
			end
		end
	
	%PRIVATE
		methods (Access=protected)
			[stim,ifo] = generate_inner(obj,ifo)
			[mask,ifo] = generate_mask(obj,ifo)
			[stim,ifo] = generate_image(obj,mask,ifo)
		end
%/METHODS-----------------------------------------------------------------------

end
