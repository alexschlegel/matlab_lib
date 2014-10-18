function strPath = PathAddPrefix(strPath,strPrefix,varargin)
% PathAddPrefix
% 
% Description:	add a prefix to the pre-extension file name of strPath, possibly
%				changing its extension at the same time
% 
% Syntax:	strPath = PathAddPrefix(strPath,strPrefix,[strExtNew]=<keep>,<options>)
% 
% In:
% 	strPath		- a path to a file
%	strPrefix	- the prefix to add
%	[strExtNew]	- the new file extension
%	<options>:
%		maxext:	(false) true to treat the first period as the start of the
%				extension
%		favor:	(<none>) a cell of extensions to favor when trying to determine
%				the extension of multi-dot file names (e.g. a.b.c.txt)
% 
% Out:
% 	strPath	- strPath altered as specified
% 
% Updated:	2011-10-19
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
[strExtForce,opt]	= ParseArgs(varargin,[],...
						'maxext'	, false	, ...
						'favor'		, []	  ...
						);
cOpt	= opt2cell(opt);
					
[strDir,strFile,strExt]	= PathSplit(strPath,cOpt{:});
if ~isempty(strExtForce)
	strExt	= strExtForce;
end

strFile	= [strPrefix strFile];

strPath	= PathUnsplit(strDir,strFile,strExt);
