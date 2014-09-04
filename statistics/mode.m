function m = mode(x)
% mode
% 
% Description:	return the mode of the array x
% 
% Syntax:	m = mode(x)
% 
% In:
% 	x	- an array
% 
% Out:
% 	m	- the mode of all the values in x
% 
% Updated:	2011-04-19
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

x	= double(x(:));

%get the unique values in x
	uX	= unique(x);
	if numel(uX)==1
		m	= uX;
		return;
	end
	
%calculate a histogram of x
	n	= hist(x,uX);
	
%return the mode
	[mx,kMx]	= max(n);
	m			= uX(kMx);