function Unset(ifo,strDomain,cPath)
% PTB.Info.Unset
% 
% Description:	unset an info value
% 
% Syntax:	ifo.Unset(strDomain,cPath)
% 
% In:
%	strDomain	- the domain of the info (e.g. 'subject')
%	cPath		- the path to the info, either a string or cell of strings
% 
% Updated: 2011-12-11
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
ifo.Set(strDomain,cPath,[]);
