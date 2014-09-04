function b = isworker
% isworker
% 
% Description:	return true if the current MATLAB session is being run by a
%				distcomp worker
% 
% Syntax:	b = isworker
% 
% Updated: 2011-02-18
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
b	= ~isempty(getCurrentTask);
