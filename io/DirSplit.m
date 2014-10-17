function cDir = DirSplit(strDir,varargin)
% DirSplit
% 
% Description:	split a directory path into a cell of directories representing
%				the path
% 
% Syntax:	cDir = DirSplit(strDir,<options>)
% 
% In:
% 	strDir	- the directory path
%	<options>:
%		'limit':		(-1) non-negative to limit the output to the specified
%						number of directories
%		'limit_dir':	('reverse') either 'reverse' or 'forward' to specify
%						whether output should be limited from the beginning
%						('reverse') or the start ('forward') of the array
%						
% 
% Out:
% 	cDir	- a cell of directories representing the path
% 
% Example:	DirSplit('c:\temp\blah') => {'c:','temp','blah'}
% 
% Updated:	2010-04-10
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgs(varargin,...
		'limit'			, -1		, ...
		'limit_type'	, 'reverse'	  ...
		);

if isempty(strDir)
	cDir	= {};
	return;
end

%get just the directory
	strDir	= PathGetDir(strDir);

%split based on forward/backslashes
	cDir	= split(strDir,'[\\\/]');
	
%in case the caller passed '\' or '//'
	if strDir(1)=='/'
		cDir	= [{'/'}; cDir];
	elseif isequal(strDir(1:2),'\\')
		cDir	= [{'\\'}; cDir];
	end

%limit the output
	if opt.limit>=0
		switch lower(opt.limit_type)
			case 'reverse'
				cDir	= cDir(end-opt.limit+1:end);
			case 'forward'
				cDir	= cDir(1:opt.limit);
			otherwise
				error(['"' opt.limit_type '" is an unknown limit type.']);
		end
	end