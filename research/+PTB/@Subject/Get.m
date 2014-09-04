function x = Get(sub,strName)
% PTB.Subject.Get
% 
% Description:	retrieve stored subject info
% 
% Syntax:	x = sub.Get(strName)
%
% In:
%	strName	- the name of the info
% 
% Updated: 2011-12-10
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
x	= sub.parent.Info.Get('subject',strName);
