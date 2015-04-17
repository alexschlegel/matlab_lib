function nii = Reorient(niiSource,niiDest,varargin)
% NIfTI.Reorient
% 
% Description:	reorient a NIfTI data set to be in line with another data set
% 
% Syntax:	nii = NIfTI.Reorient(niiSource,niiDest,<options>)
% 
% In:
% 	niiSource	- the source NIfTI
%	niiDest		- a NIfTI in the destination space
%	<options>:
%		method:	('linear') the interpolation method.  see interpn
% 
% Out:
% 	nii	- niiSource reoriented in the destination space
% 
% Updated: 2015-04-13
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'method'	, 'linear'	  ...
		);

%copy the destination NIfTI
	nii			= niiDest;
	szD			= size(nii.data);
	nD			= numel(nii.data);
	nii.data	= zeros(szD);
%get the the source coordinates of each destination point
	%get the destination coordinates
		p	= Coordinates(szD);
		p	= [reshape(p,nD,3)';ones(1,nD)];
	%transform the destination coordinates to source coordinates
		p	= inv(niiSource.mat)*niiDest.mat*p;
		p	= p';
%fill the destination with the source values
	nii.data(:)	= ArrayPartial(niiSource.data,p(:,1),p(:,2),p(:,3),'fill',0,'method',opt.method);
