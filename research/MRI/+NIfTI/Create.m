function nii = Create(data)
% NIfTI.Create
% 
% Description:	create a NIfTI struct
% 
% Syntax:	nii = NIfTI.Create(data)
% 
% In:
% 	data	- a data array
% 
% Out:
% 	nii	- the NIfTI struct
% 
% Updated: 2015-04-13
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
nii			= nii_tool('init',data);
nii.data	= nii.img;
nii			= rmfield(nii,'img');
nii.method	= 'nii_tool';
