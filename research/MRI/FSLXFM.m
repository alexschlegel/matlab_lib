function [bSuccess,strPathOut] = FSLXFM(strPathIn,strPathXFM,strPathRef,varargin)
% FSLXFM
% 
% Description:	apply a transformation matrix or warp to a NIfTI volume
% 
% Syntax:	[bSuccess,strPathOut] = FSLXFM(strPathIn,strPathXFM,strPathRef,<options>)
% 
% In:
% 	strPathIn	- the path to the input NIfTI volume
%	strPathXFM	- the path to the transformation matrix or warp file
%	strPathRef	- the path to the reference volume
%	<options>:
%		suffix:			(<auto>) the suffix to add to the input file name to
%						construct the output path
%		outdir:			(<same as input>) the output directory
%		output:			(<outdir>/<infile>-<suffix>.nii.gz) the path to the
%						output file. overrides <suffix> and <outdir>.
%		mask:			(false) true if the input is a binary mask
%		mask_thresh:	(<none/auto>) the threshold to apply to the transformed
%						mask to re-binarize it.  the mask is first normalized, so
%						this value should be in the range of [0->1].  if this is
%						unspecified and FLIRT is used, then interpolation is set
%						to nearest neighbor
%		force:			(true) true to force calculation of the transformed
%						volume even if the output already exists
%		silent:			(false) true to suppress status messages
%		<others for FSLRegisterFLIRT or FSLRegisterFNIRT>
% 
% Out:
% 	bSuccess	- true if the transformation was successful
%	strPathOut	- the path to the output file
% 
% Updated: 2015-04-13
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
bSuccess	= false;

opt	= ParseArgs(varargin,...
		'suffix'		, []	, ...
		'outdir'		, []	, ...
		'output'		, []	, ...
		'mask'			, false	, ...
		'mask_thresh'	, []	, ...
		'force'			, true	, ...
		'silent'		, false	  ...
		);

strDirOut	= unless(opt.outdir,PathGetDir(strPathIn));
strSuffix	= unless(opt.suffix,PathGetFilePre(strPathXFM));
strPathOut	= unless(opt.output,PathUnsplit(strDirOut,[PathGetFilePre(strPathIn,'favor','nii.gz') '-' strSuffix],'nii.gz'));

if opt.force || ~FileExists(strPathOut)
%transform the file
	bMask	= opt.mask;
	
	switch lower(PathGetExt(strPathXFM))
		case 'mat'
			strInterp	= [];
			
			if bMask && isempty(opt.mask_thresh)
			%just do nearest neighbor, not thresholding
				bMask		= false;
				strInterp	= 'nearestneighbour';
			end
			
			if ~FSLRegisterFLIRT(strPathIn,strPathRef,varargin{:},'xfm',strPathXFM,'output',strPathOut,'interp',strInterp);
				status(['FLIRT failed for input volume "' strPathIn '".'],'warning',true,'silent',opt.silent);
				return;
			end
		case 'nii.gz'
			if ~FSLRegisterFNIRT(strPathIn,strPathRef,varargin{:},'warp',strPathXFM,'output',strPathOut);
				status(['FLIRT failed for input volume "' strPathIn '".'],'warning',true,'silent',opt.silent);
				return;
			end
		otherwise
			error(['"' strPathXFM '" is not a recognized transformation file.']);
	end
%fix the mask
	if bMask
	%load the mask
		nii			= NIfTI.Read(strPathOut);
		nii.data	= double(nii.data);
	%normalize it
		nii.data	= normalize(nii.data);
	%apply the threshold
		if isempty(opt.mask_thresh)
			opt.mask_thresh	= graythresh(nii.data(:));
		end
		
		nii.data	= reshape(im2bw(nii.data(:),opt.mask_thresh),size(nii.data));
	%save the mask
		NIfTI.Write(nii,strPathOut);
	end
end

%success!
	bSuccess	= true;