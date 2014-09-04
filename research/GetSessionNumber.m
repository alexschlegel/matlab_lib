function kSession = GetSessionNumber(t,tSession)
% GetSessionNumber
% 
% Description:	determine the session number from the experiment date
% 
% Syntax:	kSession = GetSessionNumber(t,tSession)
% 
% In:
% 	t			- the time of the experiment
%	tSession	- an array of session period start times
% 
% Out:
% 	kSession	- the session number for the given time
% 
% Updated: 2011-10-28
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
tSession	= sort(tSession);
kSession	= find(t>=tSession,1,'last');

if isempty(kSession)
	kSession	= 0;
end
