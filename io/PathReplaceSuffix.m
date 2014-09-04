function strPath = PathReplaceSuffix(strPath,strSuffixRemove,strSuffixAdd,varargin)
% PathReplaceSuffix
% 
% Description:	replace a suffix in the pre-extension file name of strPath,
%				possibly changing its extension at the same time
% 
% Syntax:	strPath = PathReplaceSuffix(strPath,strSuffixRemove,strSuffixadd,[strExtNew]=<keep>,<options>)
% 
% In:
% 	strPath			- a path to a file
%	strSuffixRemove	- the suffix to remove from the end of the pre-extension file
%					  name
%	strSuffixAdd	- the suffix to add
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
strPath	= PathAddSuffix(PathRemoveSuffix(strPath,strSuffixRemove,varargin{:}),strSuffixAdd,varargin{:});
