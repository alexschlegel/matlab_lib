function p_GetRemoveLock(sch)
% p_GetRemoveLock
% 
% Description:	get a lock on removing from the task list
% 
% Syntax:	p_GetRemoveLock(sch)
% 
% Updated: 2011-12-20
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global PTBIFO;

PTBIFO.scheduler.lock_remove	= PTBIFO.scheduler.lock_remove + 1;
