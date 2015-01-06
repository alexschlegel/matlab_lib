function [b,err,t,kState] = Pressed(bb,strButton,varargin)
% PTB.Device.Input.ButtonBox.Pressed
% 
% Description:	check to see if a button byte was sent over the serial port
% 
% Syntax:	[b,err,t,kState] = bb.Pressed(strButton,[bLog]=true) OR
%			bb.Pressed(strButton,'reset')
% 
% In:
%	strButton	- the button name
%	[bLog]		- true to add a log event if the button was pressed
%	'reset'		- clear the serial buffer of the specified buttons
%
% Out:
%	b		- true if the button was pressed, or false if err==true
%	err		- true if any of the bad buttons were down along with strButton
%	t		- the time associated with the query
%	kState	- if b is true, an array of the state indices that were pressed
%
% Updated: 2011-12-24
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
bLog	= ParseArgs(varargin,true);

[b,err,t]	= deal(false);
kState		= [];

%get the indices to test
	[kGood,kBad]	= bb.Get(strButton);
	kCheck			= unique(append([kGood{:};kBad{:}]));
%get the state of the buttons
	[s,t]		= bb.State(kCheck);
%should we just reset?
	if isequal(bLog,'reset')
		return;
	end
%test the bad buttons
	err	= p_TestBad(bb,s,t,strButton,kBad,bLog);
	if err
		return;
	end
%test the good buttons
	nGood	= numel(kGood);
	for kG=1:nGood
		if all(s(kGood{kG}))
			kState	= kGood{kG};
			b		= true;
			break;
		end
	end
%add a log entry
	if b && bLog
		bb.AddLog(['pressed: ' tostring(strButton)],t);
	end
