function c = StringCompare(str1,str2)
% StringCompare
% 
% Description:	compare the sort order of two strings
% 
% Syntax:	c = StringCompare(str1,str2)
% 
% In:
% 	str1	- a string
%	str2	- another string
% 
% Out:
% 	c	- -1 if str1<str2, 0 if str1==str2, 1 if str1>str2
% 
% Updated:	2009-05-26
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
	n1	= numel(str1);
	n2	= numel(str2);
	n	= min(n1,n2);
	
	if n==0
		if n1==0 && n2==0	%both strings are empty
			c	= 0;
		elseif n1==0		%str1 is empty
			c	= -1;
		else				%str2 is empty
			c	= 1;
		end
	else
		%get the first point at which the two differ
			k	= find(str1(1:n)~=str2(1:n),1,'first');
			
		if isempty(k)
			if n1==n2		%strings are the same
				c	= 0;
			elseif n1<n2	%str1 is shorter
				c	= -1;
			else			%str2 is shorter
				c	= 1;
			end
		else
			if str1(k)<str2(k)	%str1 comes first
				c	= -1;
			else				%str2 comes first
				c	= 1;
			end
		end
	end
%------------------------------------------------------------------------------%
