function strPath = PathAddSuffix(strPath,strSuffix,varargin)
% PathAddSuffix
% 
% Description:	add a suffix to the pre-extension file name of strPath, possibly
%				changing its extension at the same time
% 
% Syntax:	strPath = PathAddSuffix(strPath,strSuffix,[strExtNew]=<keep>,<options>)
% 
% In:
% 	strPath		- a path to a file
%	strSuffix	- the suffix to add
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
% Updated:	2011-02-26
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
[strExtForce,opt]	= ParseArgsOpt(varargin,[],...
						'maxext'	, false	, ...
						'favor'		, []	  ...
						);
cOpt	= Opt2Cell(opt);
					
[strDir,strFile,strExt]	= PathSplit(strPath,cOpt{:});
if ~isempty(strExtForce)
	strExt	= strExtForce;
end

strFile	= [strFile strSuffix];

strPath	= PathUnsplit(strDir,strFile,strExt);
