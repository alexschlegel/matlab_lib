function t = nowunix()
% nowunix
%
% Description:	returns the current unix-style time
%
% Syntax:	t = nowunix
%
% Updated:	2010-04-13
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
t	= (nowms - unixepoch)/1000;
