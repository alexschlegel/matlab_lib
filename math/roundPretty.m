function x = roundPretty(x)
% roundPretty
% 
% Description:	round the elements of x to use the least number of digits while
%				still remaining distinct
% 
% Syntax:	x = roundPretty(x)
% 
% Updated: 2010-12-03
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
s	= size(x);
n	= numel(x);

%find the minimum distance between elements of x
	xCompare	= repmat(reshape(x,[],1),[1 n]);
	xCompare	= abs(xCompare - xCompare');
	
	xCompare(xCompare==0)	= NaN;
	
	[dMin,kMin]	= nanmin(xCompare(:));
	%[xMin,yMin]	= ind2sub([n n],kMin);
%round to keep the most significant figure of the difference
	if xCompare~=0
		d	= floor(log10(dMin))-1;
		
		%see if we can round to one digit up
% 			[x(xMin) x(yMin)]
% 			if diff(roundn([x(xMin) x(yMin)],d+1))~=0
% 				d	= d+1;
% 			end
		
		x	= roundn(x,d);
	end
	