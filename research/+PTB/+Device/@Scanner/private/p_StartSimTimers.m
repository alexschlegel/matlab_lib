function p_StartSimTimers(scn)
% p_StartSimTimers
% 
% Description:	start the scanner stimulation timers
% 
% Syntax:	p_StartSimTimers(scn)
% 
% Updated: 2012-02-14
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
tr			= scn.parent.Info.Get('scanner',{'tr','per'});
nTR			= scn.parent.Info.Get('scanner',{'tr','total'});
nTRHeard	= scn.parent.Info.Get('scanner',{'tr','heard'});

set(scn.TSim,'TasksToExecute',nTR-nTRHeard,'Period',tr/1000);
scn.parent.Info.Set('scanner','last',false);

if ~IsTimerRunning(scn.TSim)
	start(scn.TSim);
end
if ~IsTimerRunning(scn.TKey)
	try
		if ~isempty(scn.parent.Input.Key)
		%the button box made a keyboard object
			start(scn.TKey);
		end
	catch me
	
	end
end
