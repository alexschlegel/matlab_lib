function t = session2time(strSession)
% sesssion2time
% 
% Description:	determine the time of a session from its name, in ms since the
%				epoch
% 
% Syntax:	t = session2time(strSession)
% 
% In:
% 	strSession	- the session name, as ddmmmyyii (e.g. 11oct81as)
% 
% Out:
% 	t	- the session time, in ms since the epoch (assumning a 12:00 session)
% 
% Updated: 2010-04-13
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
t	= FormatTime([strSession(1:7) ' 12:00']);
