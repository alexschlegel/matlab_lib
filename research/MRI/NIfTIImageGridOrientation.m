function varargout = NIfTIImageGridOrientation(nii)
% NIfTIImageGridOrientation
% 
% Description:	determine the orientation of the image grid in a NIfTI file 
% 
% Syntax:	[mOrient] = NIfTIImageGridOrientation(nii)
% 
% In:
% 	nii	- either a NIfTI object or a path to a NIfTI file 
% Out:
% 	mOrient	- a 3x3 matrix specifying the directions of the (i,j,k) image grid
% 			  indices.  The columns of the matrix correspond to standard NIfTI
% 			  space (lr, pa, is).  The first row specifies the direction of the
% 			  i index with a 1/-1 in the corresponding column, etc.  E.g. data
% 			  oriented with (i,j,k)->(ap,is,lr) would produce the following
% 			  matrix:
% 				[ 0 -1  0
% 				  0  0  1
% 				  1  0  0 ]
% 
% Side-effects:	if no output is specified, the results are displayed
% 
% Assumptions:	assumes SPM8 is installed and the NIfTI data are not aligned
%				obliquely
% 
% Updated: 2010-12-10
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

%get a NIfTI object
	switch class(nii)
		case 'char'
			bGZip	= isequal(lower(PathGetExt(nii,'favor','nii.gz')),'nii.gz');
			if isunix && bGZip
				nii		= FSLReadHeader(nii);
				nii.mat	= nii.qto_xyz;
			elseif ~bGZip
				nii	= nifti(nii);
			else
				nii	= NIfTIRead(nii);
			end
		case {'nifti','struct'}
		otherwise
			error('What is this?');
	end

mOrient	= sign(nii.mat(1:3,1:3)');

%output
	if nargout>0
		varargout{1}	= mOrient;
	else
		cOrientNIfTI	= {'lr','pa','is'};
		cOrientData		= cell(3,1);
		
		strDisp	= 'Image grid orientation: (';
		for k=1:3
			kOrient	= find(mOrient(k,:)~=0);
			if sign(mOrient(k,kOrient))==1
				cOrientData{k}	= cOrientNIfTI{kOrient};
			else
				cOrientData{k}	= cOrientNIfTI{kOrient}(end:-1:1);
			end
		end
		strDisp	= [strDisp join(cOrientData,',') ')'];
		
		disp(strDisp);
	end
	