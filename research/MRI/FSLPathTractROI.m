function strPathROI = FSLPathTractROI(strDirDTI,strNameTract,varargin)
% FSLPathROI
% 
% Description:	get the path to a probtrackx tract ROI file
% 
% Syntax:	strPathROI = FSLPathTractROI(strDirDTI,strNameTract,<options>)
% 
% In:
% 	strDirDTI		- the DTI data directory path
%	strNameTract	- the name of the tract (i.e. the name of the tract folder in
%					  <strDirDTI>.probtrackX/)
%	<options>: (see FSLSuffixTract)
% 
% Out:
% 	strPathROI	- the path to the tract ROI file
% 
% Updated: 2011-03-20
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
strSuffix	= FSLSuffixTract(varargin{:});
strPathROI	= PathUnsplit(FSLDirTract(strDirDTI,strNameTract),['roi' strSuffix],'nii.gz');
