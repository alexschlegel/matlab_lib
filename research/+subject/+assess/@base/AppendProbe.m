function AppendProbe(obj,d,b)
% subject.assess.base.AppendProbe
% 
% Description:	append a probe to the history
% 
% Syntax: obj.AppendProbe(d,b)
% 
% In:
%	d	- the difficulty of the probe
%	b	- true if the subject was correct
% 
% Updated:	2015-12-02
% Copyright 2015 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%calculate the fit values
	dAll	= [reshape([obj.history.record.d],[],1); d];
	bAll	= [reshape([obj.history.record.result],[],1); b];
	
	[obj.history.d,obj.history.f,obj.history.n]	= obj.GetFitValues(dAll,bAll);

%update the estimate
	nD		= numel(obj.history.d);
	nProbe	= numel(obj.history.record);
	
	if nD>1
		[a,s,obj.rmse,obj.r2]	= obj.EstimateAbility(obj.history.d,obj.history.f,obj.history.n);
		
		if nProbe>2
			kMean	= max(2,nProbe-3):nProbe;
			
			obj.ability		= mean([[obj.history.record(kMean).ability] a]);
			obj.steepness	= mean([[obj.history.record(kMean).steepness] s]);
		else
			obj.ability		= a;
			obj.steepness	= s;
		end
	else
		a			= obj.ability;
		s			= obj.steepness;
		obj.rmse	= NaN;
		obj.r2		= NaN;
	end

%record the results
	obj.history.record(end+1)	= struct(...
									'd'			, d				, ...
									'result'	, b				, ...
									'ability'	, obj.ability	, ...
									'steepness'	, obj.steepness	, ...
									'rmse'		, obj.rmse		, ...
									'r2'		, obj.r2		  ...
									);
