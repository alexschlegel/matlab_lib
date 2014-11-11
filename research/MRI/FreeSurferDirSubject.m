function strDirSubject = FreeSurferDirSubject(strSubject,varargin)
% FreeSurferDirSubject
% 
% Description:	return a base FreeSurfer subject directory
% 
% Syntax:	strDirSubject = FreeSurferDirSubject(strSubject,<options>)
% 
% In:
% 	strSubject	- the name of the FreeSurfer subject
%	<options>:
%		subjectroot:	(<from $SUBJECTS_DIR>) the root FreeSurfer subjects
%						directory
%		error:			(true) true to raise an error if the subject directory
%						doesn't exist
% 
% Out:
% 	strDirSubject	- the subject's base FreeSurfer directory
% 
% Updated: 2011-03-01
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgs(varargin,...
		'subjectroot'	, []	, ...
		'error'			, true	  ...
		);

if isempty(opt.subjectroot)
	strDirRoot	= FreeSurferDirSubjectRoot('error',opt.error);
else
	strDirRoot	= opt.subjectroot;
end

strDirSubject	= DirAppend(strDirRoot,strSubject);

if opt.error && ~isdir(strDirSubject)
	error(['"' tostring(strSubject) '" is not a FreeSurfer subject.']); 
end
