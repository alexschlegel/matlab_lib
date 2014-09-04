function str = call(f,arg,varargin)
% serialize.call
% 
% Description:	serialize a function call
% 
% Syntax:	str = serialize.call(f,arg,<options>)
% 
% In:
% 	f	- the function name
%	art	- a cell of arguments
% 
% Updated: 2014-01-31
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
arg	= cellfun(@(x) serialize.to(x,varargin{:}),arg,'uni',false);

str	= [f '(' join(arg,',') ')'];
