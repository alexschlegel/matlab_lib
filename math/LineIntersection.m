function [x,y] = LineIntersection(m1,b1,m2,b2)
% LineIntersection
% 
% Description:	calculate the point of intersection between two lines.  NOTE:
%				if a line's slope is infinite then the corresponding b is
%				treated as the x-intercept
% 
% Syntax:	[x,y] = LineIntersection(m1,b1,m2,b2)
% 
% In:
% 	m1	- the slope of the first line (or an array of first line slopes)
%	b1	- the y-intercept(s) of the first line
%	m2	- the slope(s) of the second line
%	b2	- the y-intercept(s) of the second line
% 
% Out:
% 	x	- the x value(s) of the point of intercept
%	y	- the y value(s) of the point of intercept
% 
% Updated: 2011-03-04
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
[x,y]	= deal(NaN(size(m1)));

bf1	= ~isinf(m1);
bf2	= ~isinf(m2);
bf	= bf1 & bf2;
bi1	= bf2 & ~bf;
bi2	= bf1 & ~bf;

%both finite
	x(bf)	= (b1(bf)-b2(bf))./(m1(bf)-m2(bf));
	y(bf)	= (m1(bf).*b2(bf)-m2(bf).*b1(bf))./(m1(bf)-m2(bf));
%equation 1 infinite slope
	x(bi1)	= b1(bi1);
	y(bi1)	= b2(bi1) + m2(bi1).*x(bi1);
%equation 2 infinite slope
	x(bi2)	= b2(bi2);
	y(bi2)	= b1(bi2) + m1(bi2).*x(bi2);
