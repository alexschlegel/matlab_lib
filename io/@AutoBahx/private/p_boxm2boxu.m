function [nOverflow,tMicros] = p_boxm2boxu(ab,tBox)
% p_boxu2boxm
% 
% Description:	convert milliseconds since the Autobahx started to microseconds
%				and overflows
% 
% Syntax:	[nOverflow,tMicros] = p_boxm2boxu(ab,tBox)
% 
% In:
% 	ab		- the AutoBahx object
% 	tBox	- the number of milliseconds since the AutoBahx started
% 
% Out:
%	nOverflow	- the micros overflow counter value
%	tMicros		- the micros value
% 
% Updated: 2012-01-20
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
t	= tBox*1000;

nOverflow	= round(t/ab.MICROS_OVERFLOW)
tMicros		= t - nOverflow*ab.MICROS_OVERFLOW;
