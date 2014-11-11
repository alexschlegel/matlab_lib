function x = addspike(x,t,fs,varargin)
% addspike
% 
% Description:	add a spike to signal data
% 
% Syntax:	x = addspike(x,t,fs,<options>) OR
%			x = addspike(x,t,tX,<options>)
% 
% In:
% 	x	- the 1D signal
%	t	- the time (or times) at which to add the spike
%	fs	- the sampling frequency of the signal (assumes time starts at 0), in Hz
%	tX	- an array the same size as x specifying the time at each sample
%	<options>:
%		a:			(<RMS amplitude>) the spike amplitude
%		attack:		(0.01) the time from spike start to full amplitude, in
%					seconds
%		sustain:	(0) the full amplitude duration of the spike
%		decay:		(0.01) the time from full amplitude to spike end, in seconds
%		fattack:	(<x.^2>) the handle to a function to use for generating the
%					attack portion of the spike.  must be a function that takes
%					an array of values between 0 and 1 as inputs and returns an
%					array the same size of values between 0 and 1.
%		fdecay:		(<(1-x).^2>) the decay function
% 
% Out:
% 	x	- the signal with spike(s) added
% 
% Updated: 2012-02-28
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin		,...
		'a'			, []			, ...
		'attack'	, 0.01			, ...
		'sustain'	, 0				, ...
		'decay'		, 0.01			, ...
		'fattack'	, @(x) x.^2		, ...
		'fdecay'	, @(x) (1-x).^2	  ...
		);

sX	= size(x);
nX	= numel(x);

x	= reshape(x,1,[]);

if isempty(opt.a)
	opt.a	= unless(rms(x),1,0);
end

if numel(fs)~=1
	tX	= fs;
	fs	= GetSamplingFrequency(fs);
else
	tX	= reshape(k2t(1:nX,fs),size(x));
end

%construct the spike
	nAttack	= t2k(opt.attack,fs)-1;
	xAttack	= opt.a.*opt.fattack(GetInterval(0,1,nAttack));
	
	nSustain	= t2k(opt.sustain,fs)-1;
	xSustain	= opt.a.*ones(1,nSustain);
	
	nDecay	= t2k(opt.decay,fs)-1;
	xDecay	= opt.a.*opt.fdecay(GetInterval(0,1,nDecay));
	
	xSpike	= [xAttack xSustain xDecay];
	nSpike	= numel(xSpike);
%insert it
	nT	= numel(t);
	
	kStart	= t2k(t,fs,tX(1));
	kEnd	= kStart + nSpike - 1;
	for kT=1:nT
		kAdd	= kStart(kT):kEnd(kT);
		bValid	= kAdd>0 & kAdd<nX;
		
		x(kAdd(bValid))	= x(kAdd(bValid)) + xSpike(bValid);
	end

x	= reshape(x,sX);
