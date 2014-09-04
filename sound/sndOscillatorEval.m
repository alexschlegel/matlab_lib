function [x,t] = sndOscillatorEval(sOscillator,f,tOff,kS)
% sndOscillatorEval
% 
% Description:	evaluate an oscillator at specific values
% 
% Syntax:	[x,t] = sndOscillatorEval(sOscillator,f,tOff,kS)
% 
% In:
% 	sOscillator	- an oscillator struct returned by sndOscillatorDefine
%	f			- the frequency, as x input to sndEnvelopeEval
%	tOff		- the time at which the key is released, relative to onset
%	kS			- the key strength from 0->1
% 
% Out:
% 	x	- the signal
%	t	- the time vector corresponding to each point in x
% 
% Updated: 2010-11-24
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

%get the enveloped frequencies
	[f,t]	= sndEnvelopeEval(sOscillator.envelope,f,tOff,kS,f);
%construct the signal
	dk	= f./sOscillator.f_sample;
	k	= round(mod(cumsum(dk),numel(sOscillator.sample)-1)+1);
	n	= numel(k);
	x	= sOscillator.sample(k);
	t	= k2t(1:n,sOscillator.rate);
