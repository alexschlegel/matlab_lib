function b = test_exclude(obj,value)
% stimulus.property.generic.test_exclude
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
	switch class(obj.exclude)
		case 'cell'
			b	= ~IsMemberCell({value},obj.exclude);
		otherwise
			if isscalar(value) && isnumeric(obj.exclude)
				b	= ~any(value==obj.exclude);
			elseif ischar(value) && ischar(obj.exclude)
				b	= ~strcmp(value,obj.exclude);
			else
				b	= ~isequal(value,obj.exclude);
			end
	end
else
	b	= true;
end
