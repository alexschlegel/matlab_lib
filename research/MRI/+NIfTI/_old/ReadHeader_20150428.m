function hdr = ReadHeader(strPathNII)
% NIfTI.Read
% 
% Description:	read a NIfTI file header
% 
% Syntax:	hdr = NIfTI.ReadHeader(strPathNII)
% 
% Updated: 2015-04-28
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
hdr	= nii_tool('hdr',strPathNII);

%add some derived properties
	%transform matrix (stolen from SPM's code)
		if hdr.sform_code>0
		%derived from sform
			hdr.mat			= [hdr.srow_x; hdr.srow_y; hdr.srow_z; 0 0 0 1];
			hdr.mat			= hdr.mat * [eye(4,3) [-1; -1; -1; 1]];
		elseif isfield(hdr,'magic') && hdr.qform_code>0
		%derived from qform
			%convert quaternion to rotation
				R = q2m([hdr.quatern_b hdr.quatern_c hdr.quatern_d]);
		
			%translation
				T	= [eye(4,3) [hdr.qoffset_x; hdr.qoffset_y; hdr.qoffset_z; 1]];
		
			%scaling
				n		= min(hdr.dim(1),3);
				Z		= [hdr.pixdim(2:(n+1)) ones(1,4-n)];
				Z(Z<0)	= 1;
				
				if hdr.pixdim(1)<0
					Z(3)	= -Z(3);
				end
				
				Z	= diag(Z);
		
			hdr.mat	= T*R*Z * [eye(4,3) [-1 -1 -1 1]'];
		else
			warning('no mat could be computed.');
		end
