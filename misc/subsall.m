function cSub = subsall(x)
% subsall
% 
% Description:	construct a cell that can be used to retrieve all elements of
%				a multidimensional array
% 
% Syntax:	cSub = subsall(x)
% 
% Updated: 2014-03-03
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
sz		= size(x);
nd		= numel(sz);
cSub	= repmat({':'},[nd 1]);
