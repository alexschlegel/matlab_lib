function strVer = PARRECGetVersion(strPAR)
% PARRECGetVersion
% 
% Description:	get the version of a PAR file
% 
% Syntax:	strVer = PARRECGetVersion(strPathPAR) OR
%			strVer = PARRECGetVersion(strPAR)
% 
% In:
% 	strPathPAR	- path to a PAR file
%	strPAR		- contents of the PAR file
% 
% Out:
% 	strVer	- the version (or [] if one couldn't be determined)
% 
% Updated: 2010-02-24
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

%read the header
	if exist(strPAR,'file')
		strPAR	= fget(strPAR);
	end
%find the version string
	re		= 'Research image export tool\s+V(?<ver>[\d\.]+)';
	res		= regexp(strPAR,re,'names');
	if isempty(res)
		strVer	= [];
	else
		strVer	= res.ver;
	end
