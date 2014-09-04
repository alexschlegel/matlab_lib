function b = ispid(pid)
% ispid
% 
% Description:	test for the existence of a PID
% 
% Syntax:	b = ispid(pid)
% 
% Updated: 2013-07-28
% Copyright 2013 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
[ec,res]	= system(['kill -0 ' num2str(pid)]);
b			= ec==0;
