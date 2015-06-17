function id = GetWorkerID()
% GetWorkerID
% 
% Description:	get the id of a parallel computing worker
% 
% Syntax:	id = GetWorkerID()
% 
% Updated: 2015-06-08
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
t	= getCurrentTask;

if ~isempty(t)
	id	= t.ID;
else
	id	= [];
end
