function b = SimulateProbe(d,varargin)
% subject.assess.base.SimulateProbe
% 
% Description:	simulate a probe result
% 
% Syntax: b = obj.SimulateProbe(d,<options>)
% 
% In:
%	d	- the probe difficulty
%	<options>:
%		ability:		(0.5) the simulated subject's ability
%		steepness:		(5) the steepness of the simulated subject's
%						psychometric curve
%		chance:			(0.5) the chance level of performance (0->1)
%		target:			(0.75) the percentage of correct trials at the subject's
%						ability level
%		fluctuation:	(0) a multiplier that determines the fluctuation of the
%						subject's ability from probe to probe
%		attention:		(1) the fraction of the time the subject is paying
%						attention
% 
% Out:
%	b	- true if the simulated subject response was correct
% 
% Updated:	2015-12-02
% Copyright 2015 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%parse the inputs
	opt	= ParseArgs(varargin,...
			'ability'		, 0.5	, ...
			'steepness'		, 5		, ...
			'chance'		, 0.5	, ...
			'target'		, 0.75	, ...
			'fluctuation'	, 0		, ...
			'attention'		, 1		  ...
	);

sz	= size(d);
b	= nan(sz);

%use a weibull function to simulate the subject's response
	x	= 1 - d;
	t	= min(1,max(0,(1 - opt.ability).*(1+opt.fluctuation*randn(sz))));
	
	b	= weibull(x,t,opt.steepness,0,opt.chance,opt.target) > rand(sz);

%random guesses on the unattended trials
	bAttend	= opt.attention >= rand(sz);
	
	b(~bAttend)	= opt.chance >= rand(sum(~bAttend));
