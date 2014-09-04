function [b,err,t,kState] = Down(inp,strButton,varargin)
% PTB.Device.Input.Down
% 
% Description:	test if a button is down
% 
% Syntax:	[b,err,t,kState] = inp.Down(strButton,[bLog]=true)
% 
% In:
%	strButton	- the button name
%	[bLog]		- true to add a log event if the button is down
%
% Out:
%	b		- true if the button is down, or false if err==true
%	err		- true if any of the bad buttons were down
%	t		- the time associated with the query
%	kState	- if b is true, an array of the state indices that were down
%
% Updated: 2011-12-24
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
bLog	= ParseArgs(varargin,true);

b		= false;
kState	= [];

%get the input state
	[s,t]	= inp.State;
%get the indices to test
	[kGood,kBad]	= inp.Get(strButton);
%test the bad buttons
	err	= p_TestBad(inp,s,t,strButton,kBad,bLog);
	if err
		return;
	end
%test the good buttons
	nGood	= numel(kGood);
	if nGood==0
		b	= true;
	else
		for kG=1:nGood
			if isempty(kGood{kG}) || all(s(kGood{kG}))
				kState	= kGood{kG};
				b		= true;
				break;
			end
		end
	end
%add a log entry
	if b && bLog
		inp.AddLog(['down: ' tostring(strButton)],t);
	end
