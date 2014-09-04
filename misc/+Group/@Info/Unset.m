function Unset(ifo,c,x)
% Group.Info.Unset
% 
% Description:	unset info
% 
% Syntax:	ifo.Unset(c,x)
% 
% In:
%	c	- a 1xN cell specifying the path to the info
% 
% Updated: 2011-12-27
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
ifo.Set(c,[]);
