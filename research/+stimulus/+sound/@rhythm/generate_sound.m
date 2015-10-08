function [stim,ifo] = generate_sound(obj,ifo)
% stimulus.sound.rhythm.generate_sound
% 
% Description:	generate the rhythm sequence
% 
% Syntax: [stim,ifo] = obj.generate_sound(ifo)
% 
% In:
%	ifo	- the info struct
% 
% Out:
%	stim	- the sound signal
%	ifo		- the updated info struct
% 
% Updated:	2015-10-07
% Copyright 2015 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

nSample		= ifo.param.rate*ifo.param.dur;
nBeat		= numel(ifo.param.t);
nSampleBeat	= floor(nSample/(4*nBeat));

%generate the sound
	stim	= zeros(nSample,1);
	
	kBeat	= t2k(ifo.param.t,ifo.param.rate);
	
	for k=1:nBeat
		kInstrument	= ifo.param.sequence(k);
		inst		= ifo.param.fInstrument{kInstrument};
		
		kStart	= kBeat(k);
		
		switch class(inst)
			case 'function_handle'
				tBeat	= (1:nSampleBeat)/ifo.param.rate;
				xBeat	= reshape(inst(2*pi*ifo.param.f*tBeat),[],1);
			otherwise
				xBeat	= reshape(inst,[],1);
		end
		
		kEnd			= kStart + numel(xBeat) - 1;
		
		if kEnd>nSample
			xBeat	= xBeat(1:nSample-kStart+1);
			kEnd	= nSample;
		end
		
		stim(kStart:kEnd)	= stim(kStart:kEnd) + xBeat;
	end
	
	stim	= min(1,max(-1,stim));
