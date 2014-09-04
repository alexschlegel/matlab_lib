function sm = mtimes(sm1,sm2)
% mtimes
% 
% Description:	StringMath matrix multiplication function
% 
% Syntax:	sm = mtimes(x,y) OR
%			sm = x*y
% 
% In:
%	x/y	- an array of StringMath objects, numeric strings, or numbers
% 
% Updated:	2009-05-29
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

%fix the input
	[sm1,sm2,bEmptyInput]	= p_FixInputNoResize(sm1,sm2);
	
	if bEmptyInput
		sm	= [];
		return;
	end
	
%make sure we have the right dimensions
	%do array multiplication if one of the inputs is scalar
		n1	= numel(sm1);
		n2	= numel(sm2);
		if n1==1 || n2==1
			sm	= sm1.*sm2;
			return;
		end
	
	%make sure we have 2D matrices
		s1	= size(sm1);
		s2	= size(sm2);
		nd1	= numel(s1);
		nd2	= numel(s2);
		if nd1~=2 || nd2~=2
			error('Input arguments must be 2-D.');
		end
	
	%make sure inner dimensions are the same
		if s1(2)~=s2(1)
			error('Inner matrix dimensions must agree.');
		end

%initialize the output
	sm	= p_TransferProperties(sm1,StringMath);
	sm	= repmat(sm,[s1(1) s2(2)]);

%multiply!
	for r=1:s1(1)
		for c=1:s2(2)
			sm(r,c)	= sum(sm1(r,:).*sm2(:,c)');
		end
	end
	