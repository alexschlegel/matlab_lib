function t = p_box2now(ab,tBox)
% p_box2now
% 
% Description:	convert AutoBahx times to PTB.Now format
% 
% Syntax:	t = p_box2now(ab,tBox)
% 
% In:
%	ab		- the AutoBahx object
% 	tBox	- the AutoBahx time output from p_boxu2boxm
% 
% Out:
% 	t	- the PTB.Now time associated with tBox, assuming tBox represents a time
%		  fairly close to the present
% 
% Updated: 2012-01-20
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
t	= ab.calibrate_m*tBox + ab.calibrate_b;
