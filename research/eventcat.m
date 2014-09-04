function event = eventcat(cEvent,durRun)
% eventcat
% 
% Description:	concatenate events from multiple runs so they are valid for
%				concatenated data
% 
% Syntax:	event = eventcat(cEvent,durRun)
% 
% In:
% 	cEvent	- a nRun-length cell of nEvent x 3 arrays specifying the condition
%			  number, time, and duration of each event in each run
% 	durRun	- the run duration 
% 
% Out:
% 	event	- an nEventTotal x 3 array of events corresponding to the
%			  concatenated version of the runs
% 
% Updated: 2012-06-28
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

nRun	= numel(cEvent);

%offset each event time by the number of TRs that preceded its run
	cEvent	= arrayfun(@(r) cEvent{r} + repmat([0 (r-1)*durRun 0],[size(cEvent{r},1) 1]),(1:nRun)','UniformOutput',false);
%concatenate
	event	= cat(1,cEvent{:});
