classdef cloud < stimulus.image.scribble
% stimulus.image.scribble.cloud
% 
% Description:	create a scribble cloud figure
% 
% Syntax: obj = stimulus.image.scribble.cloud([param1,val1,...,paramN,valN])
% 
% Methods:
%	generate:	generate a stimulus
%	distractor:	generate a distractor stimulus
%	validate:	validate a set of parameter values
% 
% Properties:
%	param:	a property collection of parameters that the generator function will
%			use to generate the stimulus. includes:
%				x_type:	('random') (see stimulus.image.scribble)
%				y_type:	('random') (see stimulus.image.scribble)
%			<see also stimulus.image.scribble>
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
			function obj = cloud(varargin)
				obj = obj@stimulus.image.scribble();
				
				%set some parameter defaults
					add(obj.param,'x_type','generic',{'random'});
					add(obj.param,'y_type','generic',{'random'});
				
				%parse the inputs
					obj.parseInputs(varargin{:});
			end
		end
%/METHODS-----------------------------------------------------------------------

end
