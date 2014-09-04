function strDirMRIcron = GetDirMRIcron()
% GetDirMRIcron
% 
% Description:	get the MRIcron directory
% 
% Syntax:	strDirMRIcron = GetDirMRIcron()
% 
% Out:
% 	strDirMRIcron	- the MRIcron directory
% 
% Updated: 2011-02-12
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
if isunix
	strDirMRIcron	= DirAppend('/','usr','share','mricron');
	
	if isdir(strDirMRIcron)
		return;
	end
else
	strDirMRIcron	= DirAppend('C:','Program Files','MRIcroN');
	if isdir(strDirMRIcron)
		return;
	end
	
	strDirMRIcron	= DirAppend('C:','Programs','Research','MRIcroN');
	if isdir(strDirMRIcron)
		return;
	end
end

error('Could not find the MRIcron directory.');
