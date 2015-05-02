function [icaComp,icaWeight] = fMRIICA(nii,varargin)
% fMRIICA
% 
% Description:	compute ICA components for an fMRI dataset
% 
% Syntax:	[icaComp,icaWeight] = fMRIICA(nii,<options>)
% 
% In:
% 	nii	- the path to a NIfTI file, a NIfTI struct loaded with NIfTI.Read, a
%		  4D data set, or a cell of the above
%	<options>:
%		components:	(25) the number of PCA/ICA components to compute
%		mask:		(<none>) the mask within which to restrict the computation.
%					takes the same format as input data set argument.
%		time:		(<all>) an array of timepoints to which to restrict the
%					computation (or a cell of arrays)
%		out:		(<none>) to save the resulting ICA components and a NIfTI
%					file of weights for each component, specify the prefix file
%					path (or cell of file paths) here (i.e. everything before
%					the file extension).
%		cores:		(1) the number of processor cores to use
%		force:		(true) true to force ICA computation even if output files
%					already exist
%		silent:		(false) true to suppress status messages
% 
% Out:
% 	icaComp		- an nSample x nComponent array of the ICA components (or a cell
%				  of such)
%	icaWeight	- a 4D array of the weights for each component (or a cell...)
% 
% Updated: 2015-05-01
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'components'	, 25	, ...
		'mask'			, []	, ...
		'time'			, []	, ...
		'out'			, []	, ...
		'cores'			, 1		, ...
		'force'			, true	, ...
		'silent'		, false	  ...
		);

%format the inputs
	[nii,opt.mask,opt.time,opt.out,bNoCell,bNoCell,bNoCell,bNoCell]	= ForceCell(nii,opt.mask,opt.time,opt.out);
	[nii,opt.mask,opt.time,opt.out]										= FillSingletonArrays(nii,opt.mask,opt.time,opt.out);

%compute the ICAs
	[icaComp, icaWeight]	= MultiTask(@ComputeICA,{nii,opt.mask,opt.time,opt.out},...
								'description'	, 'computing fMRI ICAs'	, ...
								'cores'			, opt.cores				, ...
								'silent'		, opt.silent			  ...
								);

%uncellify
	if bNoCell
		icaComp		= icaComp{1};
		icaWeight	= icaWeight{1};
	end

%------------------------------------------------------------------------------%
function [icaComp, icaWeight] = ComputeICA(nii,msk,t,strPrefixOut)
	strPathICAComp		= [strPrefixOut '-ica.nii.gz'];
	strPathICAWeight	= [strPrefixOut '-weight.nii.gz'];
	
	if ~opt.force && FileExists(cPathICAComp) && FileExists(strPathICAWeight)
	%already done. just load the results.
		icaComp		= permute(NIfTI.Read(strPathICAComp,'return','data'),[4 1 2 3]);
		icaWeight	= NIfTI.Read(strPathICAWeight,'return','data');
		
		return;
	end
	
	%load the data
		[nii,sz,niis]		= GetData(nii);
		[nSample,nVoxel]	= size(nii);
	%apply the mask
		if msk
			msk	= logical(GetData(msk));
			
			nii(:,~msk)	= [];
		else
			msk	= true(1,nVoxel);
		end
	%keep only the specified time points
		if ~isempty(t)
			nii	= nii(t,:);
		end
	%calculate the ICA components
		[icaComp,M]	= pcaica(nii,opt.components);
		nComponent	= size(icaComp,2);
	%construct the weight array
		icaWeight			= zeros(nVoxel,nComponent);
		icaWeight(msk,:)	= M';
		icaWeight			= reshape(icaWeight,[sz(1:3) nComponent]);
	%save the results
		if strPrefixOut
			
			
			%nComponent x 1 x 1 x nSample
			niiComp	= NIfTI.Create(permute(icaComp,[2 3 4 1]));
			NIfTI.Write(niiComp,strPathICAComp);
			
			niiWeight		= niis;
			niiWeight.data	= icaWeight;
			NIfTI.Write(niiWeight,strPathICAWeight);
		end
end
%------------------------------------------------------------------------------%
function [nii,sz,niis] = GetData(nii)
	switch class(nii)
		case 'char'
			niis	= NIfTI.Read(nii);
			nii		= niis.data;
			niis	= rmfield(niis,'data');
		case 'struct'
			niis	= rmfield(nii,'data');
			nii		= nii.data;
		otherwise
			niis	= rmfield(NIfTI.Create(nii),'data');
	end
	
	%reshape to nSample x nVoxel
		sz	= size(nii);
		nT	= size(nii,4);
		nii	= double(reshape(permute(nii, [4 1 2 3]),nT,[]));
end
%------------------------------------------------------------------------------%

end
