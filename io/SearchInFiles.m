function [cFiles,nFound] = SearchInFiles(strDir,strSearch,varargin)
% SearchInFiles
% 
% Description:	search the files in strDir for the string strSearch
% 
% Syntax:	cFiles = SearchInFiles(strDir,strSearch,[bSubDir]=false,[cExt]=<all>,[bDisplay]=false) OR
%			cFiles = SearchInFiles(cFiles,strSearch,[bDisplay]=false)
% 
% In:
% 	strDir		- the directory in which to search, or a cell of directories
%	cFiles		- a cell of paths of the files to search
%	strSearch	- the string for which to search
%	[bSubDir]	- true if sub-directories should also be searched
%	[cExt]		- limit searched files to those with the extensions in cell cExt
%	[bDisplay]	- true to display progress
% 
% Out:
% 	cFiles	- a cell of the files containing the string strSearch
%	nFound	- the number of instances of strSearch found in each file
% 
% Updated:	2010-04-17
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
if (ischar(strDir) && isdir(strDir)) || (iscell(strDir) && numel(strDir)>0 && isdir(strDir{1}))
	[bSubDir,cExt,bDisplay]	= ParseArgs(varargin,false,[],false);
	
	cFiles	= FindFilesByExtension(strDir,cExt,'subdir',bSubDir);
else
	bDisplay	= ParseArgs(varargin,false);
	
	cFiles	= strDir;
end

%find the files with strings matching strSearch
	bKeep	= false(size(cFiles));
	nFound	= zeros(size(cFiles));
	nSearch	= numel(cFiles);
	
	if bDisplay
		progress(nSearch,'label','Searching');
	end
	for kFile=1:nSearch
		if exist(cFiles{kFile},'file')
			strFile	= fget(cFiles{kFile});
			
			nFound(kFile)	= numel(regexp(strFile,strSearch));
			bKeep(kFile)	= nFound(kFile)>0;
			
		end
		
		if bDisplay
			progress;
		end
	end

%keep the matching files
	cFiles	= cFiles(bKeep);
	nFound	= nFound(bKeep);
