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
%		b0first:	(false) true to reorder bvecs and bvals so the first b=0
%					volume is at the start (dcm2nii does this)
%		save:		(true) true to save the bvecs/bvals files to the same folder
%					as the NIfTI file
% 
% Out:
% 	bvecs	- an Nx3 array of the diffusion directions, oriented the same as the
%			  NIfTI image grid
%	bvals	- an Nx1 array of the diffusion magnitudes
% 
% Updated: 2015-04-28
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%parse the input
	[strPathNIfTI,opt]	= ParseArgs(varargin,[],...
							'b0first'	, false	, ...
							'save'		, true	  ...
							);
	
	if isempty(strPathNIfTI)
		strDirPAR		= PathGetDir(strPathPAR);
		strPathNIfTI	= PathUnsplit(strDirPAR,'data','nii');
		
		if ~FileExists(strPathNIfTI)
			strPathNIfTI	= PathUnsplit(strDirPAR,'data','nii.gz');
		end
	end

%check for files
	assert(FileExists(strPathPAR),'PAR file %s does not exist.',strPathPAR);
	assert(FileExists(strPathNIfTI),'NIfTI file %s does not exist.',strPathNIfTI);

%get the PAR header
	hdr		= PARRECReadHeader(strPathPAR);
	
	assert(isequal(hdr.version,'4.2'),'only v4.2 PAR files are supported. input file is v%s.',hdr.version);
	
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
		kB0	= find(hdr.imageinfo.diffusion_b_factor(kVol)==0,1,'first');
		
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
