function id = Update(sch,strName,varargin)
% Group.Scheduler.Update
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
% Updated: 2011-12-27
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
[f,tEstimate,strNameNew,arg,nOut,priority,tInterval,tStart,tEnd]	= ParseArgs(varargin,[],[],[],[],[],[],[],[],[]);

tNow	= Group.Now;

p_GetRemoveLock(sch);

[b,k]	= ismember(strName,{sch.root.info.scheduler.task.name});

if b
	if ~isempty(strNameNew)
		sch.root.info.scheduler.task(k).name	= char(strNameNew);
	end
	
	if ~isempty(priority)
		sch.root.info.scheduler.task(k).priority	= priority;
	end
	
	if ~isempty(f)
		sch.root.info.scheduler.task(k).function		= f;
	end
	
	if ~isempty(arg)
		sch.root.info.scheduler.task(k).arguments		= arg;
	end
	
	if ~isempty(tInterval)
		sch.root.info.scheduler.task(k).interval	= tInterval;
		
		if tInterval==-1
			sch.root.info.scheduler.task(k).mode	= bitset(sch.root.info.scheduler.task(k).mode,sch.MODE_RUNONCE);
		end
	end
	
	if ~isempty(nOut) && nOut~=sch.root.info.scheduler.task(k).nOut
		sch.root.info.scheduler.task(k).nOut	= nOut;
		sch.root.info.scheduler.task(k).output	= cell(1,nOut);
	end
	
	if ~isempty(tEstimate)
		sch.root.info.scheduler.task(k).tEstimate	= tEstimate;
	end
	
	if ~isempty(tStart)
		sch.root.info.scheduler.task(k).tSetStart	= tStart;
	end
	
	if ~isempty(tEnd)
		sch.root.info.scheduler.task(k).tSetEnd	= tEnd;
	end
	
	if sch.root.info.scheduler.task(k).interval==-1
		sch.root.info.scheduler.task(k).tNext	= sch.root.info.scheduler.task(k).tSetStart;
	else
		sch.root.info.scheduler.task(k).tNext	= sch.root.info.scheduler.task(k).tSetStart + sch.root.info.scheduler.task(k).interval;
	end
end

p_ReleaseRemoveLock(sch);
