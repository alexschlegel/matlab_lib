function x = Data(smp,varargin)
% Sample.Data
% 
% Description:	retrieve sample data
% 
% Syntax:	x = smp.Data([t]=<all>,<options>)
% 
% In:
% 	[t]	- the times for which to retrieve data samples
%	<options>:
%		start:	(0) the start time (only affects step, rate, and speed options)
%		step:	([]) an array of step durations, in seconds, for each sample,
%				relative to the start time. overrides t.
%		rate:	([]) an array of sampling rates, in Hz, for each sample.
%				overrides t and step.
%		speed:	([]) an array of speeds, relative to normal, for each sample.
%				overrides t, step, and rate.
% 
% Out:
% 	x	- the sample data
% 
% Updated: 2014-07-29
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
[t,opt]	= ParseArgs(varargin,[],...
			'start'	, 0		, ...
			'step'	, []	, ...
			'rate'	, []	, ...
			'speed'	, []	  ...
			);

if ~isempty(opt.speed)
	tStep	= opt.speed./smp.rate;
	t		= opt.start + cumsum(tStep);
elseif ~isempty(opt.rate)
	tStep	= 1./opt.rate;
	t		= opt.start + cumsum(tStep);
elseif ~isempty(opt.step)
	t	= opt.start + cumsum(opt.step);
elseif isempty(t)
	t	= GetInterval(0,smp.duration-1/smp.rate,1/smp.rate,'stepsize');
end

x	= smp.src(reshape(t,[],1),smp.rate);
