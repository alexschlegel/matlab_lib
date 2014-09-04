function strDirAnatomical = GetDirAnatomical(strDirRoot,strSession)
% GetDirAnatomical
% 
% Description:	get a session's base anatomical directory, given the root
%				session path or the root experimental path and the session code
% 
% Syntax:	strDirAnatomical = GetDirAnatomical(strDirRoot,strSession)
% 
% Updated:	2009-07-29
% Copyright 2009 Alex Schlegel (alex@roguecheddar.com).  All Rights Reserved.
strDirSession		= GetDirSession(strDirRoot,strSession);
strDirAnatomical	= AddSlash([strDirSession 'ANATOMICAL']);
