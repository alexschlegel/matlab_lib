function sm = mpower(sm1,sm2,varargin)
% mpower
% 
% Description:	StringMath matrix exponentiation function
% 
% Syntax:	sm = mpower(x,y,[nDigit]=10) OR
%			sm = x^y
% 
% In:
%	x/y			- a StringMath object, numeric string, or number
%	[nDigit]	- number of digits of precision required (only if y is not an
%				  integer)
% 
% Updated:	2009-05-29
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
nDigit	= ParseArgs(varargin,10);

persistent sm01;
if isempty(sm01) || ~p_EqualProperties(sm01,sm1)
	sm01	= p_TransferProperties(sm1,StringMath('1'));
end

%fix the input
	[sm1,sm2,bEmptyInput]	= p_FixInputNoResize(sm1,sm2);
	
	if bEmptyInput
		sm	= [];
		return;
	end

%make sure the sm1 is well-formed
	sz1	= size(sm1);
	nd1	= numel(sz1);
	
	if nd1>2
		error('Matrix must be MxN');
	end
	if sz1(1)~=sz1(2)
		error('Matrix must be square.');
	end
%make sure sm2 is well-formed
	n2	= numel(sm2);
	sz2	= size(sm2);
	nd2	= numel(sz2);
	
	if n2~=1 || ~isint(sm2)
		error(['Only multiplication by scalar integers is supported']);
	end
	
%power!
	sm	= sm1;
	
	while sm2>1
		sm	= sm*sm1;		
		sm2	= sm2 - sm01;
	end
	