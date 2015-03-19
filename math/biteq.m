function b = biteq(x,y)
% biteq
% 
% Description:	check whether two bit arrays are equal
% 
% Syntax:	b = biteq(x,y)
% 
% Updated: 2015-03-19
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
x	= unless(x(1:find(x,1,'last')),0);
y	= unless(y(1:find(y,1,'last')),0);
b	= all(x==y);
