function ev = event2ev(event,durRun,varargin)
% event2ev
% 
% Description:	generate a set of EVs given an event design specification
% 
% Syntax:	ev = event2ev(event,durRun,[nCondition]=<auto>)
% 
% In:
%	event			- an nEvent x 3 array specifying the condition number, time,
%					  and duration of each event
%	durRun			- the run duration, in TRs
%	[nCondition]	- the number of conditions
% 
% Out:
% 	ev	- an nTimepoint x nCondition design matrix
% 
% Updated: 2013-10-20
% Copyright 2013 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
nCondition	= ParseArgs(varargin,max(event(:,1)));

%initialize the design matrix
	ev	= zeros(durRun,nCondition);
%fill in the events
	nEvent	= size(event,1);
	
	for kE=1:nEvent
		ev(event(kE,2) + (0:event(kE,3)-1),event(kE,1))	= 1;
	end
