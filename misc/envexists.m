function b = envexists(strEnv)
% envexists
% 
% Description:	return a boolean indicating if environment variable strEnv
%				exists
% 
% Syntax:	b = envexists(strEnv)
% 
% Updated:	2009-07-03
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
b	= ~isempty(getenv(strEnv));
