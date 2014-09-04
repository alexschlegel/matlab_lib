function [cFiles,cDirSearch] = FindInCode(str,varargin)
% FindInCode
% 
% Description:	find instances of str in files in the code directories
%				(excluding the "_old" directories)
% 
% Syntax:	[cFiles,cDirSearch] = FindInCode(str,[cDirSearch]=<see below>)
% 
% Updated:	2012-11-21
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
cDirSearch	= ParseArgs(varargin,[]);

%get the directories to search
	if isempty(cDirSearch)
		status('Finding directories');
		
		%base code directories
			if isunix
				cDirBase	=	{
									'~/code/MATLAB/lib/'
									'~/studies/'
									'~/projects/Art/work/'
									'~/projects/Graphics/'
								};
			else
				cDirBase	=	{
									'C:\code\MATLAB\lib\'
									'C:\studies\'
									'C:\Projects\Art\work\'
									'C:\Projects\Graphics\'
								};
			end
		%find non '_old' directories
			cDirSearch	= [cDirBase; FindDirectories(cDirBase,'^_old$','subdir',true,'maxdepth',3,'casei',true,'negate',true,'progress',true)];
	end
%get the .m files in the remaining directories
	status('Finding files');
	[cFiles,cDirSearch]	= FindFilesByExtension(cDirSearch,'m','groupbydir',true,'progress',true);
%get one cell for files and directories
	cFiles		= append(cFiles{:});
%search in the .m files
	status('Searching in files');
	cFiles	= SearchInFiles(cFiles,str,true);
