function AutoSave(ifo,tInterval)
% PTB.Info.AutoSave
% 
% Description:	autosave the info struct to file at the specified interval. the
%				Info object must already have been named using PTB.Info.SetName.
% 
% Syntax:	ifo.AutoSave(tInterval)
%
% In:
%	tInterval	- the autosave interval, in milliseconds.  set to false to stop
%				  autosaving.
% 
% Updated: 2011-12-20
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global PTBIFO;

if notfalse(tInterval)
	tStart	= PTB.Now+tInterval;
	
	if ifo.parent.Scheduler.Exists('info_autosave')
		ifo.parent.Scheduler.Update('info_autosave',[],[],[],[],[],[],tInterval,tStart);
	else
		priority	= ifo.parent.Scheduler.PRIORITY_IDLE;
		
		ifo.parent.Scheduler.Add(@() p_AutoSave(ifo),1000,'info_autosave',{},0,priority,tInterval,tStart);
	end
else
	ifo.parent.Scheduler.Remove('info_autosave');
end
