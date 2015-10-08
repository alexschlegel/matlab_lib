function b = test_exclude(obj,value)
% stimulus.property.range.test_exclude
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
if ~isempty(obj.exclude)
	b	= ~any(ismember(value(:),obj.exclude));
else
	b	= true;
end
