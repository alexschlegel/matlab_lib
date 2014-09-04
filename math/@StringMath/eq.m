function b = eq(sm1,sm2)
% eq
% 
% Description:	StringMath eq function
% 
% Syntax:	b = eq(x,y) OR
%			x==y
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

b	= false(size(sm1));
n	= numel(sm1);
for k=1:n
	if sm1(k).sign==sm2(k).sign
		ni1	= numel(sm1(k).int);
		ni2	= numel(sm2(k).int);
		
		if ni1==ni2 && all(sm1(k).int==sm2(k).int)
			nd1	= numel(sm1(k).dec);
			nd2	= numel(sm2(k).dec);
			
			if nd1==nd2 && all(sm1(k).dec==sm2(k).dec)
				b(k)	= true;
			end
		end
	end
end
