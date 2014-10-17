function strPathBase = PathGetBase(cPath,varargin)
% PathGetBase
% 
% Description:	get the base file path of a set of files
% 
% Syntax:	strPathBase = PathGetBase(cPath,<options>)
% 
% In:
% 	cPath	- a path/cell of paths
%	<options>:
%		include_file:	(false) true to include the file names when looking for
%						the base
% 
% Out:
% 	strPathBase	- the base path common to all input paths
% 
% Updated: 2012-04-09
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgs(varargin,...
		'include_file'	, false	  ...
		);

cPath	= ForceCell(cPath);
nPath	= numel(cPath);

if nPath==0
	strPathBase	= '';
	return;
end

%get the last common character
	strPath	= char(cPath);
	bSame	= strPath==repmat(strPath(1,:),[nPath 1]);
	kDiff	= find(~all(bSame),1,'first');
	if isempty(kDiff)
		kDiff	= size(strPath,2)+1;
	end
if opt.include_file
	strPathBase	= strPath(1,1:kDiff-1);
else
	%get the preceding path separation character
		strSlash	= GetSlashType(cPath{1});
		kLastSlash	= find(strPath(1,1:kDiff-1)==strSlash,1,'last');
		strPathBase	= strPath(1,1:kLastSlash);
end
