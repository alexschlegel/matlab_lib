function r = randBetween(r1,r2,varargin)
% randBetween
% 
% Description:	choose random numbers between two values
% 
% Syntax:	r = randBetween(r1,r2,<size>,<options>)
% 
% In:
% 	r1			- lower bound
%	r2			- upper bound
%	<size>		- the size of the return matrix (same as for rand)
%	<options>:
%		seed:	(randseed2) the seed to use for randomizing, or false to skip
%				seeding the random number generator
% 
% Out:
% 	r	- a matrix of random numbers between r1 and r2
% 
% Updated: 2015-09-22
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%parse the inputs
	[sz,opt]	= ParseArgs(varargin,{},...
					'seed'	, []	  ...
					);
	
	sz	= ForceCell(sz);

%seed the random number generator
	rng2(opt.seed);

r	= rand(sz{:});
r	= r1 + r.*(r2-r1);
