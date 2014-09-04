function p = package(x)
% package
% 
% Description:	get the name of the package to which x belongs
% 
% Syntax:	p = package(x)
% 
% Updated: 2011-12-25
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
p	= ClassSplit(x);
