function x = BandpassFilterFFT(x,fs,fHighStop,fHighPass,fLowPass,fLowStop,varargin)
% BandpassFilterFFT
% 
% Description:	bandpass filter a signal using its FFT
% 
% Syntax:	x = BandpassFilterFFT(x,fs,fHighStop,fHighPass,fLowPass,fLowStop,<options>)
% 
% In:
% 	x			- a single signal or an nSignal x nSample array of signals
%	fs			- the sampling frequency, in Hz
%	fHighStop	- the lower stop frequency, in Hz
%	fHighPass	- the lower pass frequency, in Hz
%	fLowPass	- the upper pass frequency, in Hz
%	fLowStop	- the upper stop frequency, in Hz
%	<options>:
%		tattenuate:	(0.1% of signal) the time, in seconds, to attenuate the
%					signal at the beginning and end (helps with artifacts in the
%					filtered signal)
%		silent:		(false) true to suppress status output
% 
% Out:
% 	x	- the filtered signal
% 
% Updated: 2010-07-27
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgs(varargin,...
		'tattenuate'	, []	, ...
		'silent'		, false	  ...
		);

%reshape the data
	bColumn	= size(x,2)==1;
	if bColumn
		x	= reshape(x,1,[]);
	end

[nSignal,nSample]	= size(x);

if isempty(opt.tattenuate)
	opt.tattenuate	= k2t(nSample*0.001+1,fs);
end

%attenuate the signal
	if opt.tattenuate~=0
		status('applying attenuation envelope to signal','silent',opt.silent);
		
		nAttenuate	= t2k(opt.tattenuate,fs)-1;
		eAttenuate	= ConstructEnvelope(nSample,0,nAttenuate,nSample-nAttenuate,nSample);
		
		x	= x.*repmat(eAttenuate,[nSignal 1]);
	end
%fourier transform the signal
	status('fourier transforming signal','silent',opt.silent);
	
	f	= fft(x,[],2);
%apply the bandpass envelope
	status('applying bandpass envelope to fourier transform','silent',opt.silent);
	
	kHighStop1	= f2k(fHighStop,fs,nSample);
	kHighPass1	= f2k(fHighPass,fs,nSample);
	kLowPass1	= f2k(fLowPass,fs,nSample);
	kLowStop1	= f2k(fLowStop,fs,nSample);
	
	kHighStop2	= f2k(fHighStop,fs,nSample,true);
	kHighPass2	= f2k(fHighPass,fs,nSample,true);
	kLowPass2	= f2k(fLowPass,fs,nSample,true);
	kLowStop2	= f2k(fLowStop,fs,nSample,true);
	
	eBandpass	= ConstructEnvelope(nSample,kHighStop1,kHighPass1,kLowPass1,kLowStop1) + ConstructEnvelope(nSample,kLowStop2,kLowPass2,kHighPass2,kHighStop2);
	
	f	= f.*repmat(eBandpass,[nSignal 1]);
%inverse transform
	status('inverse fourier transforming signal','silent',opt.silent);
	
	x	= real(ifft(f,[],2));
%unreshape
	if bColumn
		x	= reshape(x,[],1);
	end


%------------------------------------------------------------------------------%
function e = ConstructEnvelope(n,kLeftLow,kLeftHigh,kRightHigh,kRightLow)
% construct an envelope
	nAttenuateLeft	= kLeftHigh - kLeftLow;
	nAttenuateRight	= kRightLow - kRightHigh;
	
	hLeft	= reshape(hamming(2*nAttenuateLeft-1),1,[]);
	hRight	= reshape(hamming(2*nAttenuateRight-1),1,[]);
	
	e	= [zeros(1,kLeftLow) hLeft(1:nAttenuateLeft) ones(1,kRightHigh-kLeftHigh-1) hRight(end-nAttenuateRight+1:end) zeros(1,n-kRightLow+1)];
%------------------------------------------------------------------------------%
