function b = isnumstr(x)
% isnumstr
%
% Description:	returns true if x is a string representing a number
%
% Syntax:	b = isnumstr(x)
%
% In:
%	x	- an array
%
% Out:
%	b	- true if x is a string representing a number, false otherwise
%
% Updated: 2014-02-20
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
b	= ischar(x) & (~isnan(str2double(x)) | strcmp(lower(x),'nan'));
