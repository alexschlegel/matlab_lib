function str = function_handle(x,varargin)
% serialize.function_handle
% 
% Description:	serialize a function handle
% 
% Syntax:	str = serialize.function_handle(x,<options>)
% 
% Updated: 2014-01-31
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
str	= func2str(x);

if str(1)~='@'
	str	= ['@' str];
end
