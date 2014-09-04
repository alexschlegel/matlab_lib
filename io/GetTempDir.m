function strDir = GetTempDir(varargin)
% GetTempDir
% 
% Description:	get a temporary directory
% 
% Syntax:	strDir = GetTempDir([strDirBase]=tempdir,<options>)
% 
% In:
% 	[strDirBase]	- the base directory.
%	<options>:
%		create:	(true) true to create the directory
% 
% Out:
% 	strDir	- a temporary directory
% 
% Updated:	2011-01-21
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
[strDirBase,opt]	= ParseArgsOpt(varargin,tempdir,...
						'create'	, true	  ...
						);

%get a unique subdirectory and create it
	k		= round(randBetween(1,1e9));
	strDir	= DirAppend(strDirBase,['temp' num2str(k)]);
	
	while isdir(strDir)
		k		= k + 1;
		strDir	= DirAppend(strDirBase,['temp' num2str(k)]);
	end

%create the directory
	if opt.create
		CreateDirPath(strDir);
	end
