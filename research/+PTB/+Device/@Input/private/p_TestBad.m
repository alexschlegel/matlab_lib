function bError = p_TestBad(inp,s,t,strButton,cBad,bLog)
% p_TestBad
% 
% Description:	test whether a bad button combination is down
% 
% Syntax:	bError = p_TestBad(inp,s,t,strButton,cBad,bLog)
% 
% In:
% 	inp			- the Input object
%	s			- the current input state
%	t			- the time at which the state was queried
%	strButton	- the button name
%	cBad		- the simplified bad button combination
%	bLog		- true to add a log entry if bad buttons are down
% 
% Updated: 2011-12-21
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
persistent bLast;

if isempty(bLast)
	bLast	= false;
end

nBad	= numel(cBad);

bError	= false;
for kB=1:nBad
	if any(s(cBad{kB}))
		bError	= true;
		
		if bLog && ~bLast
			inp.AddLog(['subject error: ' tostring(strButton)],t);
		end
		
		break;
	end
end

bLast	= bError;
