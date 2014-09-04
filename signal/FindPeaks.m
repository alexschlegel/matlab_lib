function [kPeaks,vPeaks] = FindPeaks(x,fs,varargin)
% FindPeaks
% 
% Description:	find the peaks in signal x
%
% Syntax:	[kPeaks,vPeaks] = FindPeaks(x,fs,[hw]=<determine>,[sd]=1,
%								[bAboveMean]=true,[bDebug]=false,[kWindow]=<all>)
% 
% In:
%	x				- the signal
%	fs				- the sampling frequency of the signal
%	[hw]			- the width at half max of the gaussian kernel with which to
%					  filter the data prior to looking for peaks, in s.  if
%					  unspecified, the function calculates this value from the
%					  highest frequency component with significant power in the
%					  signal (i.e. I hope to filter out noise but keep the
%					  frequencies that make up the signal).  Set==0 to skip
%					  filtering
%	[sd]			- only count peaks that are sd standard deviations away from
%					  the mean.  Note that standard deviations and means are
%					  calculated from data that is rectified about the mean
%	[bAboveMean]	- true to only consider values that are at or above the
%					  signal mean (for signals that oscillate around a fixed
%					  point)
%	[bDebug]		- true to debug the results
%	[kWindow]		- if bDebug is true, the indices of the window to plot
% 
% Out:
%	kPeaks	- the indices in x at which peaks occur
%	vPeaks	- the values of those peaks
% 
% Updated:	2008-11-08
% Copyright 2008 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
x	= reshape(x,1,[]);
s	= numel(x);

[hw,sd,bAboveMean,bDebug,kWindow]	= ParseArgs(varargin,[],1,true,false,1:s);

%filter to get nice peaks
	if isempty(hw)
		%determine the filter sigma based on the size of the highest-frequency
		%components of x
			f	= FindFrequencyComponents(x,s,3);
			f	= f(f>3);
			%get the approximate FWHM of the highest-frequency peaks
				if isempty(f)
					hw	= 7;
				else
					%we assume peaks are gaussian-shaped.  estimate the width of the
					%peak and then calculate the FWHM, assuming the width is
					%6*sigma
					f		= f(end);
					w		= s ./ f;
					sigma	= w ./ 6;
					hw		= 2.355*sigma; %(FWHM of a gaussian distribution)
				end
		%convert to s
			hw	= k2t(hw+1,fs);
	end
	if hw>0
		%construct the kernel and filter the signal
			g	= gaussianByFWHM((fs+1)/fs,hw,fs);
			g	= g./sum(g);
			xf	= imfilter(x,g,'replicate');
			
			if bDebug
				alexplot({x(kWindow),xf(kWindow)});
			end
	else
		xf	= x;
	end
	
%only keep values greater than sd standard deviations above the mean
	sx		= sign(xf);
	xo		= xf;
	if ~bAboveMean
		xf	= abs(xf);
	else
		xf	= xf-mean(xf);
	end
	thresh		= mean(xf(xf>=0)) + sd*std(xf(xf>=0));
	xf(xf<thresh)	= 0;
	
	if bDebug
		alexplot(xf(kWindow));
	end
	
%find the positive zones
	bPositive	= xf>0;
	peakZone	= bPositive(1:end-1) - bPositive(2:end);
	kStart		= find(peakZone==-1);
	kEnd		= find(peakZone==1);
	
	%get rid of peaks that lie on the border
		if kStart(end)>kEnd(end)		%peak at the end
			kStart	= kStart(1:end-1);
		end
		if kStart(1)>kEnd(1)			%peak at the start
			kEnd	= kEnd(2:end);
		end
		nPeak	= numel(kStart);
%for each zone, find the maximum and call it a peak
	kPeaks	= zeros(1,nPeak);
	for k=1:nPeak
		[mx,kZone]	= max(xf(kStart(k):kEnd(k)));
		kPeaks(k)	= kStart(k) + kZone - 1;
	end
	vPeaks	= x(kPeaks) .* sx(kPeaks);
	