function b = endswith(str,strEnd)
% endswith
% 
% Description:	test whether a string ends with another string
% 
% Syntax:	b = endswith(str,strEnd)
% 
% Updated: 2014-03-03
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
nStr	= numel(str);
nStrEnd	= numel(strEnd);

b	= isempty(strEnd) || (nStr>=nStrEnd && strcmp(str(end-nStrEnd+1:end),strEnd));
