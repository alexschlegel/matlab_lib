function [f,t] = DetectPitch(x,rate,varargin)
% DetectPitch
% 
% Description:	detect the dominant frequency of a signal
% 
% Syntax:	[f,t] = DetectPitch(x,rate,<options>)
% 
% In:
% 	x		- a 1D signal
%	rate	- the sample rate of the signal, in Hz
%	<options>:
%		harmonics:	([2 3]) the harmonics to consider
%		window:		(<everything>) the length of the STFT, in seconds
%		step:		(<window>/2) the window step size, in seconds
% 
% Out:
% 	f	- an Nx1 estimate of the dominant frequency of the signal at each of
%		  N time points
%	t	- the starting point at which each f value was measured, in seconds
% 
% Updated: 2011-11-25
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgs(varargin,...
		'harmonics'	, [2 3]	, ...
		'window'	, []	, ...
		'step'		, []	  ...
		);

x	= reshape(x,[],1);
n	= numel(x);
dur	= k2t(n+1,rate);

opt.window	= unless(opt.window,dur);
opt.step	= unless(opt.step,opt.window/2);
nWinDur		= t2k(opt.window,rate)-1;
nStep		= t2k(opt.step,rate)-1;

%get the start of each window
	kWin	= reshape(round(GetInterval(1,n - nWinDur + 1,nStep,'stepsize')),[],1);
	nWin	= numel(kWin);

t	= k2t(kWin,rate);
f	= NaN(nWin,1);

for kW=1:nWin
	%get the current signal
		xCur	= x(kWin(kW) + (0:nWinDur-1));
	%apply a hanning window to the signal
		xCur	= xCur.*hanning(nWinDur);
	%get the power spectrum of the signal
		[pX,fX]	= PowerSpec(xCur,rate,'out','abs');
		nF		= numel(fX);
	%blur a little
		%maximum filter
			pX	= ordfilt2(pX,5,ones(5,1),'symmetric');
		%blur by a gaussian with fwhm 3Hz and width 25Hz
			%get the frequency step
				fStep	= fX(2) - fX(1);
			%the filter
				g	= gaussianByFWHMa(25,3,fStep)';
			%filter
				pX	= imfilter(pX,g,'replicate');
	%zscore
		pX	= max(0,pX - mean(pX))./std(pX);
	%multiply by harmonics
		nHarmonic	= numel(opt.harmonics);
		
		[pXM,pXMax]	= deal(pX);
		for kH=1:nHarmonic
			mH				= zeros(nF,1);
			pH				= pX(1:opt.harmonics(kH):end);
			mH(1:numel(pH))	= pH;
			
			pXM	= pXM.*mH;
			pXB	= max(pX,pXM);
		end
	%peak frequency
		pMax	= max(pXB);
		kMax	= find(pXB==pMax,1,'first');
		f(kW)	= fX(kMax);
	%check for peaks at the lower harmonics
		fHarmonic	= [];
		kHarmonic	= [];
		
		%get the harmonics to check
			hCur	= 2;
			fH		= f(kW)/hCur;
			kH		= f2k(fH,rate,nWinDur);
			while kH>1 && (isempty(kHarmonic) || kH~=kHarmonic(end))
				fHarmonic	= [fHarmonic; fH];
				kHarmonic	= [kHarmonic; kH];
				
				hCur	= hCur+1;
				fH		= f(kW)/hCur;
				kH		= f2k(fH,rate,nWinDur);
			end
		%check the harmonics
			bPeak	= pXB(kHarmonic)>=0.8*pMax;
			kPeak	= find(~bPeak,1,'last')+1;
		%reassign if we found another peak
			if ~isempty(bPeak) && isempty(kPeak)
			%all are peaks
				f(kW)	= fHarmonic(1);
			elseif kPeak~=numel(kHarmonic)+1
			%got a peak
				f(kW)	= fHarmonic(kPeak);
			end
end