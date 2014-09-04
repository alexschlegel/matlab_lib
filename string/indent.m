function str = indent(str,varargin)
% indent
% 
% Description:	indent each line in a string 
% 
% Syntax:	str = indent(str,[strIndent]=char(9))
% 
% In:
% 	str			- the string to indent
%	[strIndent]	- the indentation string
% 
% Out:
% 	str	- the indented string
% 
% Updated: 2012-12-27
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
strIndent	= ParseArgs(varargin,9);

str	= strrep(str,char([13 10]),char([13 10 strIndent]));
str	= strrep(str,char(10),char([10 strIndent]));

str	= [strIndent str];
