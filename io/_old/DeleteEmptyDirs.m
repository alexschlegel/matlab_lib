function cDelete = DeleteEmptyDirs(strDir,varargin)
% DeleteEmptyDirs
% 
% Description:	delete empty subdirectories of the given directory
% 
% Syntax:	cDelete = DeleteEmptyDirs(strDir,<options>)
% 
% In:
% 	strDir		- a directory path or cell of directory paths
%	<options>:
%		'usequick':	(false) true to use DirQuick, which is faster for
%					directories with many files
% 
% Out:
% 	cDelete	- a cell of the deleted directory paths
% 
% Updated:	2009-07-29
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgs(varargin,...
		'usequick'	, false	  ...
		);

cDelete	= {};

strDir	= ForceCell(strDir);

%remove arguments that are subdirectories of other arguments
	bSubDir			= IsSubDir(strDir,strDir);
	strDir(bSubDir)	= [];

nDir	= numel(strDir);
for kDir=1:nDir
	if exist(strDir{kDir},'dir')
		%first check subdirectories
			cSubDir	= FindDirectories(strDir{kDir});
			nSubDir	= numel(cSubDir);
			for kSub=1:nSubDir
				cDelete	= [cDelete; DeleteEmptyDirs(cSubDir{kSub},varargin{:})];
			end
			
		%now check the directory
			if IsDirEmpty(strDir{kDir},'usequick',opt.usequick)
				if ~rmdir(strDir{kDir})
					error(['Could not remove directory ' strDir{kDir}]);
				end
				
				cDelete	= [cDelete;strDir(kDir)];
			end
	end
end
