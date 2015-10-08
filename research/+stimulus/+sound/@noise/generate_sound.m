function [stim,ifo] = generate_sound(obj,ifo)
% stimulus.sound.noise.generate_sound
% 
% Description:	generate the noise stimulus
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
% Updated:	2015-10-06
% Copyright 2015 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
stim	= 2*rand(ifo.param.rate*ifo.param.dur,1) - 1;
