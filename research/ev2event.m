function [event,durRun] = ev2event(ev)
% ev2event
% 
% Description:	generate an event design specification, given its equivalent as
%				a set of EVs
% 
% Syntax:	[event,durRun] = ev2event(ev)
% 
% In:
% 	ev	- an nTimepoint x nCondition design matrix of 1s and 0s
% 
% Out:
% 	event		- an nEvent x 3 array specifying the condition number, time, and
%				  duration of each event
%	durRun		- the run duration, in TRs
% 
% Updated: 2013-10-20
% Copyright 2013 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
[durRun,nCondition]	= size(ev);

%convert to a 1D array of the events occuring at each time point
	evevent	= sum(ev.*repmat(1:nCondition,[durRun 1]),2);
%parse the events
	bChange	= [evevent(1)~=0; diff(evevent)~=0];
	kChange	= [find(bChange); durRun+1];
	
	durEvent	= kChange(2:end) - kChange(1:end-1);
	kStart		= kChange(1:end-1);
	kEvent		= evevent(kStart);
	
	bKeep	= kEvent~=0;
	
	event	= [kEvent(bKeep) kStart(bKeep) durEvent(bKeep)];
