function [stim,ifo] = generate_sound(obj,ifo)
% stimulus.sound.pitch.generate_sound
% 
% Description:	generate the pitch sequence
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
nSample	= ifo.param.rate*ifo.param.dur;

%generate the frequency at each time point
	nCP	= numel(ifo.param.f);
	tCP	= (0:nCP+1)';
	fCP	= [ifo.param.f(1); ifo.param.f; ifo.param.f(end)];
	
	t	= (0.5:nCP/(nSample-1):nCP+0.5)';
	%t	= GetInterval(0.5,nCP+0.5,nSample)';
	f	= interp1(tCP,fCP,t,ifo.param.interp);

%generate the sound
	t		= cumsum(f/ifo.param.rate);
	stim	= ifo.param.fInstrument(2*pi*t);
