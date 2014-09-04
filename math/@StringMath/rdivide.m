function sm = rdivide(sm1,sm2)
% rdivide
% 
% Description:	StringMath array division function
% 
% Syntax:	sm = rdivide(x,y) OR
%			sm = x./y
% 
% In:
%	x/y	- an array of StringMath objects, numeric strings, or numbers
% 
% Updated:	2009-05-30
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

%fix the input
	[sm1,sm2,bEmptyInput]	= p_FixInput(sm1,sm2);
	n						= numel(sm1);
	
	if bEmptyInput
		sm	= [];
		return;
	end

persistent sm0 sm10;
if isempty(sm0) || ~p_EqualProperties(sm0,sm1)
	[sm0,sm10]	= p_TransferProperties(sm1,StringMath('0'),StringMath('10'));
end

%check for errors
	if any(sm2(:)==sm0)
		error('Divide by zero.');
	end

%make everything positive
	sgn1	= [sm1.sign];
	sgn2	= [sm2.sign];
	
	[sm1.sign]	= deal(1);
	[sm2.sign]	= deal(1);
	
%initialize
	sm	= p_TransferProperties(sm1,StringMath);
	sm	= repmat(sm,size(sm1));

%divide!
	for k=1:n
		%get the integer part
			[sm(k),sm1(k)]	= GetQuotient(sm1(k),sm2(k),true);
			
		%get the decimal part
			sm(k).dec	= zeros(1,sm.precision,'int8');
			for kDigit=1:sm.precision
				if sm1(k)==sm0
					break;
				end
				
				%get the next digit
					[sm(k).dec(kDigit),sm1(k)]	= GetQuotient(sm1(k).*sm10,sm2(k),false);
			end
			
		%get rid of extra zeros in the decimal
			sm(k)	= p_Fix(sm(k));
	end

%fix the signs
	sgn			= num2cell(sgn1.*sgn2);
	[sm.sign]	= deal(sgn{:});

%------------------------------------------------------------------------------%
function [q,a] = GetQuotient(a,b,bStringMath)
	persistent sm0 sm1;
	
	if bStringMath
		if isempty(sm0) || ~p_EqualProperties(sm0,a)
			[sm0,sm1]	= p_TransferProperties(a,StringMath('0'),StringMath('1'));
		end
		
		q	= p_TransferProperties(a,sm0);
		v1	= sm1;
	else
		q	= 0;
		v1	= 1;
	end
	
	while a>=b
		a	= a - b;
		q	= q + v1;
	end
%------------------------------------------------------------------------------%
