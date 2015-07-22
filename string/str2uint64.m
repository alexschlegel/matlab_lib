function x = str2uint64(str)
% str2uint64
% 
% Description:	convert a string representation of an integer to a uint64
% 
% Syntax:	x = str2uint64(str)
% 
% Updated: 2015-07-01
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
x	= eval(sprintf('uint64(%s)',str));
