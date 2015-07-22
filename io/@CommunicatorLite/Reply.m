function Reply(com,msg,byte)
% Communicator.Reply
% 
% Description:	reply to a message
% 
% Syntax:	com.Reply(msg,byte)
% 
% In:
% 	msg		- the message to which to reply
%	byte	- the reply byte
% 
% Updated: 2015-06-09
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
msg.message	= byte;

com.WriteMessage(msg);
