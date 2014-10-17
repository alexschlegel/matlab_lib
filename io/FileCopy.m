function b = FileCopy(strPathFrom,strPathTo,varargin)
% FileCopy
% 
% Description:	copy a file (more robust than copyfile)
% 
% Syntax:	b = FileCopy(strPathFrom,strPathTo,<options>)
% 
% In:
% 	strPathFrom	- the source file path
%	strPathTo	- the destination file path
%	<options>:
%		createpath:	(false) true to create the directory path if necessary
%		error:		(false) true to raise an error if the file could not be
%					copied
% 
% Out:
% 	b	- true if the file was successfully copied
% 
% Updated: 2011-06-10
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgs(varargin,...
		'createpath'	, false	, ...
		'error'			, false	  ...
		);

%first try to delete the destination file
	bDeleted	= DeleteCheck(strPathTo);
%create the output directory path
	if opt.createpath
		strDir	= PathGetDir(strPathTo);
		b		= CreateDirPath(strDir,'error',opt.error);
	else
		b		= true;
	end
%now try to copy.  in Linux copyfile returns 0 if the permissions couldn't be
%transferred, even if the file was successfully copied
	if b
		b	= copyfile(strPathFrom,strPathTo) || (bDeleted && FileExists(strPathTo));
	end
	
	if ~b && opt.error
		error(['Could not copy file "' strPathFrom '" to "' strPathTo '".']);
	end
