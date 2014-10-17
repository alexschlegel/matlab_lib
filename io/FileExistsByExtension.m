function [b,strPathFile] = FileExistsByExtension(strDir,varargin)
% FileExistsByExtension
% 
% Description:	determine if a file with specified extension exists
% 
% Syntax:	[b,strPathFile] = FileExistsByExtension(strDir,[cExt]=<all>,<options>))
%
% In:
%	strDir		- a directory path or a cell of directory paths
%	[cExt]		- a file extension a cell of file extensions to match
%	<options>:
%		subdir:		(false) true to also search subdirectories
%		casei:		(true) true to use case-insensitive matches
%		negate:		(false) true to return files that don't match re
%		usequick:	(false) true to use DirQuick (faster for directories
%					with lots of files, slower for directories with few files)
% 
% Out:
% 	b			- otherwise a logical value indicating if the specified file was
%				  found
%	strPathFile	- the path to the found file if one exists.  note that not more
%				  than one file is returned.
% 
% Updated:	2011-02-10
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
[cExt,opt]	= ParseArgs(varargin,{},...
				'subdir'	, false	, ...
				'casei'		, true	, ...
				'negate'	, false	, ...
				'usequick'	, false	  ...
				);

reExt	= RegExpFileExtensions(cExt);

cOpt			= Opt2Cell(opt);
[b,strPathFile]	= FileExists(strDir,reExt,cOpt{:});
