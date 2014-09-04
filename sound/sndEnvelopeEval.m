function [x,t] = sndEnvelopeEval(sEnvelope,x,tOff,kS,kF)
% sndEnvelopeEval
% 
% Description:	evaluate an envelope at specific values
% 
% Syntax:	[x,t] = sndEnvelopeEval(sEnvelope,x,tOff,kS,kF)
% 
% In:
% 	sEnvelope	- the envelope struct returned by sndEnvelopeDefine
%	x			- the value for which to evaluate the envelope, or a vector of
%				  values, one for each time point, or a function that takes time
%				  as an input
%	tOff		- the time at which the key is released, relative to onset
%	kS			- the key strength from 0->1
%	kF			- the key frequency
% 
% Out:
% 	x	- the envelope vector
%	t	- the time vector corresponding to each point in x
% 
% Updated: 2010-11-24
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

%times at the period endpoints
	tEndAttack	= sEnvelope.t_attack;
	tEndDecay	= tEndAttack + sEnvelope.t_decay;
	tEndSustain	= tOff;
	tEndRelease	= tEndSustain + sEnvelope.t_release;
%time vector
	t	= reshape(GetInterval(0,tEndRelease,tEndRelease*sEnvelope.rate),[],1);
%times in each period
	tAttack		= reshape(GetInterval(0,tEndAttack,tEndAttack*sEnvelope.rate),[],1);
	tDecay		= reshape(GetInterval(tEndAttack,tEndDecay,(tEndDecay-tEndAttack)*sEnvelope.rate),[],1);
	tSustain	= reshape(GetInterval(tEndDecay,tEndSustain,(tEndSustain-tEndDecay)*sEnvelope.rate),[],1);
	tRelease	= reshape(GetInterval(tEndSustain,tEndRelease,(tEndRelease-tEndSustain)*sEnvelope.rate),[],1);
%evaluate the parts of the envelope
	xAttack		= MapValue(sndFunctionEval(sEnvelope.f_attack,tAttack,kS,kF),0,1,sEnvelope.a_start,sEnvelope.a_attack);
	xDecay		= MapValue(sndFunctionEval(sEnvelope.f_decay,tDecay,kS,kF),0,1,sEnvelope.a_sustain,sEnvelope.a_attack);
	xSustain	= sEnvelope.a_sustain*sndFunctionEval(sEnvelope.f_sustain,tSustain,kS,kF);
	xRelease	= MapValue(sndFunctionEval(sEnvelope.f_release,tRelease,kS,kF),0,1,sEnvelope.a_end,sEnvelope.a_sustain);
%concatenate
	xNorm	= [xAttack; xDecay; xSustain; xRelease];
%make sure we didn't make too much
	n		= min(numel(xNorm),numel(t));
	t		= t(1:n);
	xNorm	= xNorm(1:n);
%apply the value
	switch class(x)
		case 'function_handle'
			x	= reshape(x(t),[],1);
		otherwise
			x	= reshape(x,[],1);
	end
	x	= x.*xNorm;
	