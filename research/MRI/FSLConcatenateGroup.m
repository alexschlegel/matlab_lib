function [b,strPathOut] = FSLConcatenateGroup(cPathCat,varargin)
% FSLConcatenateGroup
% 
% Description:	concatenate a group of subjects' concatenated functional data
%				files along the 4th dimension. data are transformed to MNI space
% 
% Syntax:	[b,strPathOut] = FSLConcatenateGroup(cPathCat,<options>)
% 
% In:
% 	cPathCat	- a cell of data_cat file paths (from FSLConcatenate)
%	<options>:
%		output:				(<auto>) the output path
%		keepintermediate:	(false) true to keep the separate aligned and
%							demeaned data files
%		cores:				(1) the number of processor cores to use
%		force:				(true) true to force concatenation if the output file
%							already exists
%		force_pre:			(false) true to force preprocessing steps
%		silent:				(false) true to suppress status messages
% 
% Out:
% 	b			- true if the concatenation was successful
%	strPathOut	- the output path
% 
% Updated: 2015-05-01
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'output'			, []	, ...
		'keepintermediate'	, false	, ...
		'cores'				, 1		, ...
		'force'				, true	, ...
		'force_pre'			, false	, ...
		'silent'			, false	  ...
		);

%get the output file
	if isempty(opt.output)
		strDirBase	= PathGetBase(cPathCat);
		strPathOut	= PathUnsplit(strDirBase,'data_group','nii.gz');
	else
		strPathOut	= opt.output;
	end

%do we need to do this?
	if ~opt.force && FileExists(strPathOut)
		b	= true;
		return;
	end

%relevant files
	cDirCat	= cellfun(@PathGetDir,cPathCat,'uni',false);
	cDirReg	= cellfun(@(d) DirAppend(d,'feat_cat','reg'),cDirCat,'uni',false);
	
	cPathExample	= cellfun(@(d) PathUnsplit(d,'example_func','nii.gz'),cDirReg,'uni',false);
	cPathMNI		= cellfun(@(d) PathUnsplit(d,'standard','nii.gz'),cDirReg,'uni',false);
	cPathWarp		= cellfun(@(d) PathUnsplit(d,'example_func2standard_warp','nii.gz'),cDirReg,'uni',false);

%resample the standard space to 3mm
	[b,cPathMNI3]	= FSLResample(cPathMNI,3,...
						'cores'		, opt.cores		, ...
						'force'		, opt.force_pre	, ...
						'silent'	, opt.silent	  ...
						);

%transform the files to MNI space
	[b,cPathCatMNI]	= FSLRegisterFNIRT(cPathCat,cPathMNI3,...
						'warp'		, cPathWarp		, ...
						'cores'		, opt.cores		, ...
						'force'		, opt.force_pre	, ...
						'silent'	, opt.silent	  ...
						);
	
	cPathExampleMNI		= cellfun(@(f) PathAddSuffix(f,'-example','favor','nii.gz'),cPathCatMNI,'uni',false);
	[b,cPathExampleMNI]	= FSLRegisterFNIRT(cPathExample,cPathMNI3,...
							'warp'		, cPathWarp			, ...
							'output'	, cPathExampleMNI	, ...
							'cores'		, opt.cores			, ...
							'force'		, opt.force_pre		, ...
							'silent'	, opt.silent		  ...
							);

%get the mean volume across all subjects
	strPathMean	= PathAddSuffix(strPathOut,'-example','favor','nii.gz');
	
	nii			= cellfun(@NIfTI.Read,cPathExampleMNI);
	nii(1).data	= mean(cat(4,nii.data),4);
	NIfTI.Write(nii(1),strPathMean);

%set the mean of each volume to the mean of the first dataset
	[b,cPathCatMNIDemean]	= FSLDemean(cPathCatMNI,...
								'mean'		, strPathMean			, ...
								'cores'		, min(2,opt.cores)		, ...
								'force'		, opt.force_pre			, ...
								'silent'	, opt.silent			  ...
								);

%concatenate everything
	b	= FSLMerge(cPathCatMNIDemean,strPathOut,...
				'silent'	, opt.silent	  ...
				);

%delete the intermediate files
	if ~opt.keepintermediate
		cellfun(@delete,cPathExampleMNI);
		cellfun(@delete,cPathCatMNI);
		cellfun(@delete,cPathCatMNIDemean);
	end