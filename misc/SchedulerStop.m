function bStopped = SchedulerStop(varargin)
% SchedulerStop
% 
% Description:	destroy any jobs currently in a scheduler
% 
% Syntax:	bStopped = SchedulerStop([sch]=<local scheduler>)
%
% In:
%	[sch]	- a scheduler object
% 
% Out:
%	bStopped	- true if the jobs were successfully stopped or none were
%				  running
% 
% Updated: 2011-02-18
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
sch	= ParseArgs(varargin,[]);

if isempty(sch)
	try
		sch	= findResource('scheduler','type','local');
	catch me
		bStopped	= false;
		return;
	end
end

try
	j	= get(sch,'jobs');
	
	if ~isempty(j)
		destroy(j);
	end
	
	bStopped	= true;
catch me
	bStopped	= false;
end
