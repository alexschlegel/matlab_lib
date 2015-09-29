function [opt,ifo] = common_pre(vargin,varargin)
% stimulus.image.common_pre
% 
% Description:	common preparation steps for stimulus image functions
% 
% Syntax:	[opt,ifo] = stimulus.image.common_pre(vargin,<options>...)
% 
% In:
%	vargin			- the varargin input to the stimulus function
%	<options>...	- the key/value option defaults
%
% Out:
%	opt	- the options struct
%	ifo	- the start of the info struct
% 
% Updated: 2015-09-24
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%parse the inputs
	cDefault	= stimulus.image.common_defaults;
	vOpt		= optadd(varargin,cDefault{:});
	
	opt	= ParseArgs(vargin,vOpt{:});

%seed the random number generator
	rng2(opt.seed);

%info struct
	ifo	= struct;
