function x = Get(ifo,strDomain,cPath)
% PTB.Info.Get
% 
% Description:	retrieve stored info
% 
% Syntax:	x = ifo.Get(strDomain,cPath)
%
% In:
%	strDomain	- the domain of the info (e.g. 'subject')
%	cPath		- the the path to the info, either a string or cell of strings
% 
% Updated: 2011-12-14
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global PTBIFO;

if iscell(cPath)
	x	= GetFieldPath(PTBIFO,strDomain,cPath{:});
else
	x	= GetFieldPath(PTBIFO,strDomain,cPath);
end
