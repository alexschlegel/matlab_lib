function param = validate(obj,param)
% stimulus.image.blob.validate
% 
% Description:	validate a set of parameter values for blob stimuli
% 
% Syntax: param = obj.validate(param)
% 
% In:
%	param	- a struct of parameter values
%
% Out:
%	param	- the validated parameter struct
% 
% Updated:	2015-09-30
% Copyright 2015 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%validate superclass stuff
	param	= validate@stimulus.image.base(obj,param);

%interpolation stuff
	param.interp		= CheckInput(param.interp,'interp',{'pchip','spline','linear'});
	param.interp_space	= CheckInput(param.interp_space,'interp_space',{'polar','cartesian'});
