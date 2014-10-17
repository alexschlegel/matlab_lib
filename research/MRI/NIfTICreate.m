function nii = NIfTICreate(base,varargin)
% NIfTICreate
% 
% Description:	create a blank NIfTI struct
% 
% Syntax:	nii = NIfTICreate(base,<options>)
% 
% In:
% 	base	- either a NIfTI object loaded via NIfTIRead or nifti, or the path
%			  to a NIfTI file
%	<options>:
%		fill:	(0) the fill value for the data array
% 
% Out:
% 	nii	- the NIfTI struct
% 
% Updated: 2010-11-07
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgs(varargin,...
		'fill'	, 0	  ...
		);

switch class(base)
	case 'struct'
		nii			= base;
		nii.data	= repmat(opt.fill,nii.orig.dat.dim);
	case 'nifti'
		nii.orig	= base;
		
		nii.data	= repmat(opt.fill,nii.orig.dat.dim);
		nii.mat		= nii.orig.mat;
	case 'char'
		nii			= NIfTIRead(base);
		nii.data(:)	= opt.fill;
	otherwise
		error('Unrecognized input.');
end
