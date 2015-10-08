function param = validate(obj,param)
% stimulus.sound.base.validate
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
% Updated:	2015-10-07
% Copyright 2015 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%validate superclass stuff
	param	= validate@stimulus.base(obj,param);

%sampling rate
	assert(isscalar(param.rate) && param.rate>0,'rate must be a non-negative scalar');

%duration
	assert(isscalar(param.dur) && param.dur>0,'duration must be a non-negative scalar');

