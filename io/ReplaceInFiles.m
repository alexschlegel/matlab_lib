function [cFiles,nReplace] = ReplaceInFiles(varargin)
% ReplaceInFiles
% 
% Description:	replace text in a set of files
% 
% Syntax:	cFiles = ReplaceInFiles(strDir,strSearch,strReplace,[bSubDir]=false,[cExt]=<all>,[bPrompt]=true) OR
%			cFiles = ReplaceInFiles(cFiles,strSearch,strReplace,[bPrompt]=true) 
% 
% In:
% 	strDir		- the directory containing the files to search, or a cell of
%				  directories
%	cFiles		- a cell of paths of the files to search
%	strSearch	- the string to search for
%	strReplace	- the string to replace strSearch with
%	[bSubDir]	- true to search subdirectories
%	[cExt]		- a cell of file extensions of the files to search
%	[bPrompt]	- true to prompt user for verification before replacing
% 
% Out:
% 	cFiles		- a cell of paths of files where strSearch was replaced
%	nReplace	- an array of the number of instances of strSearch that were
%				  replaced in each file
% 
% Updated:	2009-06-03
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

%parse the arguments
	if (ischar(varargin{1}) && isdir(varargin{1})) || (iscell(varargin{1}) && isdir(varargin{1}{1}))
		strDir					= varargin{1};
		[strSearch,strReplace]	= deal(varargin{2:3});
		[bSubDir,cExt,bPrompt]	= ParseArgs(varargin(4:end),false,[],true);
		
		cFiles	= FindFilesByExtension(strDir,cExt,'subdir',bSubDir);
	else
		[cFiles,strSearch,strReplace]	= deal(varargin{1:3});
		[bPrompt]						= ParseArgs(varargin(4:end),true);
	end

%get the files that match
	[cFiles,nFound]	= SearchInFiles(cFiles,strSearch,bPrompt);
	nFiles			= numel(cFiles);
	
%get some info if we're going to prompt
	if bPrompt
		if nFiles==0
			msgbox('No files found.');
			cFiles		= {};
			nReplace	= [];
			return;
		end
		
		strPrompt	= ['Replace "' strSearch '" with "' strReplace '" in the following files?' 10 10];
		
		for kFile=1:nFiles
			strPrompt	= [strPrompt cFiles{kFile} ': ' num2str(nFound(kFile)) ' found' 10];
		end
		
		if ~isequal(questdlg(strPrompt),'Yes')
			cFiles		= {};
			nReplace	= [];
			return;
		end
	end

%replace!
	for kFile=1:nFiles
		str	= fget(cFiles{kFile});
		str	= strrep(str,strSearch,strReplace);
		fput(str,cFiles{kFile});
	end
