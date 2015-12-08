function AppendProbe(obj,kTask,d,result)
% subject.difficultymatch.AppendProbe
% 
% Description:	append a probe result
% 
% Syntax: obj.AppendProbe(kTask,d,result)
% 
% In:
%	kTask	- the task index
%	d		- the probe difficulty
%	result	- the probe result
%
% Updated:	2015-12-07
% Copyright 2015 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%append the probe to the history
	obj.history(end+1)	= struct(...
							'task'		, kTask				, ...
							'd'			, d					, ...
							'result'	, result			  ...
							);

	%make sure we get N x 1
		if numel(obj.history)==2
			obj.history	= reshape(obj.history,2,1);
		end

%reset the calculated difficulty
	obj.dNext(kTask)	= NaN;
