function strDirRoot = FreeSurferDirSubjectRoot(varargin)
% FreeSurferDirSubjectRoot
% 
% Description:	return the root FreeSurfer subject directory
% 
% Syntax:	strDirRoot = FreeSurferDirSubjectRoot(<options>)
% 
% In:
% 	<options>:
%		clear:	(false) true to clear the previously retrieved root FreeSurfer
%				directory
%		error:	(true) true to raise an error if the $SUBJECTS_DIR environmental
%				variable is undefined or the directory doesn't exist
% 
% Out:
% 	strDirRoot	- the root FreeSurfer subject directory
% 
% Updated: 2011-03-01
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
persistent dr;

opt	= ParseArgs(varargin,...
		'clear'	, false	, ...
		'error'	, true	  ...
		);

if opt.clear || isempty(dr) 
	[ec,dr]	= RunBashScript('echo $SUBJECTS_DIR','silent',true);
	dr		= AddSlash(StringTrim(dr));
end

strDirRoot	= dr;

if opt.error && ~isdir(strDirRoot)
	error('SUBJECTS_DIR environmental variable is undefined or invalid.');
end
