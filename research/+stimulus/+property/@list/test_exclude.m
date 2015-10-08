function b = test_exclude(obj,value)
% stimulus.property.list.test_exclude
% 
% Description:	test whether a value passes the exclusion list
% 
% Syntax: b = obj.test_exclude(value)
%
% In:
%	value	- the value to test
%
% Out:
%	b	- true if the value is not in the exclusion list (i.e. it passes)
% 
% Updated:	2015-09-29
% Copyright 2015 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%the generation function takes care of checking
	b	= true;