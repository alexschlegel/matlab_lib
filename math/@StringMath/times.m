function sm1 = times(sm1,sm2)
% times
% 
% Description:	StringMath array multiplication function
% 
% Syntax:	sm = times(x,y) OR
%			sm = x.*y
% 
% In:
%	x/y	- an array of StringMath objects, numeric strings, or numbers
% 
% Updated:	2009-05-29
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

%fix the input
	[sm1,sm2,bEmptyInput]	= p_FixInput(sm1,sm2);
	n						= numel(sm1);
	
	if bEmptyInput
		sm	= [];
		return;
	end

%multiply!
	for k=1:n
		%get some info
			ni1	= numel(sm1(k).int);
			ni2	= numel(sm2(k).int);
			nd1	= numel(sm1(k).dec);
			nd2	= numel(sm2(k).dec);
			
		%number of digits past the decimals
			nDec	= nd1 + nd2;
			
		%combine the arrays, least significant first
			a1	= double([sm1(k).dec(end:-1:1) sm1(k).int]);
			a2	= double([sm2(k).dec(end:-1:1) sm2(k).int]);
			
		%engage multiplication
			a	= zeros(1,0);
			for kDigit=1:ni2+nd2
				%multiply
					aCur	= a1 * a2(kDigit);
				%carry over
					aCur	= CarryOver(aCur);
				%multiply by correct power of 10
					aCur	= [zeros(1,kDigit-1) aCur];
				%add to the sum
					a	= AddToSum(a,aCur);
			end	
		%construct the new StringMath object
			sm1(k).int	= int8(a(nDec+1:end));
			sm1(k).dec	= int8(a(nDec:-1:1));
			sm1(k).sign	= sm1(k).sign*sm2(k).sign;
			sm1(k)		= p_Fix(sm1(k));
	end

%------------------------------------------------------------------------------%
function a = CarryOver(a)
	bCarry	= a>=10;
	while any(bCarry(1:end-1))
		kCarry	= find(bCarry(1:end-1));
		
		nCarry		= floor(a(kCarry)/10);
		a(kCarry)	= a(kCarry) - nCarry*10;
		a(kCarry+1)	= a(kCarry+1) + nCarry;
		
		bCarry	= a>=10;
	end
	%add places to the end if necessary
		if a(end)>=10
			aAdd	= double(p_Number2IntDec(a(end)));
			a		= [a(1:end-1) aAdd];
		end
%------------------------------------------------------------------------------%
function a = AddToSum(a,b)
	nA	= numel(a);
	nB	= numel(b);
	
	if nA>nB
		a(1:nB)	= a(1:nB) + b(1:nB);
	else
		b(1:nA)	= b(1:nA) + a(1:nA);
		a		= b;
	end
	
	a	= CarryOver(a);
%------------------------------------------------------------------------------%
