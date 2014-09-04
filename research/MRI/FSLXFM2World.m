function [M,xfm,niiFrom,niiRef] = FSLXFM2World(xfm,niiFrom,niiRef)
% FSLXFM2World
% 
% Description:	convert a FLIRT transform matrix to a transform between
%				coordinates in world space
% 
% Syntax:	M = FSLXFM2World(xfm,niiFrom,niiRef)
% 
% In:
% 	xfm		- a 4x4 FLIRT transform matrix or the path to one
%	niiFrom	- the source NIfTI object loaded with NIfTIRead, or the path to it
%	niiRef	- the reference NIfTI object loaded with NIfTIRead, or the path to it
% 
% Out:
% 	M	- the transform matrix between the from volume and reference volume in
%		  world space
% 
% Notes:	adapted from Ged Ridgway's flirtmat2worldmat function
%			http://www.nitrc.org/snippet/detail.php?type=package&id=1
% 
% Updated: 2011-03-27
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

%get the array space transformation
	[MA,xfm,niiFrom,niiRef]	= FSLXFM2Array(xfm,niiFrom,niiRef);
%get the world space to array space transformations
	MFrom_W_A	= inv(niiFrom.mat);
	MRef_A_W	= niiRef.mat;
%world -> array -> array -> world
	M	= MRef_A_W * MA * MFrom_W_A;
