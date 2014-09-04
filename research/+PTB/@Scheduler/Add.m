function Add(sch,f,tEstimate,strName,varargin)
% PTB.Scheduler.Add
% 
% Description:	add a task to the scheduler
% 
% Syntax:	sch.Add(f,tEstimate,strName,[arg]={},[nOut]=0,[priority]=sch.PRIORITY_NORMAL,[tInterval]=-1,[tStart]=<now>,[tEnd]=Inf)
% 
% In:
%	f			- a handle to the task function.  the function must return at
%				  least a boolean as its first output indicating whether the
%				  task should abort
%	tEstimate	- an estimate of the amount of time it will take to execute the
%				  function, in milliseconds
%	strName		- the name of the task.  should be unique if it will be referred
%				  to later.
%	[arg]		- a cell of arguments to the function
%	[nOut]		- the number of outputs, not including the first abort output,
%				  the function will return
%	[priority]	- the priority of the task.  one of the following:
%					sch.PRIORITY_IDLE:		lowest priority
%					sch.PRIORITY_LOW:		lower than normal priority
%					sch.PRIORITY_NORMAL:	normal priority
%					sch.PRIORITY_HIGH:		high priority
%					sch.PRIORITY_CRITICAL:	critical priority, will run even if
%						the PTB.Scheduler.Wait caller doesn't give it enough time
%	[tInterval]	- the desired time interval between executions of the task.  set
%				  to -1 if the task should only be executed once.
%	[tStart]	- the desired start time
%	[tEnd]		- the task will no longer execute after this time
%
% Updated: 2011-12-20
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global PTBIFO;

[arg,nOut,priority,tInterval,tStart,tEnd]	= ParseArgs(varargin,{},0,sch.PRIORITY_NORMAL,-1,[],Inf);

if isempty(tStart)
	tStart	= PTB.Now;
end

if tInterval==-1
	tskMode	= bitset(uint8(0),sch.MODE_RUNONCE);
else
	tskMode	= uint8(0);
end

%append the task to the add queue
	PTBIFO.scheduler.queue.add(:,end+1)	=	{
												char(strName)
												priority
												f
												arg
												tskMode
												tInterval
												0
												nOut
												cell(1,nOut)
												tEstimate
												tStart
												tEnd
												-1
												-1
												tStart
											};
