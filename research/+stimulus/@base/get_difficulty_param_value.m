function x = get_difficulty_param_value(obj,d)
% stimulus.base.get_difficulty_param_value
% 
% Description:	get the value of the difficulty-linked parameter, given the
%				difficulty setting
% 
% Syntax: x = obj.get_difficulty_param_value(d)
% 
% In:
%	d	- the difficulty value (between 0 and 1)
% 
% Out:
%	x	- the value of the difficulty-linked parameter
% 
% Updated:	2015-11-17
% Copyright 2015 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
x	= MapValue(d,0,1,obj.difficulty_param_min,obj.difficulty_param_max);

if obj.difficulty_param_round
	x	= round(x);
end
