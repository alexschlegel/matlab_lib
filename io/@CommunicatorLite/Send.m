function reply = Send(com,byte)
% CommunicatorLite.Send
% 
% Description:	send a byte to the other party
% 
% Syntax:	reply = com.Send(byte)
% 
% Out:
% 	reply	- the reply from the other party
% 
% Updated: 2015-06-09
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%construct the message
	id	= com.AssignMessageID(true);
	msg	= struct('id',id,'message',byte);
%send it
	com.WriteMessage(msg);
%wait for a reply
	reply	= com.WaitForReply(id);
