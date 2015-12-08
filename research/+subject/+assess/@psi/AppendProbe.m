function sEstimate = AppendProbe(obj,kTask,d,result)
% subject.assess.psi.AppendProbe
% 
% Description:	append a probe to the history
% 
% Syntax: sEstimate = obj.AppendProbe(kTask,d,result)
% 
% In:
%	kTask	- the index of the task that was probed
%	d		- the difficulty of the probe
%	result	- true if the subject was correct
%
% Out:
%	sEstimate	- the new estimate for the assessed task (see GetTaskEstimate)
% 
% Updated:	2015-12-08
% Copyright 2015 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%update the PM struct with the probe result
	%suspend psi-marginal? (see PAL_AMPM_Demo)
		%***
		bSuspend	= false;
	
	obj.PM(kTask)	= PAL_AMPM_updatePM(obj.PM(kTask),result,'fixLapse',bSuspend);

%update the estimate
	sEstimate	= obj.GetTaskEstimate(kTask);
	
	sEstimate.ability	= 1 - obj.PM(kTask).threshold(end);
	sEstimate.slope		= 10.^obj.PM(kTask).slope(end);
	sEstimate.lapse		= obj.PM(kTask).lapse(end);
	sEstimate.rmse		= obj.PM(kTask).seThreshold(end);
	
	obj.SetTaskEstimate(kTask,sEstimate);

%update the history
	obj.AppendTaskHistory(kTask,d,result);
