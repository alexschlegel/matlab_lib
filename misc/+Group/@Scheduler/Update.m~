function id = Update(sch,strName,varargin)
% PTB.Scheduler.Update
% 
% Description:	update a task in the scheduler
% 
% Syntax:	sch.Update(strName,[f],[tEstimate],[strName],[arg],[nOut],[priority],[tInterval],[tStart],[tEnd])
% 
% In:
%	strName		- the task name
%	[f]			- the task's new function
%	[tEstimate]	- the new task execution time estimate
%	[strName]	- the new task name
%	[arg]		- the new cell of arguments
%	[nOut]		- the new number of function outputs
%	[priority]	- the new task priority
%	[tInterval]	- the new task interval
%	[tStart]	- the new start time
%	[tEnd]		- the new end time
%
% Updated: 2011-12-20
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global PTBIFO;

[f,tEstimate,strNameNew,arg,nOut,priority,tInterval,tStart,tEnd]	= ParseArgs(varargin,[],[],[],[],[],[],[],[],[]);

tNow	= PTB.Now;

p_GetRemoveLock(sch);

[b,k]	= ismember(strName,{PTBIFO.scheduler.task.name});

if b
	if ~isempty(strNameNew)
		PTBIFO.scheduler.task(k).name			= char(strNameNew);
	end
	
	if ~isempty(priority)
		PTBIFO.scheduler.task(k).priority		= priority;
	end
	
	if ~isempty(f)
		PTBIFO.scheduler.task(k).function		= f;
	end
	
	if ~isempty(arg)
		PTBIFO.scheduler.task(k).arguments		= arg;
	end
	
	if ~isempty(tInterval)
		PTBIFO.scheduler.task(k).interval	= tInterval;
		
		if tInterval==-1
			PTBIFO.scheduler.task(k).mode	= bitset(PTBIFO.scheduler.task(k).mode,sch.MODE_RUNONCE);
		end
	end
	
	if ~isempty(nOut) && nOut~=PTBIFO.scheduler.task(k).nOut
		PTBIFO.scheduler.task(k).nOut		= nOut;
		PTBIFO.scheduler.task(k).output	= cell(1,nOut);
	end
	
	if ~isempty(tEstimate)
		PTBIFO.scheduler.task(k).tEstimate	= tEstimate;
	end
	
	if ~isempty(tStart)
		PTBIFO.scheduler.task(k).tSetStart	= tStart;
	end
	
	if ~isempty(tEnd)
		PTBIFO.scheduler.task(k).tSetEnd	= tEnd;
	end
	
	if PTBIFO.scheduler.task(k).interval==-1
		PTBIFO.scheduler.task(k).tNext	= PTBIFO.scheduler.task(k).tSetStart;
	else
		PTBIFO.scheduler.task(k).tNext	= PTBIFO.scheduler.task(k).tSetStart + PTBIFO.scheduler.task(k).interval;
	end
end

p_ReleaseRemoveLock(sch);
