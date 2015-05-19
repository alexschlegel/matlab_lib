% PrepDCC
% 
% Description:	sets up a Directed Connectivity Classification work session
% 
% Updated: 2015-05-18
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global study strDirBase strDirCode strDirData strDirAnalysis
PrepExperiment('dcclassify');

%prepare the fieldtrip environment
	ft_defaults;
	
	%stupid fieldtrip has a function named progress
		strPathProgress	= which('progress');
		if regexp(strPathProgress,'fieldtrip')
			status('removing fieldtrip compat directory from path');
			rmpath(PathGetDir(strPathProgress));
		end
		
		clear strPathProgress;