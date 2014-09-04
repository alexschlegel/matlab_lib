function sm = StringMath(varargin)
% StringMath
%
% Description:	the StringMath constructor function.  a StringMath object
%				performs arithmetic on arbitrarily large numbers
%
% Syntax:	sm = StringMath([str/n]=0) OR
%			sm = StringMath(sm2)
%			sm = sm1 (+-*/^) sm2	- perform an arithmetic computation on two
%									  StringMath objects
%
% In:
%	str		- a string representing a number
%	n		- a numeric value
%	sm1/sm2	- a StringMath object
%
% Out:
%	sm	- the number as a StringMath object
%
% Updated:	2009-05-28
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
s	= ParseArgs(varargin,0);

switch class(s)
	case 'char'
		n	= 1;
		sz	= 1;
	otherwise
		n	= numel(s);
		sz	= size(s);
end

%initialize the instance
	sm.int	= int8([]);	%integer component
	sm.dec	= int8([]);	%decimal component
	sm.sign	= 1;		%sign of the number
	
	sm.precision	= 100;	%precision for inexact calculations
	
	sm		= class(sm,'StringMath');
	sm		= repmat(sm,sz);

for k=1:n
	switch class(s(k))
		case 'StringMath'
			sm(k)	= s(k);
		case 'char'
			[sm(k).int,sm(k).dec,sm(k).sign]	= p_String2IntDec(s);
		otherwise
			[sm(k).int,sm(k).dec,sm(k).sign]	= p_Number2IntDec(s(k));
	end
	
	%make sure it's well formatted
		sm(k)	= p_Fix(sm(k));
end
