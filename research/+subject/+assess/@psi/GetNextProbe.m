function d = GetNextProbe(obj,s)
% subject.assess.psi.GetNextProbe
% 
% Description:	use the 'psi' procedure to get the next probe value for the task
% 
% Syntax: d = obj.GetNextProbe(s)
%
% In:
%	s	- a struct of info about the task to probe (see GetTaskInfo)
%
% Out:
%	d	- the next probe difficulty
% 
% Updated:	2015-12-08
% Copyright 2015 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%get the current probe value
	d	= 1 - obj.PM(s.task).xCurrent;
