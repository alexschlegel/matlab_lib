function [p,c] = ClassSplit(x)
% ClassSplit
% 
% Description:	split the class name of x into package and class
% 
% Syntax:	[p,c] = ClassSplit(x)
% 
% Updated: 2011-12-25
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
s	= regexp(class(x),'(?<package>^.*)\.(?<class>[^\.]+$)|(?<package>^)(?<class>.*)','names');
p	= s.package;
c	= s.class;
