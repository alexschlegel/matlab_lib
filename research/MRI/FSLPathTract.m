function strPathTract = FSLPathTract(strDirDTI,strNameTract,varargin)
% FSLPathTract
% 
% Description:	get the path to a probtrackx output file
% 
% Syntax:	strPathTract = FSLPathTract(strDirDTI,strNameTract,<options>)
% 
% In:
% 	strDirDTI		- the DTI data directory path
%	strNameTract	- the name of the tract (i.e. the name of the tract folder in
%					  <strDirDTI>.probtrackX/)
%	<options>: (see FSLSuffixTract)
% 
% Out:
% 	strPathTract	- the path to the probtrackx output fdt_paths file
% 
% Updated: 2011-03-20
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
strSuffix		= FSLSuffixTract(varargin{:});
strPathTract	= PathUnsplit(FSLDirTract(strDirDTI,strNameTract),['fdt_paths' strSuffix],'nii.gz');
