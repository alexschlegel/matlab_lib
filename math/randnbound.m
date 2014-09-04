function x = randnbound(n,b,varargin)
% randnbound
% 
% Description:	generate a bounded, "normal"-like distribution of random numbers
% 
% Syntax:	x = randnbound(n,b,[sd]=3)
% 
% In:
% 	n		- the number of random numbers to generate
%	b		- the maximum possible magnitude of values to return
%	[sd]	- the standard deviation at which to cut off the normal distribution
% 
% Out:
% 	x	- the array of constrained random values
% 
% Updated: 2013-05-16
% Copyright 2013 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
sd	= ParseArgs(varargin,3);

%construct the probability distribution function, a normal PDF that goes to 0
%some number of standard deviations out and is multiplied by a constant so that
%the cumulative distribution==1
	Nsd	= normpdf(sd);
	C	= 1/(normcdf(sd)-normcdf(-sd)-2*sd*Nsd);
	
	PDF	= @(x) max(0,C*(normpdf(x) - Nsd));
%generate random numbers from the PDF
	x	= b./sd.*slicesample(randBetween(-sd,sd),n,'pdf',PDF);
