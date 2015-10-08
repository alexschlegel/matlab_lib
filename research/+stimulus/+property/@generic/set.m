function obj = set(obj,value)
% stimulus.property.generic.set
% 
% Description:	set the value of the property
% 
% Syntax: obj = obj.set(value)
% 
% Updated:	2015-09-29
% Copyright 2015 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
obj	= stimulus.property.generic(value,'exclude',obj.exclude);
