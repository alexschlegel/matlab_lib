function b = startswith(str,strStart)
% startswith
% 
% Description:	test whether a string starts with another string
% 
% Syntax:	b = startswith(str,strStart)
% 
% Updated: 2014-03-03
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
nStr		= numel(str);
nStrStart	= numel(strStart);

b	= isempty(strStart) || (nStr>=nStrStart && strcmp(str(1:nStrStart),strStart));
