function strCode = PathFindSessionCode(strPath)
% PathFindSessionCode
% 
% Description:	find the session code in a file path
% 
% Syntax:	strCode = PathFindSessionCode(strPath)
% 
% Updated: 2012-03-11
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
re	= '(?<code>\d\d\w\w\w\d\d\w{2,3})';

%first look in the directories
	[strDir,strFile]	= PathSplit(strPath);

	res	= regexp(strDir,re,'names');
	
	if ~isempty(res)
		strCode	= res.code;
		return;
	end
%now look in the file name
	res	= regexp(strFile,re,'names');
	
	if ~isempty(res)
		strCode	= res.code;
		return;
	end
%no dice
	strCode	= '';
