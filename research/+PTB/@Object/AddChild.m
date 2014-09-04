function AddChild(obj,child)
% PTB.Object.AddChild
% 
% Description:	add a child PTB.Object
% 
% Syntax:	obj.AddChild(child)
% 
% Updated: 2012-03-27
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
obj.children{end+1}	= child;
