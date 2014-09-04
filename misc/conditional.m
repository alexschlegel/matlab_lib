function z = conditional(b,x,y)
% conditional
% 
% Description:	return one of two values based on a boolean value
% 
% Syntax:	z = conditional(b,x,y)
% 
% In:
% 	b	- an array of boolean values
%	x	- an array of values to return where b==true
%	y	- an array of values to return where b==false
% 
% Out:
% 	z	- see input
% 
% Updated: 2011-02-27
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
if numel(b)==1
	if b
		z	= x;
	else
		z	= y;
	end
else
	if iscell(x) & ~iscell(y)
		y	= num2cell(y);
	elseif iscell(y) & ~iscell(x)
		x	= num2cell(x);
	end

	[b,x,y]	= FillSingletonArrays(b,x,y);
	
	z		= y;
	z(b)	= x(b);
end
