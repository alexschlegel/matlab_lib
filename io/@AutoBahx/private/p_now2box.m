function tBox = p_now2box(ab,t)
% p_now2box
% 
% Description:	convert PTB.Now times to AutoBahx format
% 
% Syntax:	tBox = p_now2box(ab,t)
% 
% In:
%	ab			- the AutoBahx object
%	t			- a PTB.Now time
% 
% Out:
% 	tBox	- the AutoBahx time associated with t, assuming t represents a time
%			  fairly close to the present
% 
% Updated: 2012-01-20
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
tBox	= (t - ab.calibrate_b)/ab.calibrate_m;
