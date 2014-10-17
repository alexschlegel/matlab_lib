function x = HighpassFilterFFT(x,fs,fHighStop,fHighPass,varargin)
% HighpassFilterFFT
% 
% Description:	highpass filter a signal using its FFT
% 
% Syntax:	x = HighpassFilterFFT(x,fs,fHighStop,fHighPass,<options>)
% 
% In:
% 	x			- a single signal or an nSignal x nSample array of signals
%	fs			- the sampling frequency, in Hz
%	fHighStop	- the lower stop frequency, in Hz
%	fHighPass	- the lower pass frequency, in Hz
%	<options>:
%		tattenuate:	(1/fHighStop) the time, in seconds, to attenuate the signal
%					at the beginning and end (helps with artifacts in the
%					filtered signal)
%		silent:		(false) true to suppress status output
% 
% Out:
% 	x	- the filtered signal
% 
% Updated: 2010-08-17
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgs(varargin,...
		'tattenuate'	, 1/fHighStop	, ...
		'silent'		, false			  ...
		);

status('Highpass filtering (FFT)','silent',opt.silent);

%reshape the data
	bColumn	= size(x,2)==1;
	if bColumn
		x	= reshape(x,1,[]);
	end

[nSignal,nSample]	= size(x);

if isempty(opt.tattenuate)
	opt.tattenuate	= k2t(nSample*0.001+1,fs);
end

%detrend the signal
	status('detrending the signal','silent',opt.silent,'noffset',1);
	
	if ~isempty(opt.tattenuate)
		nMean	= t2k(opt.tattenuate,fs)-1;
	else
		nMean	= 1;
	end
	
	b	= mean(x(:,1:nMean),2);
	m	= mean(x(:,end-nMean+1:end),2) - b;
	x	= x - repmat(b,[1 nSample]) - repmat(m,[1 nSample]).*repmat(GetInterval(0,1,nSample),[nSignal 1]);
%attenuate the signal
	if opt.tattenuate~=0
		status('applying attenuation envelope to signal','silent',opt.silent,'noffset',1);
		
		nAttenuate	= t2k(opt.tattenuate,fs)-1;
		
		eAttenuate	= ConstructEnvelope(nSample,0,nAttenuate,nSample-nAttenuate,nSample);
		
		x	= x.*repmat(eAttenuate,[nSignal 1]);
	end
%fourier transform the signal
	status('fourier transforming signal','silent',opt.silent,'noffset',1);
	
	f	= fft(x,[],2);
%apply the highpass envelope
	status('applying highpass envelope to fourier transform','silent',opt.silent,'noffset',1);
	
	kHighStop1	= f2k(fHighStop,fs,nSample);
	kHighPass1	= f2k(fHighPass,fs,nSample);
	kHighPass2	= f2k(fHighPass,fs,nSample,true);
	kHighStop2	= f2k(fHighStop,fs,nSample,true);
	
	eHighpass	= ConstructEnvelope(nSample,kHighStop1,kHighPass1,kHighPass2,kHighStop2);
	
	f	= f.*repmat(eHighpass,[nSignal 1]);
%inverse transform
	status('inverse fourier transforming signal','silent',opt.silent,'noffset',1);
	
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
	
	hLeft	= reshape(normalize(hamming(2*nAttenuateLeft-1)),1,[]);
	hRight	= reshape(normalize(hamming(2*nAttenuateRight-1)),1,[]);
	
	e	= [zeros(1,kLeftLow) hLeft(1:nAttenuateLeft) ones(1,kRightHigh-kLeftHigh-1) hRight(end-nAttenuateRight+1:end) zeros(1,n-kRightLow+1)];
%------------------------------------------------------------------------------%
