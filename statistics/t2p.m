function p = t2p(t,v,varargin)
% t2p
% 
% Description:	calculate p-values for the given t-statistics
% 
% Syntax:	p = t2p(t,v,[bTwoTail]=false)
% 
% In:
% 	t			- the t-statistics
%	v			- degrees of freedom for each t value
%	[bTwoTail]	- true to calculate two-tailed p-values
% 
% Out:
% 	p	- the probability that each t value would be obtained if the null
%		  hypothesis was true
% 
% Notes:	taken from built in corrcoef function
% 
% Updated: 2014-03-10
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
bTwoway	= ParseArgs(varargin,false);

p	= 1 - tcdf(t,v);

if bTwoway
	%negative values also count
		bRev	= t<0;
		p(bRev)	= 1-p(bRev);
	%twice as many random values pass the criterion
		p	= p*2;
end
