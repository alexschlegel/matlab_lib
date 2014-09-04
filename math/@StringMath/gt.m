function b = gt(sm1,sm2)
% gt
% 
% Description:	StringMath greater than function
% 
% Syntax:	b = gt(x,y) OR
%			b = x > y
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
		b	= [];
		return;
	end

%initialize
	b	= false(size(sm1));
	
%deal with the easy cases first
	sgn1	= [sm1.sign];
	sgn2	= [sm2.sign];
	
	kPP	= find(sgn1==1 & sgn2==1);
	kPN	= find(sgn1==1 & sgn2==-1);
	kNN	= find(sgn1==-1 & sgn2==-1);
	
	if numel(kPN)	b(kPN)	= true;						end
	if numel(kNN)	b(kNN)	= -sm2(kNN) > -sm1(kNN);	end

%greater than!
	for k=kPP
		switch GTTestInt(sm1(k).int,sm2(k).int)
			case 1
				b(k)	= true;
			case 0
				if GTTestDec(sm1(k).dec,sm2(k).dec)==1
					b(k)	= true;
				end
		end
	end

%------------------------------------------------------------------------------%
function b = GTTestInt(a1,a2)
	n1	= numel(a1);
	n2	= numel(a2);
	
	if n1>n2
		b	= 1;
	elseif n1<n2
		b	= -1;
	else
		k	= n1;
		while k>0
			if a1(k)>a2(k)
				b	= 1;
				return;
			elseif a1(k)<a2(k)
				b	= -1;
				return;
			end
			
			k	= k - 1;
		end
		
		b	= 0;
	end
%------------------------------------------------------------------------------%
function b = GTTestDec(a1,a2)
	n1	= numel(a1);
	n2	= numel(a2);
	n	= min(n1,n2);
	
	k	= 1;
	while k<=n
		if a1(k)>a2(k)
			b	= 1;
			return;
		elseif a1(k)<a2(k)
			b	= -1;
			return;
		end
		
		k	= k + 1;
	end
	
	if n1>n2
		b	= 1;
	elseif n1<n2
		b	= -1;
	else
		b	= 0;
	end
%------------------------------------------------------------------------------%
