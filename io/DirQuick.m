function cPath = DirQuick(strDir,varargin)
% DirQuick
% 
% Description:	quickly find a subset of files in a directory.  This is actually
%				only quicker for directories with many files.  For directories
%				with few files it is much slower.
% 
% Syntax:	cFiles = DirQuick(strDir,<options>)
% 
% In:
%	<options>:
%		'subdir':	(false) true to get the entire directory tree
%		'wildcard':	(<none>) wildcard for file pattern matching
%		'ksubset':	(<all>) the indices of the entries to return
%		'getfiles':	(true) true to return files
%		'getdirs':	(false) true to return directories
%		'fullpath':	(true) true to return the full file paths
% 
% Out:
% 	cPath - a cell of file names or full file paths to the files found
% 
% Updated:	2010-03-05
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgsOpt(varargin,...
		'subdir'	, false	, ...
		'wildcard'	, []	, ...
		'ksubset'	, []	, ...
		'getfiles'	, true	, ...
		'getdirs'	, false	, ...
		'fullpath'	, true	  ...
		);

bRetAll		= opt.getfiles & opt.getdirs;
bRetFiles	= opt.getfiles & ~opt.getdirs;
bRetDirs	= ~opt.getfiles & opt.getdirs;
bRetNone	= ~opt.getfiles & ~opt.getdirs;

if bRetNone
	cPath	= {};
	return;
end
	
%construct the command
	strDir		= AddSlash(strDir);
	strOption	= '';
	if ispc
		if bRetAll
			strOption	= '';
		elseif bRetFiles
			strOption	= ' /a:-d';
		elseif bRetDirs
			strOption	= ' /a:d';
		end
		if opt.subdir
			strOption	= [strOption ' /S'];
			bAddDir		= false;
		else
			bAddDir		= true;
		end
		strCommand	= ['dir ' strDir opt.wildcard ' /B' strOption];
	elseif isunix || ismac
		strOption	= '';
		if ~opt.subdir
			strOption	= [strOption ' -maxdepth 1'];
		end
		if bRetFiles
			strOption	= [strOption ' -type f'];
		elseif bRetDirs
			strOption	= [strOption ' -type d'];
		end
		
		bAddDir	= false;
		
		strCommand	= ['find ' strDir opt.wildcard ' ' strOption];
	else
		error('Function not implemented for your operating system');
	end
%execute the command
	[s,strResult]	 = system(strCommand);
	if s~=0
		strResult	= '';
	end
%parse the results
	if ~isempty(strResult)
		%split by line breaks
			cPath	= split(strResult,'\r\n|\n');
			nFile	= numel(cPath);
		%only keep the specified subset
			if isempty(opt.ksubset)
				opt.ksubset	= 1:nFile;
			end
			cPath	= cPath(opt.ksubset);
		%add/remove the directory
			if opt.fullpath && bAddDir
				cPath	= cellfun(@(x) DirAppend(strDir,x),cPath,'UniformOutput',false);
			elseif ~opt.fullpath && ~bAddDir
				cPath	= cellfun(@(x) PathAbs2Rel(x,strDir),cPath,'UniformOutput',false);
			end
		%add trailing slashes to directories
			if opt.fullpath && opt.getdirs
				if opt.getfiles
					bDir	= cellfun(@isdir,cPath);
				else
					bDir	= true(size(cPath));
				end
				
				cPath(bDir)	= cellfun(@AddSlash,cPath(bDir),'UniformOutput',false);
			end
	else
		cPath	= {};
	end

