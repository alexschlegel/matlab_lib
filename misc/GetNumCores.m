function n = GetNumCores()
% GetNumCores
% 
% Description:	get the number of cores in the machine (or 1 if the instance of
%				MATLAB calling this function is a worker)
% 
% Syntax:	n = GetNumCores()
% 
% Updated: 2012-11-21
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
n	= 1;

if ~isworker
%try a couple different methods to get the number of processor cores
	try
		import java.lang.*;
		r	= Runtime.getRuntime;
		n	= r.availableProcessors;
	catch me
		try
			n	= feature('numCores');
		catch me
		end
	end
end
