function d = GetNextProbe(obj,s)
% subject.assess.base.GetNextProbe
% 
% Description:	calculate the next probe value for a task, between 0 and 1
% 
% Syntax: d = obj.GetNextProbe(s)
%
% In:
%	s	- a struct of info about the task to probe (see GetTaskInfo)
%
% Out:
%	d	- the next probe difficulty
% 
% Updated:	2015-12-04
% Copyright 2015 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
d	= obj.d(randi(numel(obj.d)));
