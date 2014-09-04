function XIDSend(s,strCommand)
% XIDSend
% 
% Description:	send a command over an XID connection
% 
% Syntax:	XIDSend(s,strCommand)
% 
% In:
% 	s			- the XID connection object
%	strCommand	- the command to send
% 
% Updated: 2010-06-23
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
fwrite(s,[strCommand char(13)]);
