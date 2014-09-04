function [b,t] = Send(tr,strName)
% PTB.Trigger.Send
% 
% Description:	send a named trigger code
% 
% Syntax:	[b,t] = tr.Send(strName,<options>)
% 
% In:
% 	strName	- the name of the trigger code
% 
% Out:
%	b	- true if the trigger was successfully sent
%	t	- the time the trigger was sent
% 
% Updated: 2012-03-28
% Copyright 2012 Scottie Alexander (scottiealexander11@gmail.com).  This 
% work is licensed under a Creative Commons Attribution-NonCommercial-
% ShareAlike 3.0 Unported License
global PTBIFO

% get the trigger info
	sTrigger = PTBIFO.(tr.type);

if ispc
	warning('Trigger object is not yet implemented in Windows.');
else
	if sTrigger.send
		% send trigger
			[bTrigger,t]	= settrigger(sTrigger.address,tr.Get(strName));
		
		% wait
			WaitSecs(1/sTrigger.daq_rate);
		
		% send blank
			bBlank = settrigger(sTrigger.address,[]);               
		
		b	= bBlank && bTrigger;
	else
		t	= PTB.Now;
		b	= true;
	end
	
	% add to the log
		if sTrigger.log
			tr.AddLog(strName);
		end
end
