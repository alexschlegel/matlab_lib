function  b = gteSym(x,y)
% GTESYM
%
% Description:	greater than or equal function for symbolic variables
%
% Syntax:	b = gteSym(x,y)
%
% In:
%	x	- a symbolic variable
%	y	- a symbolic variable
%
% Out:
%	b	- true if x>=y, false otherwise
%
% Copyright 2006 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
if isa(x,'sym') || isa(y,'sym')
	x	= x - y;
	b	= double(x)>=0;
else
	b	= x>=y;
end	
