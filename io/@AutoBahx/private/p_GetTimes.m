function p_GetTimes(ab)
% p_GetTimes
% 
% Description:	query the AutoBahx for the button down and up times
% 
% Syntax:	p_GetTimes(ab)
% 
% Updated: 2012-01-20
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%get the button down times
	[nOverflow,tMicros]	= p_QueryTime(ab,ab.CMD_BUTTON_DOWNS,true);
	t					= p_box2now(ab,p_boxu2boxm(ab,nOverflow,tMicros));
	
	%add to the buffer
		ab.t_down	= [ab.t_down; t];
%get the button up times
	[nOverflow,tMicros]	= p_QueryTime(ab,ab.CMD_BUTTON_UPS,true);
	t					= p_box2now(ab,p_boxu2boxm(ab,nOverflow,tMicros));
	
	%add to the buffer
		ab.t_up	= [ab.t_up; t];
