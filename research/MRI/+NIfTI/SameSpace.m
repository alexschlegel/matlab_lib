function b = SameSpace(nii1,nii2)
% NIfTI.SameSpace
% 
% Description:	determine whether two NIfTI objects (loaded with NIfTI.Read) are
%				in the same space
% 
% Syntax:	b = NIfTI.SameSpace(nii1,nii2)
% 
% Updated: 2015-04-13
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
b	= (nii1.mat==nii2.mat) & isequal(size(nii1.data),size(nii2.data));
