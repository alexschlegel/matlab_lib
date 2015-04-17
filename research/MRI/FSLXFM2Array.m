function [M,xfm,niiFrom,niiRef] = FSLXFM2Array(xfm,niiFrom,niiRef)
% FSLXFM2Array
% 
% Description:	convert a FLIRT transform matrix to a transform between
%				coordinates in array space
% 
% Syntax:	M = FSLXFM2Array(xfm,niiFrom,niiRef)
% 
% In:
% 	xfm		- a 4x4 FLIRT transform matrix or the path to one
%	niiFrom	- the source NIfTI object loaded with NIfTI.Read, or the path to it
%	niiRef	- the reference NIfTI object loaded with NIfTI.Read, or the path to it
% 
% Out:
% 	M	- the transform matrix between the from volume and reference volume in
%		  array space
% 
% Notes:	adapted from Ged Ridgway's flirtmat2worldmat function
%			http://www.nitrc.org/snippet/detail.php?type=package&id=1
% 
% Updated: 2015-04-13
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

if ischar(xfm)
	xfm	= str2array(fget(xfm));
end
if ischar(niiFrom)
	niiFrom	= NIfTI.Read(niiFrom);
end
if ischar(niiRef)
	niiRef	= NIfTI.Read(niiRef);
end

%get the transform from array to FLIRT's "world" space, according to:
%http://users.fmrib.ox.ac.uk/~mark/files/coordtransforms.pdf
	MFrom_A_FW	= Array2FLIRTWorld(niiFrom);
	MRef_A_FW	= Array2FLIRTWorld(niiRef);
	
	MRef_FW_A	= inv(MRef_A_FW);
%Array-based transformation
	MAFSL_From_Ref	= MRef_FW_A * xfm * MFrom_A_FW;
%FSL's zero-based to SPM's one-based indices
	M_Z_O		= eye(4);
	M_Z_O(:,4)	= 1;
	
	M	= M_Z_O * MAFSL_From_Ref * inv(M_Z_O);

%------------------------------------------------------------------------------%
function M_A_FW = Array2FLIRTWorld(nii)
	M_A_FW		= diag(sqrt(sum(nii.mat.^2)));
	M_A_FW(4,4)	= 1;
	
	if det(nii.mat)>0
		M_A_FW(1,1)	= -M_A_FW(1,1);
		M_A_FW(1,4)	= size(nii.data,1)-1;
	end
%------------------------------------------------------------------------------%
