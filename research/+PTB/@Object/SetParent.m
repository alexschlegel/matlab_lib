function SetParent(obj,par)
% PTB.Object.SetParent
% 
% Description:	set the parent object of a PTB.Object
% 
% Syntax:	obj.SetParent(par)
% 
% Updated: 2012-03-27
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%set the object's parent
	obj.parent	= par;
%set the object's children's parent
	cProp	= setdiff(fieldnames(obj),'parent');
	cSet	= cProp(cellfun(@(x) isa(obj.(x),'PTB.Object'),cProp));
	
	cellfun(@(x) obj.(x).SetParent(par),cSet);
	cellfun(@(x) x.SetParent(par),obj.children);
