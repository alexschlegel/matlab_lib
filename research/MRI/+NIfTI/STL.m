function stl = STL(nii,varargin)
% NIfTI.STL
% 
% Description:	create an STL of an isosurface of the specified NIfTI data
% 
% Syntax:	stl = NIfTI.STL(nii,<options>)
% 
% In:
% 	nii		- a NIfTI struct loaded with NIfTI.Read or the path to a NIfTI file
%	<options>:
%		isoval:	(<auto>) the isosurface value
%		prefix:	(<filepre>) the prefix of the STL name
%		mat:	(<from NIfTI>) the transformation matrix to the output space
%		output:	(<no save>) the output file path
% 
% Out:
% 	stl	- the STL struct
% 
% Updated: 2015-06-15
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%parse the inputs
	opt	= ParseArgs(varargin,...
			'isoval'	, {}	, ...
			'prefix'	, []	, ...
			'mat'		, []	, ...
			'output'	, []	  ...
			);
	
	isoval	= ForceCell(opt.isoval);

%load the NII
	if ischar(nii)
		nii	= NIfTI.Read(nii);
	end
	
	M	= unless(opt.mat,nii.hdr.mat);
%get the STL isosurface
	stl		= STLIsoSurface(double(nii.data),isoval{:},'prefix',opt.prefix);
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
	if ~isempty(opt.output)
		STLWrite(stl,opt.output);
	end
