function DirectoryTransfer(f,strDirFrom,strDirTo,varargin)
% Data.FTP.DirectoryTransfer
% 
% Description:	transfer an FTP directory to a local directory
% 
% Syntax:	Data.FTP.DirectoryTransfer(f,strDirFrom,strDirTo,<options>)
% 
% In:
% 	f			- an open ftp object
%	strDirFrom	- the directory on the server to transfer
%	strDirTo	- the local directory to transfer to
%	<options>:
%		overwrite:	(false) false to overwrite files that already exist
% 
% Updated: 2013-03-09
% Copyright 2013 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'overwrite'	, false	  ...
		);

CreateDirPath(strDirTo);

cd(f,strDirFrom);

sPath		= dir(f);
nPath		= numel(sPath);
strNPath	= num2str(nPath);
nFill		= numel(strNPath);

for kP=1:nPath
	strKP	= StringFill(kP,nFill);
	
	strPathTo	= PathUnsplit(strDirTo,sPath(kP).name);
	
	if opt.overwrite || ~FileExists(strPathTo)
		status(['transferring (' strKP '/' strNPath ', ' num2str(sPath(kP).bytes) ' bytes): ' sPath(kP).name]);
		mget(f,sPath(kP).name,strDirTo);
	else
		status(['transferring (' strKP '/' strNPath ', exists): ' sPath(kP).name]);
	end
end
