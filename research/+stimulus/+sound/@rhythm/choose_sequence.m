function seq = choose_sequence(obj,n,cInstrument)
% stimulus.sound.rhythm.choose_sequence
% 
% Description:	choose the instrument sequence
% 
% Syntax: seq = obj.choose_sequence(n,cInstrument)
% 
% In:
%	n			- the number of beats
%	cInstrument	- a cell of instruments to choose from
%
% Out:
%	seq	- an array of instrument indices
% 
% Updated:	2015-11-17
% Copyright 2015 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

nInstrument	= numel(ForceCell(cInstrument));

seq	= [(1:nInstrument)'; randi(nInstrument,[n-nInstrument 1])];
seq	= randomize(seq(1:n),'seed',false);
