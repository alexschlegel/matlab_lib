function [tDown,tUp] = GetTimes(ab)
% AutoBahx.GetTimes
% 
% Description:	get the button down and up times that have occurred since the
%				last call to AutoBahx.GetTimes
% 
% Syntax:	[tDown,tUp] = ab.GetTimes()
%
% Out:
%	tDown	- the button down times, as milliseconds since the epoch
%	tUp		- the button up times, as milliseconds since the epoch
%
% Updated: 2012-01-19
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%query the AutoBahx
	p_GetTimes(ab);
%get and clear the buffers
	tDown	= ab.t_down;
	tUp		= ab.t_up;
	
	ab.t_down	= [];
	ab.t_up		= [];
