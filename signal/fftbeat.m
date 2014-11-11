function [f,p] = fftbeat(x,rate,varargin)
% fftbeat
% 
% Description:	simple method to estimate the beat rate of a signal from its
%				fft
% 
% Syntax:	[f,p] = fftbeat(x,rate,<options>)
% 
% In:
% 	x		- a signal
%	rate	- the sampling rate of the signal, in Hz
%	<options>:
%		fmin:	(0.5) the minimum beat rate to consider, in Hz
%		fmax:	(6) the maximum beat rate to consider, in Hz
% 
% Out:
% 	f	- the estimated beat rate, in Hz
%	p	- the phase of the beat pattern, in seconds
% 
% Updated: 2012-11-18
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'fmin'	, 0.5	, ...
		'fmax'	, 6		  ...
		);

%calculate the fft
	nfft	= numel(x);
	
	kMin	= f2k(opt.fmin,rate,nfft);
	kMax	= f2k(opt.fmax,rate,nfft);
	
	ft		= reshape(fft(x),[],1);
	ft		= ft(kMin:kMax);
	aft		= abs(ft);
%find the maximum in the specified range
	nRange	= kMax-kMin+1;
	nFilt	= max(3,round(nRange/10));
	
	%median filter the fft
		ft	= medfilt2(aft,[nFilt 1],'zeros');
	%find the max
		k	= kMin - 1 + find(aft==max(aft),1);
		f	= k2f(k,rate,nfft);
		p	= 0;
		