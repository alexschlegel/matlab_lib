function [bvecs,bvals] = PARRECGetDiffusion(strPathPAR,varargin)
% PARRECGetDiffusion
% 
% Description:	get diffusion magnitude and factor direction for PAR version 4.2
%				files
%  
% Syntax:	[bvecs,bvals] = PARRECGetDiffusion(strPathPAR,[strPathNIfTI]='<par_dir>/data.nii[.gz]',<options>)
% 
% In:
% 	strPathPAR		- the path to a PAR file or a .mat file storing a PAR header
%	[strPathNIfTI]	- the path to the NIfTI file to which the PAR/REC pair has
%					  been converted (to determine the correct orientation for
%					  the bvecs coordinates)
%	<options>:
%		'b0first':				(false) true to reorder bvecs and bvals so the
%								first b=0 volume is at the start (dcm2nii does
%								this)
%		'save':					(true) true to save the bvecs/bvals files to the
%								same folder as the NIfTI file
% 
% Out:
% 	bvecs	- an Nx3 array of the diffusion directions, oriented the same as the
%			  NIfTI image grid
%	bvals	- an Nx1 array of the diffusion magnitudes
% 
% Side-effects: if specified, saves the bvecs and bvals files to the same
%				directory as the NIfTI file
% 
% 
% Updated: 2011-11-12
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
[strPathNIfTI,opt]	= ParseArgs(varargin,[],...
						'b0first'	, false	, ...
						'save'		, true	  ...
						);
if isempty(strPathNIfTI)
	strPathNIfTI	= PathUnsplit(PathGetDir(strPathPAR),'data','nii');
	if ~FileExists(strPathNIfTI)
		strPathNIfTI	= PathUnsplit(PathGetDir(strPathPAR),'data','nii.gz');
	end
end

%check for files
	if ~exist(strPathPAR)
		error(['PAR file ' strPathPAR ' doesn''t exist.']);
	end
	if ~exist(strPathNIfTI)
		error(['NIfTI file ' strPathNIfTI ' doesn''t exist.']);
	end

%get the PAR header
	hdr		= PARRECReadHeader(strPathPAR);
	
	if ~isequal(hdr.version,'4.2')
		error(['Only v4.2 PAR files are supported.  Input file is v' hdr.version '.']);
	end
	
	kVol	= find(hdr.imageinfo.slice_number==1);
%get the gradient table
	bvecs	= hdr.imageinfo.diffusion(kVol,:);
	%reorient bvecs
		mOrientFrom	= PARRECDiffusionOrientation(hdr);
		mOrientTo	= NIfTI.ImageGridOrientation(strPathNIfTI);
		mTransform	= mOrientTo/mOrientFrom;
		bvecs		= (mTransform*bvecs')';
%get bvals
	bvals	= hdr.imageinfo.diffusion_b_factor(kVol);
	
%reorder
	if opt.b0first
		kB0			= find(hdr.imageinfo.diffusion_b_factor(kVol)==0,1,'first');
		
		bvecs	= bvecs([kB0 1:kB0-1 kB0+1:end],:);
		bvals	= bvals([kB0 1:kB0-1 kB0+1:end]);
	end

%save the data if specified
	if opt.save
		strDir	= PathGetDir(strPathNIfTI);
		
		strPathBVecs	= PathUnsplit(strDir,'bvecs','');
		strPathBVals	= PathUnsplit(strDir,'bvals','');
		
		fput(array2str(bvecs'),strPathBVecs);
		fput(array2str(bvals'),strPathBVals);
	end
