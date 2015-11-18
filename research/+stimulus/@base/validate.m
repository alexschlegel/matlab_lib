function param = validate(obj,param)
% stimulus.base.validate
% 
% Description:	validate a set of parameter values
% 
% Syntax: param = obj.validate(param)
% 
% In:
%	param	- a struct of parameter values
%
% Out:
%	param	- the validated parameter struct
% 
% Updated:	2015-09-29
% Copyright 2015 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%d
	assert(isscalar(param.d),'d must be a scalar');
	assert(param.d>=0 && param.d<=1,'d must be between 0 and 1');

%seed
	assert(isscalar(param.seed),'seed parameter must be a scalar');
