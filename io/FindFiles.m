function [cPath,cDir,nPath] = FindFiles(strDir,varargin)
% FindFiles
% 
% Description:	find files within a directory path that match a regular
%				expression
% 
% Syntax:	[cPath,[cDir],[nPath]] = FindFiles(strDir,[re]='.*',<options>)
%
% In:
%	strDir		- a directory or cell of directories
%	[re]		- a regular expression pattern for file names to match
%	<options>:
%		'subdir':		(false) true to also search subdirectories
%		'casei':		(false) true to use case-insensitive matches
%		'negate':		(false) true to return files that don't match re
%		'usequick':		(false) true to use DirQuick (faster for directories
%						with lots of files, slower for directories with few
%						files)
%		'groupbydir':	(false) true to group results by directory
%		'progress':		(false) true to show a progress bar
% 
% Out:
%	cPath	- a cell of the matching file paths in strDir.  If the 'groupbydir'
%			  option is true, each element of cPath is a cell of full paths in
%			  the directory specified by the corresponding element of cDir.
%	[cDir]	- if the 'groupbydir' option is true, a cell of directory paths
%			  corresponding to the grouped file paths in cPath
%	[nPath]	- if the 'groupbydir' option is true, the total number of files
%			  found
%
% Example:
%	FindFiles('c:\','\.txt$') will find all .txt files in the root
%	directory
% 
% Updated: 2015-04-08
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

[re,opt]	= ParseArgs(varargin, '.*', ...
				'subdir'		, false	, ...
				'casei'			, false	, ...
				'negate'		, false	, ...
				'usequick'		, false	, ...
				'groupbydir'	, false	, ...
				'progress'		, false	  ...
				);

%get the regexp function to use
	if opt.casei
		if opt.negate
			refunc	= @priv_REIN;
		else
			refunc	= @priv_REIP;
		end
	else
		if opt.negate
			refunc	= @priv_RECN;
		else
			refunc	= @priv_RECP;
		end
	end

%get the directories to search
	cDir	= reshape(ForceCell(strDir),[],1);
	nDir	= numel(cDir);
	
	%add trailing slashes
		for kDir=1:nDir
			cDir{kDir}	= AddSlash(cDir{kDir},false);
		end
	
	%get sub directories
		if opt.subdir
			cDir	= [cDir; FindDirectories(cDir,'subdir',true,'usequick',opt.usequick,'progress',opt.progress)];
			nDir	= numel(cDir);
		end

%search each directory
	if opt.groupbydir
		cPath	= cell(nDir,1);
		nPath	= 0;
	else
		cPath	= {};
	end
	
	if opt.progress
		progress('action','init','total',nDir,'label','Searching for Files');
	end
	
	for kDir=1:nDir
		%get the names of the files in the current directory
			if opt.usequick
				cFile	= DirQuick(cDir{kDir},'fullpath',false);
			else
				d		= dir(cDir{kDir});
				cFile	= reshape({d.name},[],1);
				cFile	= cFile(~[d.isdir]);
			end
			nFile	= numel(cFile);
			
		%filter out the ones that don't match the regexp
			bKeep	= false(nFile,1);
			for kFile=1:nFile
				bKeep(kFile)	= refunc(cFile{kFile},re);
			end
		
		%add the matching file paths
			cFile	= cFile(bKeep);
			nFile	= numel(cFile);
			
			for kFile=1:nFile
				cFile{kFile}	= [cDir{kDir} cFile{kFile}];
			end
			
			if nFile>0
				if opt.groupbydir
					cPath{kDir}	= cFile;
					nPath		= nPath + numel(cFile);
				else
					cPath		= [cPath; cFile];
				end
			end
			
		if opt.progress
			progress;
		end
	end
%total number of files
	if ~opt.groupbydir
		nPath	= numel(cPath);
	end

	
%------------------------------------------------------------------------------%
function b = priv_REIN(str,re)
	b	= isempty(regexpi(str,re));
%------------------------------------------------------------------------------%
function b = priv_REIP(str,re)
	b	= ~isempty(regexpi(str,re));
%------------------------------------------------------------------------------%
function b = priv_RECN(str,re)
	b	= isempty(regexp(str,re));
%------------------------------------------------------------------------------%
function b = priv_RECP(str,re)
	b	= ~isempty(regexp(str,re));
%------------------------------------------------------------------------------%
