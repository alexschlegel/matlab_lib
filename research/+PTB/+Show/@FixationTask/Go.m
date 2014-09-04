function tGo = Go(ft)
% PTB.FixationTask.Go
% 
% Description:	start the fixation task
% 
% Syntax:	tGo = ft.Go
%
% Out:
%	tGo	- the time the fixation task started
% 
% Updated: 2012-01-31
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global PTBIFO;

tNow	= PTB.Now;

if ~ft.parent.Scheduler.Exists('fixation_task')
	ft.Reset;
	
	ft.parent.Window.SetStore(true);
	
	tDelay		= PTBIFO.fixation_task.delay;
	priority	= ft.parent.Scheduler.PRIORITY_CRITICAL;
	
	ft.parent.Scheduler.Add(...
		@() p_FixationTaskStep(ft)	, ...
		1							, ...
		'fixation_task'				, ...
		[]							, ...
		[]							, ...
		priority					, ...
		10							, ...
		tNow+tDelay					  ...
		);
	
	PTBIFO.fixation_task.tGo	= tNow;
	PTBIFO.fixation_task.tLast	= PTBIFO.fixation_task.tGo;
	
	ft.AddLog('started',tNow);
elseif ~ft.Running
	ft.parent.Window.SetStore(true);
	
	ft.parent.Scheduler.Resume('fixation_task');
	
	PTBIFO.fixation_task.tLast	= tNow;
end

tGo	= PTBIFO.fixation_task.tGo;
