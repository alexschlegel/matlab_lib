function [bShown,fPassed,bAbort,tShow,tResponse] = Result(ft,varargin)
% PTB.FixationTask.Result
% 
% Description:	get the fixation task results, either after stopping the fixation
%				task or inflight
% 
% Syntax:	[bShown,fPassed,bAbort,tShow,tResponse] = ft.Result([tStart]=<task start>,[tEnd]=<task end or now>,[bPrint]=true)
%
% In:
%	[tStart]	- the start of the fixation task period to query
%	[tEnd]		- the end of the fixation task period to query
%	[bResult]	- true to print the fraction of tests passed
%
% Out:
%	bShown		- true if the fixation task was shown during the specified
%				  period
%	fPassed		- the fraction of fixation tasks that were passed, or 1 if the
%				  fixation task was not shown during the specified period
%	bAbort		- true if the task was aborted
%	tShow		- an Nx1 array of the times at which the fixation task was shown
%	tResponse	- an Mx1 array of the times at which the subject responded
% 
% Updated: 2012-02-05
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global PTBIFO;

[tStart,tEnd,bPrint]	= ParseArgs(varargin,[],[],true);

tNow	= PTB.Now;

if isempty(tStart)
	tStart	= unless(PTBIFO.fixation_task.tGo,0);
end
if isempty(tEnd)
	tEnd	= unless(PTBIFO.fixation_task.tStop,tNow);
end

bAbort		= ft.parent.Scheduler.Result('fixation_task');
tShow		= PTBIFO.fixation_task.tShow;
tResponse	= PTBIFO.fixation_task.tResponse;

tShow		= tShow(tShow>=tStart & tShow<=tEnd);
tResponse	= tResponse(tResponse>=tStart & tResponse<=tEnd);

bShown		= ~isempty(tShow);

if bShown
%determine whether the subject passed the task
	tTimeout	= PTBIFO.fixation_task.timeout;
	
	%only keep the show times that have finished
		if ~isempty(PTBIFO.fixation_task.tStop)
		%the task has stopped
			tShowGood	= tShow(tShow<PTBIFO.fixation_task.tStop-tTimeout);
		elseif ft.Running
		%the task is still running
			tShowGood	= tShow(tShow<tNow-tTimeout);
		else
		%keep 'em all (would this ever happen?)
			tShowGood	= tShow;
		end
	%find the next response after each task presentation
		if ~isempty(tShowGood)
			tNextResponse	= arrayfun(@(t) tResponse(find(tResponse>=t,1)),tShowGood,'UniformOutput',false);
			bResponded		= ~cellfun(@isempty,tNextResponse);
			
			tResponseCheck	= reshape(cell2mat(tNextResponse(bResponded)),[],1);
			tShowCheck		= reshape(tShowGood(bResponded),[],1);
			fPassed			= sum((tResponseCheck-tShowCheck)<=tTimeout)./numel(tShowGood);
		else
			fPassed	= 1;
		end
else
	fPassed	= 1;
end

if bPrint
	ft.AddLog([num2str(roundn(fPassed*100,0)) '% passed']);
end
