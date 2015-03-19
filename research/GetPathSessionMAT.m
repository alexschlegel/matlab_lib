function strPathSession = GetPathSessionMAT(strDirData,strSession)
% GetPathSessionMAT
% 
% Description:	get the path to a subject's session .mat file
% 
% Syntax:	strPathSession = GetPathSessionMAT(strDirData,strSession)
% 
% In:
% 	strDirData	- the root data directory
%	strSession	- the session code
% 
% Out:
% 	strPathSession	- the path to the session .mat file
% 
% Updated: 2015-03-10
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
if isempty(strSession)
	strPathSession	= '';
else
	strPathSession	= PathUnsplit(strDirData,strSession,'mat');
end
