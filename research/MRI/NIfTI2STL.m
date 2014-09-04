function [stl,strPathSTL,isoval] = NIfTI2STL(nii,varargin)
% NIfTI2STL
% 
% Description:	create an STL of an isosurface of the specified NIfTI data
% 
% Syntax:	[stl,strPathSTL,isoval] = NIfTI2STL(nii,[isoval]=<auto>,<options>)
% 
% In:
% 	nii			- a NIfTI struct loaded with NIfTIRead or the path to a NIfTI file
%	[isoval]	- the isosurface value
%	<options>:
%		prefix:	(<filepre>) the prefix of the STL name
%		mat:	(<from NIfTI>) the transformation matrix to the output space
%		save:	(<true if nii is a file, false otherwise>) true to save the STL
%		output:	('<name>_<isoval>.stl') the output file path
% 
% Out:
% 	stl			- the STL struct
%	strPathSTL	- the output STL path, if the STL was saved
%	isoval		- the isovalue used to create the isosurface
% 
% Updated: 2011-03-19
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
[isoval,opt]	= ParseArgsOpt(varargin,{},...
					'prefix'	, []			, ...
					'mat'		, []			, ...
					'save'		, ischar(nii)	, ...
					'output'	, []			  ...
					);

%load the NII
	if ischar(nii)
		[strDir,strFilePre,strExt]	= PathSplit(nii,'favor','nii.gz');
		
		nii	= NIfTIRead(nii);
	else
		[strDir,strFilePre,strExt]	= PathSplit(nii.orig.dat.fname,'favor','nii.gz');
	end
	
	M	= unless(opt.mat,nii.mat);
%get the STL isosurface
	strPrefix		= unless(opt.prefix,strFilePre);
	isoval			= ForceCell(isoval);
	[stl,isoval]	= STLIsoSurface(nii.data,isoval{:},'prefix',strPrefix);
	
	nFace	= size(stl.Vertex,1);
%convert coordinates to NIfTI space
	stl.Vertex	= [reshape(stl.Vertex,[],3) ones(nFace*3,1)]';
	stl.Vertex	= M*stl.Vertex;
	stl.Vertex	= reshape(stl.Vertex(1:3,:)',[],3,3);
	
	if ~isempty(stl.Normal)
		stl.Normal	= [stl.Normal ones(nFace,1)]';
		stl.Normal	= M*stl.Normal;
		stl.Normal	= stl.Normal(1:3,:)';
	end
%save
	if opt.save
		strPathSTL	= unless(opt.output,PathUnsplit(strDir,[strPrefix '_' num2str(isoval)],'stl'));
		
		STLWrite(stl,strPathSTL);
	else
		strPathSTL	= [];
	end
