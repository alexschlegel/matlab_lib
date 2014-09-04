function [x,msd] = sigfig(x,n)
% sigfig
% 
% Description:	round x to n significant figures
% 
% Syntax:	[x,msd] = sigfig(x,n)
%
% Out:
%	x	- x rounded
%	msd	- the most significant digit of each element of x
% 
% Updated: 2012-10-30
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
bNZ	= x~=0;

msd			= zeros(size(x));
msd(bNZ)	= floor(log10(abs(x(bNZ))));

if n>0
	bNZ	= x~=0;
	
	x(bNZ)		= roundn(x(bNZ),msd(bNZ)-n+1);
else
	x(:)	= 0;
end
