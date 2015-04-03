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
% Updated: 2015-03-24
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%parse the inputs
	opt	= ParseArgs(varargin,...
			'limit'			, -1		, ...
			'limit_type'	, 'reverse'	  ...
			);

%get just the directory
	strDir	= PathGetDir(strDir);

%split based on forward/backslashes
	cDir	= split(strDir,'[\\\/]');
	
%in case the caller passed '/' or '\\'
	if numel(strDir)>0 && strDir(1)=='/'
		cDir	= ['/'; cDir];
	elseif numel(strDir>1) && isequal(strDir(1:2),'\\')
		cDir	= ['\\'; cDir];
	end

%limit the output
	if opt.limit>=0
		nDir	= numel(cDir);
		
		switch lower(opt.limit_type)
			case 'reverse'
				kKeep	= max(1,nDir-opt.limit+1):nDir;
			case 'forward'
				kKeep	= 1:min(nDir,opt.limit);
			otherwise
				error('"%s" is not a valid limit type.',opt.limit_type);
		end
		
		cDir	= cDir(kKeep);
	end
	