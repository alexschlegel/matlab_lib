function [aInt,aDec,sgn] = p_String2IntDec(str)
% p_String2IntDec
% 
% Description:	convert a string representation of a number to arrays
%				representing the integer and decimal parts of the number
% 
% Syntax:	[aInt,aDec,sgn] = p_String2IntDec(str)
% 
% In:
% 	str	- a string representing a number
% 
% Out:
% 	aInt	- the integer part of the number (e.g. abc => [c b a])
%	aDec	- the decimal part of the number (e.g. 0.abc => [a b c])
%	sgn		- 1 if str is positive or 0, -1 otherwise
% 
% Example:	[i,d] = p_String2IntDec('123.456') =>
%				i==[3 2 1]
%				d==[4 5 6]
% 
% Assumptions:	assumes str is well-formed
%
% Updated:	2009-05-28
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

if isempty(str)
	aInt	= int8([]);
	aDec	= int8([]);
	sgn		= 1;
	
	return;
end

%get the sign of the number
	if str(1)==45
		sgn	= -1;
		str	= str(2:end);
	else
		sgn	= 1;
	end
%find the decimal point, if any
	kDecimal	= find(str==46);
%convert to int8
	str	= int8(reshape(str,1,[]));
%convert from ascii to number
	str	= str - 48;
%separate
	if ~isempty(kDecimal)
		aInt	= str(kDecimal-1:-1:1);
		aDec	= str(kDecimal+1:end);
	else
		aInt	= str(end:-1:1);
		aDec	= int8([]);
	end
	