function strPath = PathRemoveSuffix(strPath,strSuffix,varargin)
% PathRemoveSuffix
% 
% Description:	remove a suffix from the pre-extension file name of strPath,
%				possibly changing its extension at the same time
% 
% Syntax:	strPath = PathRemoveSuffix(strPath,strSuffix,[strExtNew]=<keep>,<options>)
% 
% In:
% 	strPath		- a path to a file
%	strSuffix	- the suffix to remove from the end of the pre-extension file
%				  name
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
% Updated:	2011-11-12
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

%remove the suffix if it exists
	nSuffix			= numel(strSuffix);
	if isequal(strFile(end-nSuffix+1:end),strSuffix)
		strFile	= strFile(1:end-nSuffix);
	end

strPath	= PathUnsplit(strDir,strFile,strExt);
