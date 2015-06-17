function cPathOut = DICOMTransform(cDirIn,varargin)
% DICOMTransform
% 
% Description:	apply an affine transformation to a DICOM data set
% 
% Syntax:	cPathOut = DICOMTransform(cPathIn,<options>)
% 
% In:
% 	cDirIn	- a directory containing a DICOM data set
%	<options>:
%		'dirout':		(<overwrite>) the output directory for transformed files
%		<transform>:	specify the transform using the syntax from makehgtform
% 
% Out:
% 	cPathOut	- a cell of paths to transformed DICOM files
% 
% Example:	cPathOut = DICOMTransform(strDirIn,'scale',[
% 
% Updated:	2009-09-24
% Copyright 2009 Alex Schlegel (alex@roguecheddar.com).  All Rights Reserved.
