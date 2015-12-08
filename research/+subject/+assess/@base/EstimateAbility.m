function [ability,slope,lapse,rmse,r2] = EstimateAbility(s)
% subject.assess.base.EstimateAbility
% 
% Description:	estimate the subject's ability, given the probe history and
%				current ability estimate
% 
% Syntax: [ability,slope,lapse,rmse,r2] = obj.EstimateAbility(s)
% 
% In:
%	s	- a struct of info about the task (see GetTaskInfo)
% 
% Out:
%	ability	- the estimated ability
%	slope	- the estimated steepness
%	lapse	- the estimate lapse rate
%	rmse	- the root mean square error between the data and the fit curve
%	r2		- the degree of freedom adjusted squared correlation between data
%			  and fit
% 
% Updated:	2015-12-07
% Copyright 2015 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
persistent ft ftFixL ftFixLB;

if isempty(ft)
	ft		= fittype('abs(weibull(x,t,b,0,g,a,lapse))',...
				'coefficients'	, {'t','b','lapse'}	, ...
				'problem'		, {'g','a'}			  ...
				);
	ftFixL	= fittype('abs(weibull(x,t,b,0,g,a,lapse))',...
				'coefficients'	, {'t','b'}			, ...
				'problem'		, {'g','a','lapse'}	  ...
				);
	ftFixLB	= fittype('abs(weibull(x,t,b,0,g,a,lapse))',...
				'coefficients'	, {'t'}					, ...
				'problem'		, {'b','g','a','lapse'}	  ...
				);
end

%repeat values according to the number of probes
	nSample	= numel(s.performance.d);
	kSample	= (1:nSample)';
	
	kRep	= arrayfun(@(k) repmat(k,[s.performance.n(k) 1]),kSample,'uni',false);
	kRep	= cat(1,kRep{:});
	
	dRep	= s.performance.d(kRep);
	fRep	= s.performance.f(kRep);

%fit the responses to a weibull curve
	try
		[fo,gf,op]	= fit(1-dRep,fRep,ft,...
						'problem'		, {s.estimate.chance, s.estimate.target}					, ...
						'startpoint'	, [s.estimate.ability; s.estimate.slope; s.estimate.lapse]	, ...
						'lower'			, [0 0 0]													, ...
						'upper'			, [1 10 0.1]												  ...
						);
	catch me
		switch me.identifier
			case 'curvefit:fit:nanComputed'
			%try with lapse fixed
				try
					[fo,gf,op]	= fit(1-dRep,fRep,ftFixL,...
						'problem'		, {s.estimate.chance, s.estimate.target, s.estimate.lapse}	, ...
						'startpoint'	, [s.estimate.ability; s.estimate.slope]					, ...
						'lower'			, [0 0]														, ...
						'upper'			, [1 10]													  ...
						);
				catch me
					switch me.identifier
						case 'curvefit:fit:nanComputed'
						%try with lapse and b fixed
							try
								[fo,gf,op]	= fit(1-dRep,fRep,ftFixLB,...
									'problem'		, {s.estimate.slope, s.estimate.chance, s.estimate.target, s.estimate.lapse}	, ...
									'startpoint'	, [s.estimate.ability]															, ...
									'lower'			, [0]																			, ...
									'upper'			, [1]																			  ...
									);
							catch me
								switch me.identifier
									case 'curvefit:fit:nanComputed'
									%:(, keep the old fit and just keep collecting probes
										fo	= struct(...
												't'		, 1 - s.estimate.ability	, ...
												'b'		, s.estimate.slope			, ...
												'lapse'	, s.estimate.lapse			  ...
												);
									otherwise
										rethrow(me);
								end
							end
						otherwise
							rethrow(me);
					end
				end
			otherwise
				rethrow(me);
		end
	end

%return the parameters
	ability	= 1-fo.t;
	slope	= fo.b;
	lapse	= fo.lapse;
	rmse	= gf.rmse;
	r2		= gf.adjrsquare;
