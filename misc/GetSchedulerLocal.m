function sch = GetSchedulerLocal()
% GetSchedulerLocal
% 
% Description:	attempt to retrieve the local scheduler object
% 
% Syntax:	sch = GetSchedulerLocal()
% 
% Out:
% 	sch	- the local scheduler object, or [] if none could be found
% 
% Updated: 2011-03-08
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
try
	if ~isworker
		sch	= findResource('scheduler','type','local');
	else
		sch	= [];
	end
catch me
	sch	= [];
end
