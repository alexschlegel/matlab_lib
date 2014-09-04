function b = IsTimerRunning(tmr)
% IsTimerRunning
% 
% Description:	check if a timer is running
% 
% Syntax:	b = IsTimerRunning(tmr)
% 
% Updated: 2011-12-14
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
try
	b	= isequal(get(tmr,'Running'),'on');
catch me
	b	= false;
end
