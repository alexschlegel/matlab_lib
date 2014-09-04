function sm1 = plus(sm1,sm2)
% plus
% 
% Description:	add the values of two StringMath objects
% 
% Syntax:	sm = plus(x,y) OR
%			sm = x + y
% 
% In:
%	x/y	- an array of StringMath objects, numeric strings, or numbers
% 
% Updated:	2009-05-28
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

%fix the input
	[sm1,sm2,bEmptyInput]	= p_FixInput(sm1,sm2);
	n						= numel(sm1);
	
	if bEmptyInput
		sm	= [];
		return;
	end

%only handle positive numbers
	sgn1	= [sm1.sign];
	sgn2	= [sm2.sign];
	
	kPP	= find(sgn1==1 & sgn2==1);
	kPN	= find(sgn1==1 & sgn2==-1);
	kNP	= find(sgn1==-1 & sgn2==1);
	kNN	= find(sgn1==-1 & sgn2==-1);
	
	if numel(kPN)	sm1(kPN)	= sm1(kPN) - -sm2(kPN);		end
	if numel(kNP)	sm1(kNP)	= sm2(kNP) - -sm1(kNP);		end
	if numel(kNN)	sm1(kNN)	= -(-sm1(kNN) + -sm2(kNN));	end

%add!
	for k=kPP
		%decimal part
			[sm1(k).dec,bAddInt]	= AddDecimal(sm1(k).dec,sm2(k).dec);
		
		%add 1 to integer if necessary
			if bAddInt
				sm1(k).int(1)	= sm1(k).int(1) + 1;
			end
		
		%integer part
			sm1(k).int	= AddInteger(sm1(k).int,sm2(k).int);
			
		%fix
			sm1(k)	= p_Fix(sm1(k));
	end

%------------------------------------------------------------------------------%
function [aDec,bAddInt] = AddDecimal(aDec1,aDec2)
	%pad first
		n1		= numel(aDec1);
		n2		= numel(aDec2);
		nMax	= max(n1,n2);
		
		aDec1(n1+1:nMax)	= 0;
		aDec2(n2+1:nMax)	= 0;
	%now add corresponding places
		aDec	= aDec1 + aDec2;
	%carry over
		bCarry	= aDec>=10;
		while any(bCarry(2:end))
			kCarry	= find(bCarry(2:end))+1;
			
			aDec(kCarry)	= aDec(kCarry) - 10;
			aDec(kCarry-1)	= aDec(kCarry-1) + 1;
			
			bCarry	= aDec>=10;
		end
	%did we spill over to the integers?
		bAddInt	= numel(aDec)>0 && aDec(1)>=10;
		if bAddInt
			aDec(1)	= aDec(1)-10;
		end
%------------------------------------------------------------------------------%
function aInt = AddInteger(aInt1,aInt2)
	%pad first
		n1		= numel(aInt1);
		n2		= numel(aInt2);
		nMax	= max(n1,n2);
		
		aInt1(n1+1:nMax)	= 0;
		aInt2(n2+1:nMax)	= 0;
	%now add corresponding places
		aInt	= aInt1 + aInt2;
	%carry over
		bCarry	= aInt>=10;
		while any(bCarry(1:nMax-1))
			kCarry	= find(bCarry(1:nMax-1));
			
			aInt(kCarry)	= aInt(kCarry) - 10;
			aInt(kCarry+1)	= aInt(kCarry+1) + 1;
			
			bCarry	= aInt>=10;
		end
	%do we need a new place?
		if aInt(nMax)>=10
			aInt(nMax)	= aInt(nMax) - 10;
			aInt(nMax+1)	= 1;
		end
%------------------------------------------------------------------------------%
