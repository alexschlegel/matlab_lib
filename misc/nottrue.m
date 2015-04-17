function b = nottrue(x)
% nottrue
% 
% Description:	return true if x is not the logical scalar value true
% 
% Syntax:	b = nottrue(x)
% 
% Updated: 2015-04-16
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
b	= ~isa(x,'logical') || ~isscalar(x) || ~isequal(x,true);
