function b = nanlogical(x)
% nanlogical
% 
% Description:	convert x to a logical array (NaNs -> 0)
% 
% Syntax:	b = nanlogical(x)
% 
% Updated: 2011-02-11
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
x(isnan(x))	= 0;
b			= logical(x);
