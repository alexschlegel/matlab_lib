function bSuccess = CreateDirPath(strDir,varargin)
% CreateDirPath
% 
% Description:	create a directory path
% 
% Syntax:	bSuccess = CreateDirPath(strDir,<options>)
% 
% In:
% 	strDir	- a directory path to create
%	<option>:
%		error:	(false) true to raise an error if the directory could not be
%				created
% 
% Out:
% 	bSuccess	- true if successful, false otherwise
% 
% Updated:	2013-03-09
% Copyright 2013 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
persistent optDefault cOptDefault

if isempty(optDefault)
	optDefault	= struct(...
					'error'	, false	  ...
					);
	cOptDefault	= opt2cell(optDefault);
end

if numel(varargin)>0
	opt	= ParseArgs(varargin,cOptDefault{:});
else
	opt	= optDefault;
end

if ~exist(strDir,'dir')
	bSuccess	= false;
	
	cDir	= DirSplit(AddSlash(strDir));
	nDir	= numel(cDir);
	for kDir=1:nDir
		strDirCur	= DirUnsplit(cDir(1:kDir));
		
		if ~isdir(strDirCur) && ~mkdir(strDirCur)
			if opt.error
				error(['Could not create directory "' tostring(strDirCur) '"']);
			end
			
			return;
		end
	end
end

bSuccess	= true;
