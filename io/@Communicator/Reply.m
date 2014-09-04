function Reply(com, msg, reply)
% Communicator.Reply
% 
% Description:	reply to a message
% 
% Syntax:	com.Reply(msg, reply)
% 
% In:
% 	msg		- the message to which to reply
%	reply	- the reply
% 
% Updated: 2014-01-30
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
com.L.Print(sprintf('sending reply to message %d',msg.id),'info');

com.WriteMessage(msg.type, reply, msg.id);
