function [p,t,f,pnz] = spectrogram2(x,varargin)
% spectrogram2
% 
% Description:	calculate the mean spectrogram for a set of signals
% 
% Syntax:	[p,t,f,sig] = spectrogram2(x,<options>)
% 
% In:
% 	x	- an nSignal x nSample set of signals
%	<options>:
%		rate:		(1) the sample rate, in Hz
%		tstart:		(0) the start time, in seconds
%		winexp:		(log2(nSample)) window sizes are 2^winexp samples long
%		ntime:		(512) the number of time points to return
%		fmin:		(0) the minimum frequency, in Hz
%		fmax:		(<Nyquist frequency>) the maximum frequency, in Hz
%		fpadexp:	(2) multiply the default number of output frequencies by
%					2^fpadexp
%		baseline:	(<no baseline>) the [min max] time points for baseline
%					calculation, in seconds
%		silent:		(false) true to suppress status output
% 
% Out:
% 	p	- an nFreq x nTime array of the mean of the average power estimates of
%		  the signal (in decibels), or event-related spectral perturbation if a
%		  baseline was specified
%	t	- an nTime x 1 array of the time value for each PSD value
%	f	- an nFreq x 1 array of the frequency value for each PSD value
%	pnz	- an nFreq x nTime array of p-values for a t-test to find values that
%		  deviate significantly from zero.  only applies if a baseline is
%		  specified.
% 
% Updated: 2015-04-08
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
if size(x,2)==1
	x	= x';
end
[nSignal,nSample]	= size(x);
x					= double(x);


opt	= ParseArgs(varargin,...
		'rate'			, 1		, ...
		'tstart'		, 0		, ...
		'winexp'		, []	, ...
		'ntime'			, 512	, ...
		'fmin'			, 0		, ...
		'fmax'			, []	, ...
		'fpadexp'		, 2		, ...
		'baseline'		, []	, ...
		'silent'		, false	  ...
		);

if isempty(opt.winexp)
	l2s			= log2(nSample);
	opt.winexp	= floor(l2s);
	if opt.winexp==l2s
		opt.winexp	= opt.winexp-1;
	end
end
nWindow		= 2^opt.winexp;
padRatio	= 2^opt.fpadexp;

opt.fmax	= unless(opt.fmax,opt.rate/2);

tLim	= 1000*[opt.tstart k2t(nSample,opt.rate,opt.tstart)];
fLim	= [opt.fmin opt.fmax];

status(['using ' num2str(nWindow) ' samples per window'],'silent',opt.silent);

%calculate the average powers -> decibels
	bBaseline	= ~isempty(opt.baseline);
	
	[s,s2]	= deal(0);
	
	progress('action','init','total',nSignal,'label','Calculating spectrograms','silent',opt.silent);
	for kS=1:nSignal
		%get the time/frequency decomposition
			[str,tf,f,t]	= evalc(['timefreq(x(kS,:),opt.rate,'		...
										'''tlimits''	, tLim,'		...
										'''winsize''	, nWindow,'		...
										'''ntimesout''	, opt.ntime,'	...
										'''freqs''		, fLim,'		...
										'''padratio''	, padRatio'		...
										');']);
		%calculate power
			p	= tf.*conj(tf);
		%normalize by nWindow, multiply by 2 to account for negative frequencies,
		%and divide by 0.375 to account for Hann windowing attenuation (see bug
		%446 of EEGLAB)
			p	= 2*p/(0.375*nWindow);
		%calculate the baseline
			%***
			p	= 10*log10(p);
			if bBaseline
				if kS==1
					kBaseline	= find( (t >= 1000*opt.baseline(1)) & (t <= 1000*opt.baseline(2)) );
					
					status(['baseline calculation from ' num2str(min(t(kBaseline))/1000) 's to ' num2str(max(t(kBaseline))/1000) 's'],'silent',opt.silent); 
				end
	
				pBase	= mean(p(:,kBaseline),2);
				pBase	= repmat(pBase,[1 opt.ntime]);
			else
				%pBase	= 1;
				pBase	= 0;
			end
			%***
			p	= p - pBase;
		%convert to decibels
			%p	= 10*log10(p./pBase);
		
		%keep track of values for mean and standard deviation calculations
			s	= s + p;
			s2	= s2 + p.^2;
		
		progress;
	end
	
	p	= s ./ nSignal;
	ps	= sqrt((s2 - 2.*p.*s + nSignal.*p.^2)./(nSignal-1));
	
	t	= t./1000;
%find significant points
	if bBaseline && nargout>=4
		tval	= p./(ps./sqrt(nSignal));
		pnz		= 2*tcdf(-abs(tval),nSignal-1);
	else
		pnz	= [];
	end
