function [sz,usz] = GetSize(strPathNII)
% NIfTI.GetSize
% 
% Description:	get the size of a NIfTI data set
% 
% Syntax:	[sz,usz] = NIfTI.GetSize(strPathNII)
%
% In:
%	strPathNII	- the path to a NIfTI file
%
% Out:
%	sz	- the size of each dimension of the data
%	usz	- the unit size of each voxel in each dimension 
% 
% Updated: 2015-04-28
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
hdr	= NIfTI.ReadHeader(strPathNII);

sz	= hdr.dim(2:hdr.dim(1)+1);
usz	= hdr.pixdim(2:hdr.dim(1)+1);
