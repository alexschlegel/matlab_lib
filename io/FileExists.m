function [b,strPathFile] = FileExists(strPath,varargin)
% FileExists
% 
% Description:	determine if a file exists
% 
% Syntax:	[b,strPathFile] = FileExists(strPath,[re]='.*',<options>)
% 
% In:
% 	strPath	- either a path to a file, or a path to a directory in which to
%			  search for the file, or a cell of file or directory paths.  If a
%			  cell of file paths is passed, checks to see if each file exists.
%			  If a cell of directory paths exist, searches for the specified
%			  file in all directories
%	[re]	- a regular expression pattern for file names to match
%	<options>:
%		subdir:		(false) true to also search subdirectories
%		casei:		(false) true to use case-insensitive matches
%		negate:		(false) true to search for a file that doesn't match re
%		usequick:	(false) true to use DirQuick (faster for directories
%					with lots of files, slower for directories with few files)
%		error:		(false) true to raise an error if any of the files don't
%					exist
% 
% Out:
% 	b			- if file paths were passed, a logical array indicating which
%				  files exist.  otherwise a logical value indicating if the
%				  specified file was found
%	strPathFile	- if directories are passed, the path to the found file if one
%				  exists.  note that not more than one file is returned.
% 
% Example:	%check to see if strPathFile exists
%				b = FileExists(strPathFile);
%			%search for a .txt file in or under strDir
%				[b,strPathFile] = FileExists(strDir,'\.txt$','subdir',true)
% 
% Updated:	2013-02-04
% Copyright 2013 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
persistent reDefault optDefault cOptDefault;

if isempty(optDefault)
	reDefault		= '.*';
	optDefault		= struct(...
						'subdir'		, false	, ...
						'casei'			, false	, ...
						'negate'		, false	, ...
						'usequick'		, false	, ...
						'error'			, false	  ...
						);
	cOptDefault		= Opt2Cell(optDefault);
end

if numel(varargin)>0
	[re,opt]	= ParseArgs(varargin,reDefault,cOptDefault{:});
else
	re		= reDefault;
	opt		= optDefault;
end

strPath	= ForceCell(strPath);
nPath	= numel(strPath);

%do we search for files or check to see if files exist?
	bDir	= ~isempty(strPath) && all(cellfun(@isdir,strPath(:)));
%search for a file
	if bDir
		%search each directory
			for kP=1:nPath
				%does the file exist in this directory?
					strPathFile	= FindFiles(strPath{kP},re,'casei',opt.casei,'negate',opt.negate,'usequick',opt.usequick);
					if ~isempty(strPathFile)
						b			= true;
						strPathFile	= strPathFile{1};
						return;
					end
				%does the file exist in a subdirectory?
					if opt.subdir
						cSubDir	= FindDirectories(strPath{kP},'usequick',opt.usequick);
						nSubDir	= numel(cSubDir);
						for kS=1:nSubDir
							[b,strPathFile]	= FileExists(cSubDir{kS},varargin{:});
							if b
								return;
							end
						end
					end
			end
		%none exists
			b			= false;
			strPathFile	= '';
%check to see if files exist
	else
		b	= logical(cellfun(@(x) exist(x,'file'),strPath));
		
		if opt.error & ~all(b(:))
			error(['The following files do not exist: ' 10 join(strPath(~b),10)]);
		end
	end
