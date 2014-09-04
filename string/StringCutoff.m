function str = StringCutoff(str,n,varargin)
% StringCutoff
% 
% Description:	cutoff a string to make it the specified length
% 
% Syntax:	str = StringCutoff(str,n,[strEnd]='right')
% 
% In:
% 	str			- a string
% 	n			- the maximum size of the string (including ellipses)
% 	[strEnd]	- the end from which to cut.  either 'left' or 'right'
% 
% Out:
% 	str	- the shortened string
% 
% Updated:	2009-08-25
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
strEnd	= ParseArgs(varargin,'right');

nStr	= numel(str);
if nStr>n-3
	switch lower(strEnd)
		case 'left'
			str	= ['...' right(str,n-3)];
		case 'right'
			str	= [left(str,n-3) '...'];
		otherwise
			error(['"' strEnd '" is not a valid end specification.']);
	end
end