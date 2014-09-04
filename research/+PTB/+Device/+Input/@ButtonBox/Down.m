function [b,err,t,kState] = Down(bb,strButton,varargin)
% PTB.Device.Input.ButtonBox.Down
% 
% Description:	check to see if a button byte was sent over the serial port. this
%				has the same behavior as PTB.Device.Input.ButtonBox.Pressed.
% 
% Syntax:	[b,err,t,kState] = bb.Down(strButton,[bLog]=true)
% 
% In:
%	strButton	- the button name
%	[bLog]		- true to add a log event if the button is down
%
% Out:
%	b		- true if the button was pressed, or false if err==true
%	err		- true if any of the bad buttons were down along with strButton
%	t		- the time associated with the query
%	kState	- if b is true, an array of the state indices that were down
%
% Updated: 2011-12-24
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
[b,err,t,kState]	= bb.Pressed(strButton,varargin{:});
