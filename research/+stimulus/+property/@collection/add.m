function add(obj,strName,strType,cArg)
% stimulus.property.collection.add
% 
% Description:	add a property to the collection
% 
% Syntax: obj.add(strName,strType,cArg)
% 
% In:
%	strName	- the name of the property
%	strType	- a valid property type (e.g. 'explicit', 'range')
%	cArg	- a cell of values to pass as arguments to the property
%			  class constructor
% 
% Updated:	2015-09-29
% Copyright 2015 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
cArg	= ForceCell(cArg);

obj.prop.(strName)	= stimulus.property.(strType)(cArg{:});
