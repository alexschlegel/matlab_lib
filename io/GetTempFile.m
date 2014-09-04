function strPathTemp = GetTempFile(varargin)
% GetTempFile
% 
% Description:	get the path to a non-existent temporary file
% 
% Syntax:	strPathTemp = GetTempFile(<options>)
% 
% In:
% 	<options>:
%		ext:	(<none>) the extension of the file to return
%		base:	(<none>) the base path of the file
% 
% Out:
% 	strPathTemp	- path to the temporary file
% 
% Updated:	2013-02-04
% Copyright 2013 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
if nargin==0
	strPathTemp	= tempname;
	return;
end

%the strExt is left in for backward compatibility with a previous version of the
%function
[strExt,opt]	= ParseArgsOpt(varargin,[],...
					'ext'	, []		, ...
					'base'	, tempname	  ...
					);

if ~isempty(strExt)
	opt.ext	= strExt;
end

k			= 0;
strPathTemp	= NextTemp;
while exist(strPathTemp,'file')
	strPathTemp	= NextTemp;
end

%------------------------------------------------------------------------------%
function strPathTemp = NextTemp()
	k			= k + 1;
	strPathTemp	= PathAddSuffix(opt.base,['-temp' StringFill(k,3)],opt.ext);
end
%------------------------------------------------------------------------------%

end
