function [bSuccess,cPathOut,tr,cDirFEAT] = FSLFEATPreprocess(cPathData,varargin)
% FSLFEATPreprocess
% 
% Description:	preprocess functional data using FSL's feat
% 
% Syntax:	[bSuccess,cPathOut,tr,cDirFEAT] = FSLFEATPreprocess(cPathData,[cPathStructural]=<no registration>,<options>)
% 
% In:
% 	cPathData			- the path to a functional data file, or a cell of paths
%	[cPathStructural]	- the path to structural data corresponding to the
%						  functional data, or a cell of paths.  if unspecified,
%						  no registration is performed.  structural files must
%						  be brain extracted if FNIRT will be used to register to
%						  standard space.
%	<options>:
%		output:				(<auto>) the path to the folder in which to place
%							information about the preprocessing, or a cell of
%							paths
%		save_transformed:	(false) true to save the functional data transformed
%							to structural/standard space
%		motion_correct:		(true) true to perform motion correction
%		slice_time_correct:	(6) a code to specify which type of slice timing
%							correction to perform:
%								0: None
%								1: Regular up (0, 1, 2, 3, ...)
%								2: Regular down
%								5: Interleaved (0, 2, 4 ... 1, 3, 5 ... )
%								6: square root method (e.g. for 35 slices:
%								   (1,7,13,19,25,31,2,8,14,...)
%							OR an nSlice x 1 array specifying the slice
%							acquisition order
%		bet:				(true) true to BET the data
%		spatial_fwhm:		(6) the spatial smoothing filter FWHM, in mm
%		norm_intensity:		(false) true to perform intensity normalization
%		highpass:			(100) the highpass filter cutoff, in seconds.  set to
%							0 to skip highpass filtering.
%		lowpass:			(false) true to lowpass filter
%		struct_dof:			('BBR') the functional->structural registration
%							method. either the degrees of freedom, or the string
%							'BBR' to use the BBR method (in which case the
%							original non-BETed structural data set must exist in
%							the same directory as the BETed data).
%		standard:			(<MNI152_T1_2mm_brain>) path to the standard brain to
%							which to register the data.  set to false to skip
%							registration to standard space.
%		standard_dof:		(12) degrees of freedom for the structural->standard
%							registration
%		standard_fnirt:		(true) true to FNIRT the structural to the standard
%							after FLIRTing
%		warp_res:			(10) the nonlinear warp field resolution
%		bb_thresh:			(10) the brain/background threshold percentage
%		noise_level:		(0.66) the noise level parameter in the feat design
%		noise_ar:			(0.34) the noise AR parameter in the feat design
%		attempts:			(4) the number of attempts to make before accepting
%							defeat. for some reason FEAT seems to be failing a
%							lot with preprocessing.
%		cores:				(1) the number of processor cores to use
%		force:				(true) true to force preprocessing if preprocessed
%							outputs already exist
%		silent:				(false) true to suppress status messages
% 
% Out:
% 	bSuccess	- a logical array indicating which directories were successfully
%				  preprocessed
%	cPathOut	- the path/cell of paths to preprocessed data files
%	tr			- the TR of each processed data file
%	cDirFEAT	- the path/cell of paths to preprocessing feat directories
% 
% Updated: 2015-09-14
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
[cPathStructural,opt]	= ParseArgs(varargin,[],...
							'output'				, []		, ...
							'save_transformed'		, false		, ...
							'motion_correct'		, true		, ...
							'slice_time_correct'	, 6			, ...
							'bet'					, true		, ...
							'spatial_fwhm'			, 6			, ...
							'norm_intensity'		, false		, ...
							'highpass'				, 100		, ...
							'lowpass'				, false		, ...
							'struct_dof'			, 'BBR'		, ...
							'standard'				, []		, ...
							'standard_dof'			, 12		, ...
							'standard_fnirt'		, true		, ...
							'warp_res'				, 10		, ...
							'bb_thresh'				, 10		, ...
							'noise_level'			, 0.66		, ...
							'noise_ar'				, 0.34		, ...
							'attempts'				, 4			, ...
							'cores'					, 1			, ...
							'force'					, true		, ...
							'silent'				, false		  ...
							);
bReg	= ~isempty(cPathStructural);
if bReg && isempty(opt.standard)
	opt.standard	= FSLPathMNIAnatomical('type','MNI152_T1_2mm_brain');
end
bRegStandard	= bReg && notfalse(opt.standard);
opt.standard	= conditional(bRegStandard,opt.standard,'');

%cellify
	[cPathData,cPathStructural,cDirFEAT,bNoCell,dummy,dummy]	= ForceCell(cPathData,cPathStructural,opt.output);
	[cPathData,cPathStructural,cDirFEAT]						= FillSingletonArrays(cPathData,cPathStructural,cDirFEAT);
	
	%get the feat directories
	cDirFEAT	= cellfun(@(d,f) unless(d,FSLDirFEAT(f)),cDirFEAT,cPathData,'uni',false);
%make sure all the structurals are brain-extracted
	if bRegStandard && opt.standard_fnirt
		bBrain	= cellfun(@(f) ~isempty(regexp(PathGetFilePre(f,'favor','nii.gz'),'brain$')),cPathStructural);
		if any(~bBrain)
			error(['In order to FNIRT to standard space, the following structural files need to be brain extracted:' 10 join(cPathStructural(~bBrain),10)]);
		end
	end
%get the template
	strPathFEATTemplate	= PathAddSuffix(mfilename('fullpath'),'','template');
	opt.feat_template	= ReadTemplate(strPathFEATTemplate);
%get the output files
	cPathOutPre	= cellfun(@(f) PathAddSuffix(f,'-pp','favor','nii.gz'),cPathData,'UniformOutput',false);
%get the final data file produced
	bStructural	= ~cellfun(@isempty,cPathStructural);
	bStandard	= bRegStandard & bStructural & opt.save_transformed;
	bStructural	= bStructural & ~bStandard & opt.save_transformed;
	
	cSuffix		= arrayfun(@GetRegSuffix,bStructural,bStandard,'UniformOutput',false);
	cPathOut	= cellfun(@(f,s) PathAddSuffix(f,s,'favor','nii.gz'),cPathOutPre,cSuffix,'UniformOutput',false);
	
	if opt.force
		bProcess	= true(size(cPathData));
	else
		bProcess	= ~FileExists(cPathOut);
	end
%preprocess each
	bSuccess	= true(size(cPathData));
	
	cInput	=	{
					cPathData(bProcess)
					cPathStructural(bProcess)
					cDirFEAT(bProcess)
					cPathOutPre(bProcess)
					opt
				};
	
	if any(bProcess)
		[mtO,tr]	= MultiTask(@PreprocessOne,cInput,...
						'description'	, 'Preprocessing functional data using FEAT'	, ...
						'catch'			, true											, ...
						'cores'			, opt.cores										, ...
						'silent'		, opt.silent									  ...
						);
		
		bSuccess(bProcess)	= cellfun(@notfalse,mtO);
		tr					= cellfun(@(x) unless(x,NaN),tr);
	else
		tr	= [];
	end
%uncellify
	if bNoCell
		cPathOut	= cPathOut{1};
		cDirFEAT	= cDirFEAT{1};
	end

%------------------------------------------------------------------------------%
function [b,tr] = PreprocessOne(strPathData,strPathStructural,strDirFEATOut,strPathOut,opt)
	[strDirData,strFileData]	= PathSplit(strPathData,'favor','nii.gz');
	
	hdr		= NIfTI.ReadHeader(strPathData);
	
	tr		= hdr.pixdim(5);
	nVol	= hdr.dim(5);
	nSlice	= hdr.dim(4);
	
	%temporary directory so we're not left with a bunch of crap
		strDirTemp	= GetTempDir;
	%construct the template replacement struct
		bHighpass			= opt.highpass~=0;
		bRegStructural		= ~isempty(strPathStructural);
		bRegStandard		= ~isempty(opt.standard);
		
		%process the slice timing options
			strPathSliceOrder	 = '';
			
			if isscalar(opt.slice_time_correct)
				switch opt.slice_time_correct
					case 6	%sqrt method
						step					= ceil(sqrt(nSlice));
						opt.slice_time_correct	= reshape(reshape(1:step.^2,step,step)',[],1);
						opt.slice_time_correct	= opt.slice_time_correct(1:nSlice);
				end
			end
			
			if ~isscalar(opt.slice_time_correct)
				%custom slice order selected
				strPathSliceOrder	= PathUnsplit(strDirTemp,'slice_order','txt');
				
				fput(array2str(opt.slice_time_correct),strPathSliceOrder);
				
				opt.slice_time_correct	= 3;
			end
		
		sFill	= struct(...
						'functional_path'		, strPathData					, ...
						'structural_path'		, strPathStructural				, ...
						'output_dir'			, strDirTemp					, ...
						'tr'					, tr							, ...
						'volumes'				, nVol							, ...
						'bb_thresh'				, opt.bb_thresh					, ...
						'noise_level'			, opt.noise_level				, ...
						'noise_ar'				, opt.noise_ar					, ...
						'motion_correct'		, double(opt.motion_correct)	, ...
						'slice_time_correct'	, opt.slice_time_correct		, ...
						'slice_timing_file'		, strPathSliceOrder				, ...
						'bet'					, double(opt.bet)				, ...
						'spatial_fwhm'			, opt.spatial_fwhm				, ...
						'norm_intensity'		, double(opt.norm_intensity)	, ...
						'highpass'				, double(bHighpass)				, ...
						'highpass_cutoff'		, opt.highpass					, ...
						'lowpass'				, double(opt.lowpass)			, ...
						'reg'					, double(bRegStructural)		, ...
						'reg_standard'			, double(bRegStandard)			, ...
						'struct_dof'			, opt.struct_dof				, ...
						'standard_path'			, opt.standard					, ...
						'standard_dof'			, opt.standard_dof				, ...
						'standard_fnirt'		, double(opt.standard_fnirt)	, ...
						'warp_res'				, opt.warp_res					  ...
					);
	%fill and save the feat definition
		strPathFEATDef	= PathUnsplit(strDirData,['feat-pp-' strFileData],'fsf');
		strFEATDef		= StringFillTemplate(opt.feat_template,sFill);
		
		fput(strFEATDef,strPathFEATDef);
	%run feat
		ec			= 1;
		kAttempt	= 1;
		while ec~=0 && kAttempt<=opt.attempts
			[ec,strOutput]	= RunBashScript(['feat ' strPathFEATDef],'silent',opt.silent);
			
			kAttempt	= kAttempt + 1;
		end
		
		b	= ec==0;
		
		if ~notfalse(b)
			b	= false;
			return;
		end
		
		strDirFEAT		= DirAppend(strDirTemp,'.feat');
		strPathFEATData	= PathUnsplit(strDirFEAT,'filtered_func_data','nii.gz');
	%copy the slice order file to the .feat directory
		if ~isempty(strPathSliceOrder)
			strPathSOFEAT	= PathUnsplit(strDirFEAT,PathGetFileName(strPathSliceOrder));
			
			FileCopy(strPathSliceOrder,strPathSOFEAT,'createpath',true);
		end
	if bRegStructural
	%register the functional data to the final structural
		strDirReg	= DirAppend(strDirFEAT,'reg');
		strXFM		= conditional(bRegStandard && ~opt.standard_fnirt,'example_func2standard','example_func2highres');
		strPathXFM	= PathUnsplit(strDirReg,strXFM,'mat');
		strPathWarp	= PathUnsplit(strDirReg,'highres2standard_warp','nii.gz');
		
		if opt.save_transformed
			strPathFEATDataXFM	= PathAddSuffix(strPathFEATData,'-xfm','favor','nii.gz');
			
			if bRegStandard && opt.standard_fnirt
			%fnirt to standard space
				b	= FSLRegisterFNIRT(strPathFEATData,opt.standard,...
						'output'	, strPathFEATDataXFM	, ...
						'affine'	, strPathXFM			, ...
						'warp'		, strPathWarp			, ...
						'log'		, false					, ...
						'silent'	, opt.silent			  ...
						);
			else
			%flirt to structural/standard space
				strPathRef	= conditional(bRegStandard,opt.standard,strPathStructural);
				
				b	= FSLRegisterFLIRT(strPathFEATData,strPathRef,...
						'output'	, strPathFEATDataXFM	, ...
						'xfm'		, strPathXFM			, ...
						'log'		, false					, ...
						'silent'	, opt.silent			  ...
						);
			end
			
			if ~notfalse(b)
				b	= false;
				return;
			end
		end
	end
	%copy the data to the output directory
		strDirOut			= PathGetDir(strPathOut);
		[cPathIn,cPathOut]	= deal({});
		
		%data files
			strPathMask		= PathUnsplit(strDirFEAT,'mask','nii.gz');
			strPathMaskOut	= PathAddSuffix(strPathOut,'-mask','favor','nii.gz');
			
			cPathIn		= [cPathIn; strPathFEATData; strPathMask];
			cPathOut	= [cPathOut; strPathOut; strPathMaskOut];
		%feat directory
			cPathIn		= [cPathIn; strDirFEAT];
			cPathOut	= [cPathOut; strDirFEATOut];
		
		b	= notfalse(all(cellfun(@(fi,fo) FileCopy(fi,fo,'createpath',true),cPathIn,cPathOut)));
	%remove the temporary directory
		[ec,strOutput]	= RunBashScript(['rm -r ' strDirTemp],'silent',opt.silent);
%------------------------------------------------------------------------------%
function str = GetRegSuffix(bStruct,bStandard)
	str	= conditional(bStandard,'-tostandard',conditional(bStruct,'-tostruct',''));
%------------------------------------------------------------------------------%
