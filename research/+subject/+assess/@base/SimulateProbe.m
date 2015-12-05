function b = SimulateProbe(d,varargin)
% subject.assess.base.SimulateProbe
% 
% Description:	simulate a probe result
% 
% Syntax: b = obj.SimulateProbe(d,[param]=struct,<options>)
% 
% In:
%	d		- the probe difficulty
%	[param]	- has no effect. just here to conform to the task function
%			  requirements.
%	<options>:
%		chance:			(0.5) the chance level of performance (0->1)
%		target:			(0.75) the percentage of correct trials at the subject's
%						ability level
%		ability:		(0.5) the simulated subject's ability
%		slope:			(5) the slope of the simulated subject's psychometric
%						curve
%		lapse:			(0.03) the subject's lapse rate
%		fluctuation:	(0) a multiplier that determines the fluctuation of the
%						subject's ability from probe to probe
% 
% Out:
%	b	- true if the simulated subject response was correct
% 
% Updated:	2015-12-04
% Copyright 2015 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%parse the inputs
	[param,opt]	= ParseArgs(varargin,struct,...
					'chance'		, 0.5	, ...
					'target'		, 0.75	, ...
					'ability'		, 0.5	, ...
					'slope'			, 5		, ...
					'lapse'			, 0.03	, ...
					'fluctuation'	, 0		  ...
	);

sz	= size(d);
b	= nan(sz);

%use a weibull function to simulate the subject's response
	x	= 1 - d;
	t	= min(1,max(0,(1 - opt.ability).*(1+opt.fluctuation*randn(sz))));
	
	b	= weibull(x,t,opt.slope,0,opt.chance,opt.target,opt.lapse) > rand(sz);
