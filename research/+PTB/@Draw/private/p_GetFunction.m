function f = p_GetFunction(drw,f,bTime,bInput,strProp)
% p_GetFunction
% 
% Description:	get a function handle based on a user-defined function
% 
% Syntax:	f = p_GetFunction(drw,f,bTime,bInput,strProp)
% 
% In:
%	drw		- the PTB.Draw object
% 	f		- the function (see PTB.Draw options)
%	bTime	- true if the function can be a time
%	bInput	- true if the function can be an input button name
%	strProp	- the property name in case an error occurs
% 
% Out:
%	f	- the actual function associated with f
% 
% Updated: 2012-11-27
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
if ~isa(f,'function_handle')
	if bTime && isnumeric(f)
		if f < PTB.Now - 24*60*60*1000
		%if the time is less than a day ago, it must be relative
			f	= @(tNow,tStart) FByTime(tNow,tStart,tStart+f);
		else
		%absolute time
			f	= @(tNow,tStart) FByTime(tNow,tStart,f);
		end
	elseif bInput && ischar(f)
		f	= @(tNow,tStart) drw.parent.Input.Down(f,false);
	else
		error(['Invalid ' strProp '.']);
	end
end

%------------------------------------------------------------------------------%
function [b,tRemain,tTotal] = FByTime(tNow,tStart,tTotal)
	b		= tNow>=tTotal;
	tRemain	= tTotal-tNow;
%------------------------------------------------------------------------------%
