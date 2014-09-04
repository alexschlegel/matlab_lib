function msg = CheckMessages(com)
% Communicator.CheckMessages
% 
% Description:	check to see whether any messages have been sent by the other
%				party
% 
% Syntax:	msg = com.CheckMessages()
% 
% Out:
% 	msg	- the first message on the stack
% 
% Updated: 2014-01-30
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
com.L.Print('checking messages','info');

msgIDs	= com.messages.domain;

if ~isempty(msgIDs)
	msg	= com.PopMessage(msgIDs{1});
else
	msg	= [];
end
