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
% Updated: 2015-06-09
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
id	= find(com.idInOccupied,1);

if ~isempty(id)
	msg	= com.PopMessageIn(id);
else
	msg	= [];
end
