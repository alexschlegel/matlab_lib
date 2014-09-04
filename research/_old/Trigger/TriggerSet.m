function [sTrigger,t] = TriggerSet(sTrigger,v)
% TriggerSet
% 
% Description:	set I/O card bits to the specified value
% 
% Syntax:	[sTrigger,t] = TriggerSet(sTrigger,v)
% 
% In:
% 	sTrigger	- a trigger struct returned by TriggerPrepare
%	v			- the new value
% 
% Out:
% 	sTrigger	- the updated trigger struct
%	t			- an estimate of the true GetSecs value at which the I/O card
%				  set the specified bits on the last port
% 
% Updated: 2010-10-29
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
if ~isempty(sTrigger)
	if sTrigger.debug
		status(['Trigger set: ' num2str(v) ' (debug)']);
	end
	
	%get the new port states
		sTrigger.state	= reshape(int2bit(v,sTrigger.nbit-1),[],1);
		if sTrigger.bitreverse
			sTrigger.state	= sTrigger.state(end:-1:1);
		end
	%blank the ports first
		if sTrigger.blankfirst
			for kP=1:sTrigger.nport
				calllib('ACCES32','OutPortB',sTrigger.baseAddress+sTrigger.uport(kP)-1,0);
			end
			
			WaitSecs(1/sTrigger.fs);
		end
	%set the port values
		for kP=1:sTrigger.nport
			%bits controlled by the current port
				bPort	= sTrigger.port==sTrigger.uport(kP);
			%new port value
				vPort	= sum(bitset(0,sTrigger.bit(bPort),sTrigger.state(bPort)));
			
			tBefore	= GetSecs;
			calllib('ACCES32','OutPortB',sTrigger.baseAddress+sTrigger.uport(kP)-1,vPort);
			tAfter	= GetSecs;
		end
	%midway point between the two GetSecs calls (which is the bit set time assuming
	%GetSecs reports the time halfway into its call time and the bit is set half way
	%into its function execution time
		t	= (tBefore+tAfter)/2;
	%record the trigger information
		nStart		= numel(sTrigger.event.start);
		nDuration	= numel(sTrigger.event.duration);
		
		%record the duration of the last event
			if nStart>0 && nStart~=nDuration
				sTrigger.event.duration(end+1)	= t - sTrigger.event.start(end);
			end
		%record info about non-zero events
			if v~=0
				sTrigger.event.type(end+1)	= v;
				sTrigger.event.start(end+1)	= t;
			end
else
	t	= GetSecs;
end
