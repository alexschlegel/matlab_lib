function [cPath,cDir,nPath] = FindFilesByExtension(strDir,varargin)
% FindFilesByExtension
% 
% Description:	return the paths of files in a directory or directories
% 
% Syntax:	[cPath,[cDir],[nPath]] = FindFilesByExtension(strDir,[cExt]=<all>,<options>))
%
% In:
%	strDir		- a directory path or a cell of directory paths
%	[cExt]		- a file extension or a cell of file extensions to match, or one
%				  of the following strings:
%					'image':	return image files
%	<options>:
%		'subdir':		(false) true to also search subdirectories
%		'casei':		(true) true to use case-insensitive matches
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
% Updated:	2011-03-01
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
[cExt,opt]	= ParseArgsOpt(varargin,{},'casei',[]);

if isempty(opt.casei)
	varargin	= [varargin {'casei' 'true'}];
end

reExt	= RegExpFileExtensions(cExt);

[cPath,cDir,nPath]	= FindFiles(strDir,reExt,varargin{2:end});
