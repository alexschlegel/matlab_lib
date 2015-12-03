function [a,s,rmse,r2] = EstimateAbility(obj,d,f,n)
% subject.assess.base.EstimateAbility
% 
% Description:	estimate the subject's ability, given the probe history
% 
% Syntax: [a,s,rmse,r2] = obj.EstimateAbility(d,f,n)
% 
% In:
%	d	- an array of the difficulty values probed
%	f	- for each d, the fraction of correct responses on those probes
%	n	- the number of probes at each value of d
% 
% Out:
%	a		- the estimated ability
%	s		- the estimated steepness
%	rmse	- the root mean square error between the data and the fit curve
%	r2		- the degree of freedom adjusted squared correlation between data
%			  and fit
% 
% Updated:	2015-12-02
% Copyright 2015 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
persistent ft;

if isempty(ft)
	ft	= fittype('abs(weibull(x,t,b,0,g,a))',...
					'coefficients'	, {'t','b'}	, ...
					'problem'		, {'g','a'}	  ...
					);
end

%repeat values according to the number of probes
	nSample	= numel(d);
	kSample	= (1:nSample)';
	
	kRep	= arrayfun(@(k) repmat(k,[n(k) 1]),kSample,'uni',false);
	kRep	= cat(1,kRep{:});
	
	dRep	= d(kRep);
	fRep	= f(kRep);

%fit the responses to a weibull curve
	[fo,gf,op]	= fit(1-dRep,fRep,ft,...
					'problem'		, {obj.chance, obj.target}		, ...
					'startpoint'	, [obj.ability; 5]	, ...
					'lower'			, [0 0]							, ...
					'upper'			, [1 10]						  ...
					);

%return the parameters
	a		= 1-fo.t;
	s		= fo.b;
	rmse	= gf.rmse;
	r2		= gf.adjrsquare;
