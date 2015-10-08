function value = generate(obj)
% stimulus.property.list.generate
% 
% Description:	generate a property value from the specified list
% 
% Syntax: value = obj.generate()
% 
% Updated:	2015-09-29
% Copyright 2015 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
xValues	= obj.values;

value	= randFrom(xValues,obj.size,...
			'unique'	, false			, ...
			'exclude'	, obj.exclude	, ...
			'seed'		, false			  ...
			);

if iscell(xValues) && numel(value)==1
	value	= value{1};
end
