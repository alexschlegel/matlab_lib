function Press(ab,tDelay,varargin)
% AutoBahx.Press
% 
% Description:	press the button and then release it
% 
% Syntax:	ab.Press(tDelay,[tPress]=<now>)
%
% In:
%	tDelay	- the number of milliseconds (between 0 and ab.MAX_PRESS) to keep
%			  the button down
%	tPress	- the time at which to press the button
%
% Updated: 2012-01-20
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
tPress	= ParseArgs(varargin,[]);

%get the byte corresponding to the specified time
	byteDuration	= round(MapValue(tDelay,0,ab.T_PRESS_MAX,0,255));

if isempty(tPress)
%send the command to press immediately
	p_Send(ab,ab.CMD_BUTTON_PRESS,byteDuration);
else
%send the command to press in the future
	tPress	= p_now2box(ab,tPress);
	
	%disp(int32(tPress))
	p_Send(ab,ab.CMD_BUTTON_PRESSAT,[byteDuration typecast(int32(tPress),'uint8')]);
end
