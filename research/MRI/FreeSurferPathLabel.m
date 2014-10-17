function strPathLabel = FreeSurferPathLabel(strSubject,strName,strHemi,varargin)
% FreeSurferPathLabel
% 
% Description:	return the path to a FreeSurfer label
% 
% Syntax:	strPathLabel = FreeSurferPathLabel(strSubject,strName,strHemi,<options>)
% 
% In:
% 	strSubject	- the name of the FreeSurfer subject
%	strName		- the label name
%	strHemi		- the hemisphere, either 'lh' or 'rh'
%	<options>:
%		subjectroot:	(<FreeSurferDirSubject default>) the root FreeSurfer
%						subjects directory
%		error:			(true) true to raise an error if the label path doesn't
%						exist
% 
% Out:
% 	strPathLabel	- the path to the label
% 
% Updated: 2011-03-01
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgs(varargin,...
		'subjectroot'	, []	, ...
		'error'			, true	  ...
		);

strDirSubject	= FreeSurferDirSubject(strSubject,'subjectroot',opt.subjectroot,'error',opt.error);
strDirLabel		= DirAppend(strDirSubject,'label');
strHemi			= lower(strHemi);
strFilePre		= [strHemi '.' strName]; 

strPathLabel	= PathUnsplit(strDirLabel,strFilePre,'label');

if opt.error && ~FileExists(strPathLabel)
	error(['The label file "' strPathLabel '" does not exist.']);
end
