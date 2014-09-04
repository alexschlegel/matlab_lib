function fs = GetSamplingFrequency(t)
% GetSamplingFrequency
% 
% Description:	get the sampling frequency based on a time vector t (in s)
% 
% Syntax:	fs = GetSamplingFrequency(t)
%
% Assumptions:	Assumes t is an almost uniform array, e.g. an array the steps
%				the same amount from one position to the next, except for sparse
%				anomalies such as a single large jump in the time value
% 
% Updated:	2009-11-17
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

%get the time between samples
	tDiff	= t(2:end) - t(1:end-1);
%get a 10 bin histogram and find the mean of elements in the modal bin
	[n,x]		= hist(tDiff);
	
	sBin	= mean(x(2:end)-x(1:end-1));
	
	kMode		= find(n==max(n),1);
	xModeMin	= x(kMode)-sBin/2;
	xModeMax	= x(kMode)+sBin/2;
		
	kMean	= find(tDiff>=xModeMin & tDiff<=xModeMax);
	
	%if kMean is empty everything's real close to uniform
		if isempty(kMean)
			kMean	= 1:numel(tDiff);
		end
	
	tDiffMean	= mean(tDiff(kMean));
%sampling frequency
	fs	= 1/tDiffMean;
