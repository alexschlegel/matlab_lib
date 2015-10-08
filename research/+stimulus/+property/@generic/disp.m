function disp(obj)
% stimulus.property.generic.disp
% 
% Description:	display the property value
% 
% Syntax: disp(obj)
% 
% Updated:	2015-09-29
% Copyright 2015 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
if isa(obj.value,'function_handle')
	disp(sprintf('(function) %s',func2str(obj.value)));
else
	disp(obj.value);
end
