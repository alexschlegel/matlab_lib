function sprev = rng2(varargin)
% rng2
% 
% Description:	modification of rng
% 
% Syntax:	sprev = rng2([seed]=randseed2,[generator]='twister')
%
% In:
%	seed		- the seed to use, or false to not call rng
%	generator	- see rng
% 
% Updated: 2015-09-22
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%parse the inputs
	[seed,generator]	= ParseArgs(varargin,[],'twister');
	
	if isempty(seed)
		seed	= randseed2;
	end

%seed the random number generator
	if notfalse(seed)
		rng(seed,generator);
	end
