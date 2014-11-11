function x = GeneratePeak(t,tPeak,varargin)
% GeneratePeak
% 
% Description:	generate a signal with a peak
% 
% Syntax:	x = GeneratePeak(t,tPeak,<options>)
% 
% In:
% 	t		- a time vector
%	tPeak	- the time at which the peak occurs
%	<options>:
%		fwhm:	(<duration>/10) the FWHM of the peak
% 
% Out:
% 	x	- the signal with the peak
% 
% Updated: 2011-11-04
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgs(varargin,...
		'fwhm'	, []	  ...
		);

dur		= max(t) - min(t);
tMid	= (min(t)+max(t))/2;

opt.fwhm	= unless(opt.fwhm,dur/10);

fs			= GetSamplingFrequency(t);
n			= numel(t);
s			= size(t);

mu		= t2k(tMid - tPeak,fs);
sigma	= opt.fwhm./(2*sqrt(-log(0.5)));

x		= exp(-((t-tPeak)./sigma).^2);
