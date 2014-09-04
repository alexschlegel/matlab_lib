function b = IsBetween(x,xMin,xMax,varargin)
% IsBetween
% 
% Description:	tests whether x is between xMin and xMax
% 
% Syntax:	b = IsBetween(x,xMin,xMax,[bIncMin]=true,[bIncMax]=true)
% 
% In:
% 	x			- an array of numbers
%	xMin		- an array of minimum bounds
%	xMax		- an array of maximum bounds
%	[bIncMin]	- true to do an inclusive test on the minimum
%	[bIncMax]	- true to do an inclusive test on the maximum
% 
% Out:
% 	b	- a logical array of the result of the test xMin<[=]x<[=]xMax
% 
% Updated:	2009-05-19
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
[bIncMin,bIncMax]	= ParseArgs(varargin,true,true);

%test the minimum bound
	if bIncMin
		b	= x >= xMin;
	else
		b	= x > xMin;
	end
	
%test the maximum bound
	if numel(xMax)==1
		if bIncMax
			b(b)	= x(b) <= xMax;
		else
			b(b)	= x(b) < xMax;
		end
	else
		if bIncMax
			b(b)	= x(b) <= xMax(b);
		else
			b(b)	= x(b) < xMax(b);
		end
	end
