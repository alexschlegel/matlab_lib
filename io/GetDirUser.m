function strDirUser = GetDirUser()
% GetDirUser
% 
% Description:	get a user's home directory
% 
% Syntax:	strDirUser = GetDirUser()
% 
% Updated: 2015-03-22
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
if ispc
	strDirUser	= getenv('USERPROFILE');
else
	strDirUser	= getenv('HOME');
	
	if isempty(strDirUser)
		try
			[ec,strUser]	= system('whoami');
			strUser			= StringTrim(strUser);
			if ~isempty(strUser)
				strDirUser	= DirAppend('/home/',strUser);
			end
		catch
		end
	end
end

if ~isdir(strDirUser)
	strDirUser	= '';
end
