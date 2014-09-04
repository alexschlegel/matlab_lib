function strDirFunctional = GetDirFunctional(strDirRoot,strSession)
% GetDirFunctional
% 
% Description:	get a session's base functional directory, given the root
%				session path or the root experimental path and the session code
% 
% Syntax:	strDirFunctional = GetDirFunctional(strDirRoot,strSession)
% 
% Updated:	2009-07-29
% Copyright 2009 Alex Schlegel (alex@roguecheddar.com).  All Rights Reserved.
strDirSession		= GetDirSession(strDirRoot,strSession);
strDirFunctional	= AddSlash([strDirSession 'FUNCTIONAL']);
