function [bSuccess,cPathOut] = fMRIRegressWMV(cPathData,cDirFEAT,cDirFreeSurfer,varargin)
% fMRIRegressWMV
% 
% Description:	regress the white matter and ventricle timecourses out of
%				preprocessed fMRI data files
% 
% Syntax:	[bSuccess,cPathOut] = fMRIRegressWMV(cPathData,cDirFEAT,cDirFreeSurfer,<options>)
% 
% In:
% 	cPathData		- the path or cell of paths to fMRI data files
%	cDirFEAT		- the corresponding FEAT directories
%	cDirFreeSurfer	- the corresponding fully-processed freesurfer directories
%	<options>:
%		output:		(<in>-wmv) the output path or cell of output paths
%		cores:		(1) the number of processor cores to use
%		force_pre:	(false) true to force preprocessing steps
%		force:		(true) true to force regression even if the output data exist
%		silent:		(false) true to suppress status messages
% 
% Out:
% 	bSuccess	- a logical array specifying which data were successfully
%				  regressed
%	cPathOut	- the output path/cell of output paths
% 
% Updated: 2015-05-01
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'output'	, []	, ...
		'cores'		, 1		, ...
		'force_pre'	, false	, ...
		'force'		, true	, ...
		'silent'	, false	  ...
		);

[cPathData,cDirFEAT,cDirFreeSurfer,cPathOut,bNoCell1,bNoCell2,bNoCell3,bNoCell4]	= ForceCell(cPathData,cDirFEAT,cDirFreeSurfer,opt.output);
bNoCell																					= bNoCell1 && bNoCell2 && bNoCell3 && bNoCell4;
[cPathData,cDirFEAT,cDirFeeSurfer,cPathOut]											= FillSingletonArrays(cPathData,cDirFEAT,cDirFreeSurfer,cPathOut);

cPathOut	= cellfun(@(fi,fo) unless(fo,PathAddSuffix(fi,'-wmv','favor','nii.gz')),cPathData,cPathOut,'UniformOutput',false);

if opt.force
	bProcess	= true(size(cPathData));
else
	bProcess	= ~FileExists(cPathOut);
end

bSuccess	= true(size(bProcess));
if any(bProcess)
	bSuccess(bProcess)	= MultiTask(@DoRegress,{cPathData(bProcess) cDirFEAT(bProcess) cDirFreeSurfer(bProcess) cPathOut(bProcess)},...
							'description'	, 'regressing out wm and ventricle timecourses'	, ...
							'cores'			, opt.cores										, ...
							'uniformoutput'	, true											, ...
							'silent'		, opt.silent									  ...
							);
end

if bNoCell
	cPathOut	= cPathOut{1};
end


%------------------------------------------------------------------------------%
function b = DoRegress(strPathData,strDirFEAT,strDirFreeSurfer,strPathOut)
	strDirData	= PathGetDir(strPathData);
	
	%transform FreeSurfer to FEAT spaces
		b	= FreeSurfer2FEAT(strDirFreeSurfer,strDirFEAT,...
				'force'		, opt.force_pre	, ...
				'silent'	, opt.silent	  ...
				);
		
		if ~b;	return;	end
		
		strDirReg		= DirAppend(strDirFEAT,'reg');
		strPathFunc		= PathUnsplit(strDirReg,'example_func','nii.gz');
		strPathFS2FEAT	= PathUnsplit(strDirReg,'freesurfer2example_func','mat');
	%construct the white matter mask in functional space
		[b,strPathWMFS]	= FreeSurferMaskWM(strDirFreeSurfer,...
							'force'		, opt.force_pre	, ...
							'silent'	, opt.silent	  ...
							);
		
		if ~b;	return;	end
	
		strPathWMFull	= PathUnsplit(strDirReg,'wm','nii.gz');
		b				= FSLRegisterFLIRT(strPathWMFS,strPathFunc,...
							'output'	, strPathWMFull			, ...
							'xfm'		, strPathFS2FEAT		, ...
							'interp'	, 'nearestneighbour'	, ...
							'force'		, opt.force_pre			, ...
							'silent'	, opt.silent			  ...
							);
		
		if ~b;	return;	end
	
		%shrink by one
			strPathWM	= PathAddSuffix(strPathWMFull,'_shrink','favor','nii.gz');
			b			= MRIMaskGrow(strPathWMFull,-1,...
							'output'	, strPathWM		, ...
							'force'		, opt.force_pre	, ...
							'silent'	, opt.silent	  ...
							);
			
			if ~b;	return;	end
	%construct the ventricle mask in functional space
		[b,strPathVFS]	= FreeSurferMaskVentricle(strDirFreeSurfer,...
							'force'		, opt.force_pre	, ...
							'silent'	, opt.silent	  ...
							);
		
		if ~b;	return;	end
	
		strPathV	= PathUnsplit(strDirReg,'ventricle','nii.gz');
		b			= FSLRegisterFLIRT(strPathVFS,strPathFunc,...
						'output'	, strPathV				, ...
						'xfm'		, strPathFS2FEAT		, ...
						'interp'	, 'nearestneighbour'	, ...
						'force'		, opt.force_pre			, ...
						'silent'	, opt.silent			  ...
						);
		
		if ~b;	return;	end
	%extract and save the mean timecourses
		nii	= NIfTI.Read(strPathData);
		
		mWM	= NIfTI.MaskMean(nii,strPathWM);
		mV	= NIfTI.MaskMean(nii,strPathV);
		
		strPathT	= PathAddSuffix(strPathOut,'','dat','favor','nii.gz');
		
		fput(array2str([mWM mV]),strPathT);
	%regress them out
		b	= FSLRegFilt(strPathData,strPathT,1:2,...
				'output'	, strPathOut	, ...
				'force'		, opt.force		, ...
				'silent'	, opt.silent	  ...
				);
end
%------------------------------------------------------------------------------%

end
