function sm = power(sm1,sm2)
% times
% 
% Description:	StringMath array exponentiation function
% 
% Syntax:	sm = power(x,y) OR
%			sm = x.*y
% 
% In:
%	x/y	- an array of StringMath objects, numeric strings, or numbers
% 
% Updated:	2009-05-30
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

persistent sm01;
if isempty(sm01) || ~p_EqualProperties(sm01,sm1)
	sm01	= p_TransferProperties(sm1,StringMath('1'));
end

%fix the input
	[sm1,sm2,bEmptyInput]	= p_FixInput(sm1,sm2);
	n						= numel(sm1);
	
	if bEmptyInput
		sm	= [];
		return;
	end

%initialize
	sm	= sm1;

%power!
	for k=1:n
		if isint(sm2(k))
			while sm2(k)>1
				sm	= sm.*sm1;
				sm2	= sm2 - sm01;
			end
		else
			error('Exponentiation for non-integers is not implemented.');
		end	
	end
