function [aInt,aDec,sgn] = p_Number2IntDec(n)
% p_Number2IntDec
% 
% Description:	convert a a numeric value to arrays representing the integer and
%				decimal parts of the number
% 
% Syntax:	[aInt,aDec,sgn] = p_Number2IntDec(n)
% 
% In:
% 	n	- a numeric value
% 
% Out:
% 	aInt	- the integer part of the number (e.g. abc => [c b a])
%	aDec	- the decimal part of the number (e.g. 0.abc => [a b c])
%	sgn		- the sign of the number
%
% Note:	this isn't necessarily exact with decimals
% 
% Example:	[i,d] = p_Number2IntDec(123.456) =>
%				i==[3 2 1]
%				d==[4 5 6]
% 
% Updated:	2009-05-28
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

str				= num2str(n,'%0.10000f');
[aInt,aDec,sgn]	= p_String2IntDec(str);
