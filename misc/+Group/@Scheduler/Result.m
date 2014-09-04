function [bAbort,varargout] = Result(sch,strName)
% Group.Scheduler.Result
% 
% Description:	get the result of the last call to a task
% 
% Syntax:	[bAbort,x1,...,xN] = sch.Result(strName)
% 
% In:
%	strName	- the name of the task
%
% Out:
%	bAbort	- true if the task was aborted
%	xK		- the Kth output from the last call to the task
%
% Updated: 2011-12-27
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
p_GetRemoveLock(sch);

k	= p_Get(sch,strName);

if ~isempty(k)
	bAbort		= logical(bitget(sch.root.info.scheduler.task(k).mode,sch.MODE_ABORTED));
	varargout	= sch.root.info.scheduler.task(k).output;
else
	bAbort						= false;
	[varargout{1:nargout-1}]	= deal([]);
end

p_ReleaseRemoveLock(sch);
