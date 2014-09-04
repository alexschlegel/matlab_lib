function b = NIfTISameSpace(nii1,nii2)
% NIfTISameSpace
% 
% Description:	determine whether two NIfTI objects (loaded with NIfTIRead) are
%				in the same space
% 
% Syntax:	b = NIfTISameSpace(nii1,nii2)
% 
% Updated: 2011-02-06
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
b	= (nii1.mat==nii2.mat) & isequal(size(nii1.data),size(nii2.data));
