function value = generate(obj)
% stimulus.property.generic.generate
% 
% Description:	generate a property value
% 
% Syntax: value = obj.generate()
% 
% Updated:	2015-09-29
% Copyright 2015 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
switch obj.valueType
	case obj.VALUE_EXPLICIT
		value	= obj.value;
	case obj.VALUE_FUNC_NOARG
		value	= obj.value();
	case obj.VALUE_FUNC_EXCLUDE
		value	= obj.value('exclude',obj.exclude);
end
