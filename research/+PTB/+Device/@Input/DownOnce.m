function [b,err,t,kState] = DownOnce(inp,strButton,varargin)
% PTB.Device.Input.DownOnce
% 
% Description:	test if a button is down.  if it is down, don't return true again
%				until it is released and down again.
% 
% Syntax:	[b,err,t,kState] = inp.State.DownOnce(strButton,[bLog]=true) OR
%			inp.State.DownOnce(strButton,'reset')
% 
% In:
%	strButton	- the button name
%	[bLog]		- true to add a log event if the button was pressed
%	'reset'		- reset the state of the button
%
% Out:
%	b		- true if the button is down after being up, or false if err==true
%	err		- true if any of the bad buttons were down along with strButton
%	t		- the time associated with the query
%	kState	- if b is true, an array of the state indices that were down
%
% Updated: 2012-02-10
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
bLog	= ParseArgs(varargin,true);

[b,err,t]	= deal(false);
kState		= [];

%get the current state
	[s,t]	= inp.State;
%initialize the state variables
	if isempty(inp.state.downonce.wasup)
		inp.state.downonce.wasup	= ~s;
	end
%get the indices to test
	[kGood,kBad]	= inp.Get(strButton);
%should we just reset?
	if isequal(bLog,'reset')
		kReset								= unique(append(kGood{:}));
		inp.state.downonce.wasup(kReset)	= false;
		return;
	end
%test the bad buttons
	err	= p_TestBad(inp,s,t,strButton,kBad,bLog);
	if err
		kReset								= unique(append(kGood{:}));
		inp.state.downonce.wasup(kReset)	= false;
		return;
	end
%test the good buttons
	nGood	= numel(kGood);
	for kG=1:nGood
		if all(inp.state.downonce.wasup(kGood{kG}) & s(kGood{kG}))
			kState	= kGood{kG};
			b		= true;
			
			inp.state.downonce.wasup(kGood{kG})	= false;
		elseif all(~s(kGood{kG}))
			inp.state.downonce.wasup(kGood{kG})	= true;
		end
	end
%add a log entry
	if b && bLog
		inp.AddLog(['down: ' tostring(strButton)],t);
	end
