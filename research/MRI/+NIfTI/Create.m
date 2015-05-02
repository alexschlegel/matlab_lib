function nii = Create(data,varargin)
% NIfTI.Create
% 
% Description:	create a NIfTI struct
% 
% Syntax:	nii = NIfTI.Create(data,<options>)
% 
% In:
% 	data	- a data array
%	<options>:
%		version:	(1) the NIfTI version to create. either 1 or 2.
% 
% Out:
% 	nii	- the NIfTI struct
% 
% Updated: 2015-04-29
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%parse the inputs
	opt	= ParseArgs(varargin,...
			'version'	, 1	  ...
			);
	
	opt.version	= CheckInput(opt.version,'version',{1 2});

%create the NIfTI struct
	nii			= nii_tool('init',data);
	nii.data	= nii.img;
	nii			= rmfield(nii,'img');
	nii.method	= 'nii_tool';

%set the version
	nii.hdr.version	= opt.version;
