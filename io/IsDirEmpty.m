function b = IsDirEmpty(strDir,varargin)
% IsDirEmpty
% 
% Description:	return true if directory strDir is empty
% 
% Syntax:	b = IsDirEmpty(strDir,<options>)
%
% In:
%	strDir	- the directory in question
%	<options>:
%		'usequick':	(false) true to use DirQuick, which is faster for
%					directories with many files
% 
% Updated:	2009-07-29
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgsOpt(varargin,...
		'usequick'	, false	  ...
		);

if opt.usequick
	b	= isempty(DirQuick(strDir,'getdirs',true));
else
	%if the dir function returns less than three values (i.e. . and ..), it's empty
		b	= numel(dir(strDir))<3;
end
