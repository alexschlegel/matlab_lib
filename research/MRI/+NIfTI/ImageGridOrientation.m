function varargout = ImageGridOrientation(nii)
% NIfTI.ImageGridOrientation
% 
% Description:	determine the orientation of the image grid in a NIfTI file 
% 
% Syntax:	[mOrient] = NIfTI.ImageGridOrientation(nii)
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
% Assumptions:	assumes the NIfTI data are not aligned obliquely
% 
% Updated: 2016-04-12
% Copyright 2016 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%get a NIfTI object with .mat
	switch class(nii)
		case 'char'
			nii	= NIfTI.ReadHeader(nii);
		case {'nifti','struct'}
		otherwise
			error('What is this?');
	end

mOrient	= sign(nii.hdr.mat(1:3,1:3)');

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
	