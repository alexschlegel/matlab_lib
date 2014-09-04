function tBox = p_boxu2boxm(ab,nOverflow,tMicros)
% p_boxu2boxm
% 
% Description:	convert a time sent by the AutoBahx to milliseconds
% 
% Syntax:	tBox = p_boxu2boxm(ab,nOverflow,tMicros)
% 
% In:
% 	ab			- the AutoBahx object
%	nOverflow	- the micros overflow counter value
%	tMicros		- the micros value
% 
% Out:
% 	tBox	- the number of milliseconds since the AutoBahx started (kind of,
%			  the Arduino seems to lose accuracy pretty quickly)
% 
% Updated: 2012-01-20
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
tBox	= (nOverflow*ab.MICROS_OVERFLOW + tMicros)/1000;
