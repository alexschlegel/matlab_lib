function [bSuccess,strPathBackup] = backup(strPath,varargin)
% backup
% 
% Description:	backup a file
% 
% Syntax:	[bSuccess,strPathBackup = backup(strPath,<options>)
% 
% In:
% 	strPath	- the path to the file
%	<options>:
%		backup_path:	(<auto>) the path to which to backup the file
% 
% Out:
% 	bSuccess		- true if the file was successfully backed up
%	strPathBackup	- the backed up path
% 
% Updated: 2011-02-19
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgs(varargin,...
		'backup_path'	, []	  ...
		);

if isempty(opt.backup_path)
	kTest		= -1;
	bContinue	= true;
	
	while bContinue
		kTest			= kTest+1;
		strPathBackup	= PathAddSuffix(strPath,['-' StringFill(kTest,4)]);
		bContinue		= FileExists(strPathBackup);
	end
else
	strPathBackup	= opt.backup_path;
end

%copyfile errors when permissions can't be set properly
	bSuccess	= copyfile(strPath,strPathBackup) | FileExists(strPathBackup);
