function nSent = FSLTractSamplesSent(cDirDTI,cNameTract,nSample,varargin)
% FSLTractSamplesSent
% 
% Description:	calculate the total number of samples sent for a set of tracts.
% 
% Syntax:	nSent = FSLTractSamplesSent(cDirDTI,cNameTract,nSample,<options>)
% 
% In:
% 	cDirDTI		- the DTI data directory path or cell of paths
%	cNameTract	- the name or cell of names of the tracts (i.e. the name of the
%				  tract folder in <strDirDTI>.probtrackX/) (one for each
%				  specified DTI directory).  tracts must be named
%				  <mask1>-to-<mask2> and have corresponding mask files named
%				  <strDirDTI>/mask/<mask>-diffusion.nii.gz.
%	nSamples	- the --nsamples option passed to probtrackx
%	<options>:
%		force:	(true) true to calculate the number of samples sent even if a
%				previously saved value exists
%		silent:	(false) true to suppress status messages
% 
% Out:
% 	nSent	- an array of the total number of samples sent for each tract, or
%			  NaN if the required files don't exist
% 
% Updated: 2015-04-13
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'force'		, true	, ...
		'silent'	, false	  ...
		);

[cDirDTI,cNameTract]	= ForceCell(cDirDTI,cNameTract);
[cDirDTI,cNameTract]	= FillSingletonArrays(cDirDTI,cNameTract);

sTract	= size(cDirDTI);
nTract	= numel(cDirDTI);

nSent	= NaN(sTract);

%get the output mean files
	cDirTract	= cellfun(@FSLDirTract,cDirDTI,cNameTract,'UniformOutput',false);
	cPathS		= cellfun(@(d) PathUnsplit(d,'sent','dat'),cDirTract,'UniformOutput',false);
%get the values to calculate
	if opt.force
		bCalc	= true(sTract);
	else
		bCalc	= ~FileExists(cPathS);
	end
%read the previously stored values
	nSent(~bCalc)	= cellfunprogress(@(f) fget(f,'precision','double'),cPathS(~bCalc),'label','reading previously calculated sent totals','silent',opt.silent);
%calculate the values
	if any(bCalc)
	%mask names
		cTractSplit	= cellfun(@(n) split(n,'-to-'),cNameTract(bCalc),'UniformOutput',false);
		bProper		= cellfun(@(s) numel(s)==2,cTractSplit);
		
% 		if ~all(bProper)
% 			bBad		= false(size(bCalc));
% 			bBad(bCalc)	= ~bProper;
			
% 			status(['The following tracts are not formatted correctly:' 10 join(cNameTract(bBad),10)],'warning',true,'silent',opt.silent);
% 		end
		
		[cNameMask1,cNameMask2]	= cellfun(@(s) deal(s{1},s{2}),cTractSplit(bProper),'UniformOutput',false);
		bCalc(bCalc)				= bProper;
	%required files
		cDirMask	= cellfun(@(d) DirAppend(d,'mask'),cDirDTI(bCalc),'UniformOutput',false);
		cPathMask1	= cellfun(@(d,n) PathUnsplit(d,[n '-diffusion'],'nii.gz'),cDirMask,cNameMask1,'UniformOutput',false);
		cPathMask2	= cellfun(@(d,n) PathUnsplit(d,[n '-diffusion'],'nii.gz'),cDirMask,cNameMask2,'UniformOutput',false);
		
		bReady			= true(sTract);
		bReady(bCalc)	= cellfun(@(varargin) all(FileExists(varargin)),cPathMask1,cPathMask2);
		
		if any(~bReady(:))
			status(['Masks do not exist for the following tract directories:' 10 join(cDirTract(~bReady),10)],'warning',true,'silent',opt.silent);
		end
	%calculate
		bDo						= bReady(bCalc);
		nSent(bCalc & bReady)	= cellfunprogress(@CalcSent,cPathMask1(bDo),cPathMask2(bDo),cPathS(bCalc & bReady),'label','calculating tract sent totals');
	end

%------------------------------------------------------------------------------%
function nSent = CalcSent(strPathMask1,strPathMask2,strPathS)
	%load each
		[dM1,dM2]	= varfun(@(f) NIfTI.Read(f,'return','data'),strPathMask1,strPathMask2);
	%get the number of voxels in the masks
		nVoxel1	= sum(reshape(dM1~=0,[],1));
		nVoxel2	= sum(reshape(dM2~=0,[],1));
	%total number of samples sent
		nSent	= (nVoxel1 + nVoxel2) * nSample;
	%save the output
		fput(nSent,strPathS);
end
%------------------------------------------------------------------------------%

end
