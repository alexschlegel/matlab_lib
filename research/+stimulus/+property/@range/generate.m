function value = generate(obj)
% stimulus.property.range.generate
% 
% Description:	generate a property value within the specified range
% 
% Syntax: value = obj.generate()
% 
% Updated:	2015-09-29
% Copyright 2015 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
xBound	= obj.bound;

assert(isnumeric(xBound) && numel(xBound)==2,'bound must be a two-element numeric array');

value	= randBetween(xBound(1),xBound(2),obj.size,'seed',false);
