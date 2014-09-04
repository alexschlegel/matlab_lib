function reply = Send(com,msgType,msg)
% Communicator.Send
% 
% Description:	send a message to the other party
% 
% Syntax:	reply = com.Send(msgType,msg)
% 
% In:
% 	msgType	- the message type. must be an element of the msg argument passed
%			  during object creation
%	msg		- the message
% 
% Out:
% 	reply	- the reply from the other party
% 
% Updated: 2014-01-29
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
msgID	= com.WriteMessage(msgType, msg);
reply	= com.WaitReply(msgID);
