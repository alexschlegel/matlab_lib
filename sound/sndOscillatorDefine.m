function sOscillator = sndOscillatorDefine(f,varargin);
% sndOscillatorDefine
% 
% Description:	define an oscillator
% 
% Syntax:	sOscillator = sndOscillatorDefine(f,<options>);
% 
% In:
% 	f	- a periodic function from (0->1) to (0->1), or one of the following
%		  strings for a builtin oscillator:
%			'sine'
%			'sawtooth'
%			'square'
%			'random'
%			'pow2'
%	<options>:
%		rate:		(44100) the sampling frequency
%		f_sample:	(1) the frequency of the sample to store
%		envelope:	(<default>) an envelope struct to apply to the oscillator
% 
% Out:
% 	sOscillator	- an oscillator struct
% 
% Updated: 2010-11-24
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
rateDefault	= 44100;

opt	= ParseArgs(varargin,...
		'rate'		, rateDefault	, ...
		'f_sample'	, 1				, ...
		'envelope'	, []			  ...
		);
if isempty(opt.envelope)
	opt.envelope	= sndEnvelopeDefine('oscillator');
end

sOscillator	= opt;

%get the oscillator function
	if ischar(f)
		switch f
			case 'sine'
				f	= @(x) sin(2*pi*x);
			case 'sawtooth'
				f	= @(x) 2*x-1;
			case 'square'
				f	= @(x) 2*(x>=0.5)-1;
			case 'random'
				f	= @(x) 2*rand(size(x))-1;
			case 'pow2'
				f	= @(x) 2*x.^2-1;
			otherwise
				error(['"' f '" is not a valud builtin oscillator type.']);
		end
	end
	sOscillator.f	= f;
%get the oscillator sample
	sOscillator.sample	= reshape(sOscillator.f(GetInterval(0,1,sOscillator.rate/sOscillator.f_sample)),[],1);
