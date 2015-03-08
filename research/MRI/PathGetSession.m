function strSession = PathGetSession(strPath)
% PathGetSession
% 
% Description:	find a session code in a file path
% 
% Syntax:	strSession = PathGetSession(strPath)
% 
% Updated: 2015-03-06
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%treat "o" as "0"
	reD	= '[\dOo]';

re	= [reD reD '[A-Za-z]{3}' reD reD '\w{2,3}'];
s	= regexp(strPath,re,'match');

if ~isempty(s)
	strSession	= s{1};
else
	strSession	= '';
end
