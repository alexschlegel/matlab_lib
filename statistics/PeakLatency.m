function [tPL,kPL] = PeakLatency(t,x,fPeak,varargin)
% PeakLatency
% 
% Description:	calculate the time at which a signal reaches some fraction of
%				the peak
% 
% Syntax:	[tPL,kPL] = PeakLatency(t,x,fPeak,<options>)
% 
% In:
% 	t		- an Nx1 array of times
%	x		- an Nx1 array of signal data with a peak
%	fPeak	- the fraction of the peak for which to report the latency
%	<options>:
%		t_start:		(<first time point>) the first time point at which to
%						look for the peak
%		t_end:			(<last time point>) the last time point at which to look
%						for the peak
%		peak_direction:	('both') look for 'positive' peaks, 'negative' peaks, or
%						'both'
% 
% Out:
% 	tPL	- the time at which the signal reaches the specified fraction of the
%		  peak value (peak latency)
%	kPL	- the equivalent index of tPL
% 
% Updated: 2011-10-16
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgs(varargin,...
		't_start'			, min(t)	, ...
		't_end'				, max(t)	, ...
		'peak_direction'	, 'both'	  ...
		);

nT	= numel(t);

%find the peak position
	kStart	= find(t>=opt.t_start,1,'first');
	kEnd	= find(t<=opt.t_end,1,'last');
	
	switch opt.peak_direction
		case 'positive'
			kPeak	= find(x(kStart:kEnd)==max(x(kStart:kEnd)),1) + kStart - 1;
		case 'negative'
			kPeak	= find(x(kStart:kEnd)==min(x(kStart:kEnd)),1) + kStart - 1;
		case 'both'
			kPeak	= find(abs(x(kStart:kEnd))==max(abs(x(kStart:kEnd))),1) + kStart - 1;
		otherwise
			error(['"' tostring(opt.peak_direction) '" is not a valid peak_direction.']);
	end

%get the peak latency
	xPeak	= x(kPeak);
	sgnPeak	= sign(xPeak);
	
	%last point before passing the latency
		if sgnPeak==1
			kPL	= find(x(1:kPeak)<xPeak*fPeak,1,'last');
		else
			kPL	= find(x(1:kPeak)>xPeak*fPeak,1,'last');
		end
		
		if isempty(kPL)
			[tPL,kPL]	= deal(NaN);
			return;
		end
	%interpolate to the latency point
		xPre	= x(kPL);
		tPre	= t(kPL);
		
		if kPL==nT
			tPost	= tPre;
			xPost	= xPre;
			f		= 0;
		else
			tPost	= t(kPL+1);
			xPost	= x(kPL+1);
			f		= min(1,max(0,(xPost - xPeak*fPeak)./(xPost - xPre)));
		end
		
		tPL	= tPre + f.*(tPost - tPre);
		kPL	= kPL + f;

