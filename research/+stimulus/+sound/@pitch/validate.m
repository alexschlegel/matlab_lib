function param = validate(obj,param)
% stimulus.sound.pitch.validate
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
	param	= validate@stimulus.sound.base(obj,param);

%number of pitches
	assert(isscalar(param.n) && isint(param.n) && param.n>0,'n must be a positive integer scalar');

%instrument
	try
		param.fInstrument	= str2func(param.instrument);
	catch me
		error('invalid instrument');
	end
	
	nArg	= nargin(param.fInstrument);
	assert(nArg~=0,'the instrument function must take at least one input argument');

%frequency range
	assert(isscalar(param.fmin) && param.fmin>0,'fmin must be a postive scalar');
	assert(isscalar(param.fmax) && param.fmax>0,'fmax must be a postive scalar');

%frequencies
	param.f	= reshape(param.f,[],1);
	
	assert(isnumeric(param.f) && all(param.f>0),'the array of pitch frequencies must be an array of positive values');

