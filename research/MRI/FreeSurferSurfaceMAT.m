function M = FreeSurferSurfaceMAT(strPathNII)
% FreeSurferSurfaceMAT
% 
% Description:	return the transformation matrix from a NIfTI file's index-space
%				to FreeSurfer surface space
% 
% Syntax:	M = FreeSurferSurfaceMAT(strPathNII)
% 
% In:
% 	strPathNII	- the path to a NIfTI file
% 
% Out:
% 	M	- the 4x4 affine transformation matrix
% 
% Updated: 2011-03-19
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
[v,s]	= CallProcess('mri_info',{strPathNII '--vox2ras-tkr'},'silent',true);
M		= str2array(s{1});
