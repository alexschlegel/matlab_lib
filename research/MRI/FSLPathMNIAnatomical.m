function strPathMNI = FSLPathMNIAnatomical(varargin)
% FSLPathMNIAnatomical
% 
% Description:	get the path to the MNI anatomical
% 
% Syntax:	strPathMNI = FSLPathMNIAnatomical([strDirFSL]=<find>,<options>)
% 
% In:
% 	[strDirFSL]	- the path to the base FSL directory
%	<options>:
%		type:	('MNI152_T1_1mm') the type of anatomical file to return
% 
% Out:
% 	strPathMNI	- the path to the MNI NIfTI data file
% 
% Updated: 2010-12-13
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
[strDirFSL,opt]	= ParseArgs(varargin,[],...
					'type'	, 'avg152t1'	  ...
					);
if isempty(strDirFSL)
	strDirFSL	= GetDirFSL();
end

switch lower(opt.type)
	case 'avg152t1'
		strFilePre	= 'avg152T1';
	case 'fmrib58_fa'
		strFilePre	= 'FMRIB58_FA_1mm';
	otherwise
		strFilePre	= opt.type;
end


strPathMNI	= PathUnsplit(DirAppend(strDirFSL,'data','standard'),strFilePre,'nii.gz');

if ~FileExists(strPathMNI)
	strPathMNI	= '';
end
