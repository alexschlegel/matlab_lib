function step_size = validate_step_size(obj,step_size)
% stimulus.image.scribble.validate_step_size
% 
% Description:	validate a step_size value
% 
% Syntax: step_size = obj.validate_step_size(step_size)
% 
% In:
%	step_size	- the step size value
%
% Out:
%	step_size	- the step size value
% 
% Updated:	2015-11-17
% Copyright 2015 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
assert(isscalar(step_size),'step_size must be scalar');
