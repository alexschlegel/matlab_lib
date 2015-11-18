function f = get_pitches(obj)
% stimulus.sound.pitch.get_pitches
% 
% Description:	get control point pitches
% 
% Syntax: f = obj.get_pitches()
% 
% Out:
%	f	- the pitch frequencies, in Hz
% 
% Updated:	2015-11-17
% Copyright 2015 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
f	= normalize(rand(obj.param.n,1),'min',obj.param.fmin,'max',obj.param.fmax);
