function RemoveChild(obj,child)
% PTB.Object.RemoveChild
% 
% Description:	remove a child PTB.Object
% 
% Syntax:	obj.RemoveChild(child)
% 
% Updated: 2012-03-27
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
kChild	= FindCell(obj.children,child);

if ~isempty(kChild)
	obj.children(kChild)	= [];
end
