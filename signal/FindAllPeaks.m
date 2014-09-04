function [kPeaks,vPeaks] = FindAllPeaks(x,fs,varargin)
% FindAllPeaks
% 
% Description:	find all the peaks in signal x
%
% Syntax:	[kPeaks,vPeaks] = FindAllPeaks(x,fs,[hw]=<determine>,[bAboveMean]=true,
%										[bDebug]=false)
% 
% In:
%	x				- the signal
%	fs				- the sampling frequency of the signal
%	[hw]			- the width at half max of the gaussian kernel with which to
%					  filter the data prior to looking for peaks, in ms.  if
%					  unspecified, the function calculates this value from the
%					  highest frequency component with significant power in the
%					  signal (i.e. I hope to filter out noise but keep the
%					  frequencies that make up the signal).  Set==0 to skip
%					  filtering
%	[bAboveMean]	- true to only consider values that are at or above the
%					  signal mean (for signals that oscillate around a fixed
%					  point)
%	[bDebug]		- true to display a debug plot
% 
% Out:
%	kPeaks	- the indices in x at which peaks occur
%	vPeaks	- the values of those peaks
% 
% Updated:	2008-03-05
% Copyright 2008 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
x	= reshape(x,1,[]);
s	= numel(x);

[hw,bAboveMean,bDebug]	= ParseArgs(varargin,[],true,false);

%filter to get nice peaks
	if isempty(hw)
		%determine the filter sigma based on the size of the highest-frequency
		%components of x
			f	= FindFrequencyComponents(x,s,3);
			f	= f(f>3);
			%get the approximate half-width of the highest-frequency peaks
				if isempty(f)
					hw	= 7;
				else
					%we assume peaks are gaussian-shaped.  estimate the width of the
					%peak and then calculate the half-width, assuming the width is
					%6*sigma
					f		= f(end);
					w		= s ./ f;
					sigma	= w ./ 6;
					hw		= 2.355*sigma; %(half-width of a gaussian distribution)
				end
		%convert to s
			hw	= k2t(hw+1,fs);
	end
	if hw>0
		%construct the kernel and filter the signal
			g	= gaussianByFWHM((fs+1)/fs,hw,fs);
			g	= g./sum(g);
			xf	= imfilter(x,g,'replicate');
			
			if nargin==6
				alexplot({x,xf});
			end
	else
		xf	= x;
	end

%optionally cut off signal below the mean
	xf	= xf - mean(xf);
	if bAboveMean
		xf(xf<0)	= 0;
	end

%find peaks
	dx	= sign(xf(2:end) - xf(1:end-1));
	ddx	= dx(2:end) - dx(1:end-1);
	ddx	= [-sign(xf(1)) ddx -sign(xf(end))];	%pad so we get the ends
	
	kPeaks	= find( (xf<0 &	ddx>0) | (xf>0 & ddx<0) );
	vPeaks	= x(kPeaks);
	
%debug?
	if bDebug
		plot(1:numel(x),x,kPeaks,x(kPeaks),'o')
	end
