function b = islower(chr)
% islower
% 
% Description:	return true if the first character of chr is lowercase
% 
% Updated: 2014-10-18
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
b	= numel(chr)>0 && chr(1)>='a' && chr(1)<='z';
