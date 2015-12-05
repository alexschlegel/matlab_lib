function sEstimate = GetTaskEstimate(obj,varargin)
% subject.assess.base.GetTaskEstimate
% 
% Description:	get a struct with info about the current ability estimate for
%				the given task
% 
% Syntax: sEstimate = obj.GetTaskEstimate([kTask]=1)
% 
% In:
%	[kTask]	- the task index
% 
% Out:
%	sEstimate	- a struct containing the following info about the estimate (see
%				  the class' properties for more info:
%					ability, slope, lapse, chance, target, rmse, r2
% 
% Updated:	2015-12-04
% Copyright 2015 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
kTask	= ParseArgs(varargin,1);

sEstimate	= struct(...
				'ability'	, obj.ability(kTask)	, ...
				'slope'		, obj.slope(kTask)		, ...
				'lapse'		, obj.lapse(kTask)		, ...
				'chance'	, obj.chance			, ...
				'target'	, obj.target			, ...
				'rmse'		, obj.rmse(kTask)		, ...
				'r2'		, obj.r2(kTask)			  ...
				);
