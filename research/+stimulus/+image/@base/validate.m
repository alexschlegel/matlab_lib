function param = validate(obj,param)
% stimulus.image.base.validate
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

%validate superclass stuff
	validate@stimulus.base(obj,param);

%size
	assert(all(param.size>=0),'size must be non-negative');
	assert(all(isint(param.size)),'size must be an array of integers');

%colors
	param.foreground	= str2rgb(param.foreground);
	param.background	= str2rgb(param.background);

