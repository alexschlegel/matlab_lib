function SetTaskEstimate(obj,kTask,sEstimate)
% subject.assess.base.SetTaskEstimate
% 
% Description:	set an updated task estimate
% 
% Syntax: obj.SetTaskEstimate(kTask,sEstimate)
% 
% In:
%	sEstimate	- the updated task estimate (see GetTaskEstimate)
% 
% Updated:	2015-12-04
% Copyright 2015 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
obj.ability(kTask) 	= sEstimate.ability;
obj.slope(kTask)	= sEstimate.slope;
obj.lapse(kTask)	= sEstimate.lapse;
obj.rmse(kTask)		= sEstimate.rmse;
obj.r2(kTask)		= sEstimate.r2;
