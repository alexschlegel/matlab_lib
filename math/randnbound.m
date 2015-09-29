function x = randnbound(n,b,varargin)
% randnbound
% 
% Description:	generate a bounded, "normal"-like distribution of random numbers
% 
% Syntax:	x = randnbound(n,b,<options>)
% 
% In:
% 	n		- the number of random numbers to generate
%	b		- the maximum possible magnitude of values to return
%	<options>:
%		sd:	(3) the standard deviation at which to cut off the normal
%			distribution
% 
% Out:
% 	x	- the array of constrained random values
% 
% Updated: 2015-09-22
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%parse the inputs
	opt	= ParseArgs(varargin,...
			'sd'	, 3		, ...
			'seed'	, []	  ...
			);

%seed the random number generator
	rng2(opt.seed);

%construct the probability distribution function, a normal PDF that goes to 0
%some number of standard deviations out and is multiplied by a constant so that
%the cumulative distribution==1
	Nsd	= normpdf(opt.sd);
	C	= 1/(normcdf(opt.sd)-normcdf(-opt.sd)-2*opt.sd*Nsd);
	
	PDF	= @(x) max(0,C*(normpdf(x) - Nsd));

%generate random numbers from the PDF
	init	= randBetween(-opt.sd,opt.sd,'seed',false);
	x		= b./opt.sd.*slicesample(init,n,'pdf',PDF);
