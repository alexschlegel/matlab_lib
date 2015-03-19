function b = bitlt(x,y)
% bitlt
% 
% Description:	check whether bit array x represents a number less than that
%				represented by bit array y
% 
% Syntax:	b = bitlt(x,y)
% 
% Updated: 2015-03-19
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
b	= ~bitgt(x,y) && ~biteq(x,y);
