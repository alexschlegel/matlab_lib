function sm1 = minus(sm1,sm2)
% minus
% 
% Description:	subtract the values of one StringMath object from another
% 
% Syntax:	sm = minus(x,y) OR
%			sm = x - y
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
	
%only handle positive numbers where sm1>=sm2
	sgn1	= [sm1.sign];
	sgn2	= [sm2.sign];
	
	kPP		= find(sgn1==1 & sgn2==1);
	kPPG	= find(sm1(kPP)>=sm2(kPP));
	kPPG	= kPP(kPPG);
	kPPL	= setdiff(kPP,kPPG);
	
	kPN		= find(sgn1==1 & sgn2==-1);
	kNP		= find(sgn1==-1 & sgn2==1);
	kNN		= find(sgn1==-1 & sgn2==-1);
	
	if numel(kPPL)	sm1(kPPL)	= -(sm2(kPPL) - sm1(kPPL));	end
	if numel(kPN)	sm1(kPN)		= sm1(kPN) + -sm2(kPN);		end
	if numel(kNP)	sm1(kNP)		= -(-sm1(kNP) + sm2(kNP));	end
	if numel(kNN)	sm1(kNN)		= -sm2(kNN) - -sm1(kNN);	end
	
%subtract!
	for k=kPPG
		%decimal part
			[sm1(k).dec,bSubInt]	= SubtractDecimal(sm1(k).dec,sm2(k).dec);
		
		%subtract 1 from integer if necessary
			if bSubInt
				sm1(k).int(1)	= sm1(k).int(1) - 1;
			end
		
		%integer part
			sm1(k).int	= SubtractInteger(sm1(k).int,sm2(k).int);
			
		%fix
			sm1(k)	= p_Fix(sm1(k));
	end

%------------------------------------------------------------------------------%
function [aDec,bSubInt] = SubtractDecimal(aDec1,aDec2)
	%pad first
		n1		= numel(aDec1);
		n2		= numel(aDec2);
		nMax	= max(n1,n2);
		
		aDec1(n1+1:nMax)	= 0;
		aDec2(n2+1:nMax)	= 0;
	%now subtract corresponding places
		aDec	= aDec1 - aDec2;
	%carry over
		bCarry	= aDec<0;
		while any(bCarry(2:end))
			kCarry	= find(bCarry(2:end))+1;
			
			aDec(kCarry)	= aDec(kCarry) + 10;
			aDec(kCarry-1)	= aDec(kCarry-1) - 1;
			
			bCarry	= aDec<0;
		end
	%did we spill over to the integers?
		bSubInt	= numel(aDec)>0 && aDec(1)<0;
		if bSubInt
			aDec(1)	= aDec(1)+10;
		end
%------------------------------------------------------------------------------%
function aInt = SubtractInteger(aInt1,aInt2)
	%pad first
		n1		= numel(aInt1);
		n2		= numel(aInt2);
		nMax	= max(n1,n2);
		
		aInt1(n1+1:nMax)	= 0;
		aInt2(n2+1:nMax)	= 0;
	%now subtract corresponding places
		aInt	= aInt1 - aInt2;
	%carry over
		bCarry	= aInt<0;
		while any(bCarry(1:nMax-1))
			kCarry	= find(bCarry(1:nMax-1));
			
			aInt(kCarry)	= aInt(kCarry) + 10;
			aInt(kCarry+1)	= aInt(kCarry+1) - 1;
			
			bCarry	= aInt<0;
		end
%------------------------------------------------------------------------------%
