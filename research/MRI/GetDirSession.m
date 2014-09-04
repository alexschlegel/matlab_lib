function strDirSession = GetDirSession(strDirRoot,strSession)
% GetDirSession
% 
% Description:	get a session's base directory, given the root experiment path
% 
% Syntax:	strDirSession = GetDirSession(strDirRoot,strSession)
% 
% Updated:	2009-07-29
% Copyright 2009 Alex Schlegel (alex@roguecheddar.com).  All Rights Reserved.
strDirSession	= AddSlash([AddSlash(strDirRoot) strSession]);
