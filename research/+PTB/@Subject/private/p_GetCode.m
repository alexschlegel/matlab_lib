function strCode = p_GetCode(sub)
% p_GetCode
% 
% Description:	get the subject code
% 
% Syntax:	p_GetCode(sub)
% 
% Updated: 2014-03-14
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
strCode	= sub.Get('code');

if isempty(strCode)
	strInit	= sub.Get('init');
	t		= sub.parent.Info.Get('experiment','start');
	
	strCode	= sessioncode(strInit,t);
end
