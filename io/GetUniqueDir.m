function [strDir,strName] = GetUniqueDir(strDirBase,varargin)
% GetUniqueDir
% 
% Description:	get a unique directory of the specified base directory
% 
% Syntax:	[strDir,strName] = GetUniqueDir(strDirBase,<options>)
% 
% In:
% 	strDirBase	- the base directory
%	<options>:
%		create:	(true) true to create the directory
%		error:	(false) true to raise an error if the directory could not be
%				created
% 
% Out:
% 	strDir	- a path to the unique directory
%	strName	- the name of the unique directory
% 
% Updated:	2011-03-20
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgs(varargin,...
		'create'	, true	, ...
		'error'		, false	  ...
		);

%get the name of a unique subdirectory
	strBase	= FormatTime(nowms,'yyyymmdd');
	
	bContinue	= true;
	k			= round(randBetween(0,1000000));
	while bContinue
		k	= k + 1;
		
		strName	= [strBase '_' num2str(k)];
		strDir	= DirAppend(strDirBase,strName);
		
		bContinue	= isdir(strDir);
	end
%create the directory
	if opt.create
		CreateDirPath(strDir,'error',opt.error);
	end
