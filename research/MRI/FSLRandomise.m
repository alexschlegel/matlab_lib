function [b,cPathOut] = FSLRandomise(cPathData,d,varargin)
% FSLRandomise
% 
% Description:	run FSL's randomise tool to perform a permutation-based GLM
% 
% Syntax:	[b,cPathOut] = FSLBet(cPathData,d,<options>)
% 
% In:
% 	cPathData	- the path to the 4D input data to randomise, or a cell of input
%				  data paths to perform multiple randomise jobs
%	d			- an nData x nEV design matrix (nData is the number of elements
%				  in the 4th dimension of the input data), or a cell of design
%				  matrices
%	<options>:
%		output:				(<pre-extension path of cPathData>) the root output
%							path
%		mask:				(<none>) the path/cell of paths to masks to specify
%							which voxels in the input data should be analyzed
%		tcontrast:			(<eye>) an nTContrast x nEV t-contrast array, or a
%							cell of t-contrast arrays
%		ftest:				(<none>) an nFTest x nTContrast f-test array, or a
%							cell of f-test arrays
%		exchangeability:	(<none>) an nEV-length exchangeability block array,
%							or a cell of exchangeability block arrays
%		permutations:		(5000) the number of permutations to perform
%		demean:				(false) true to temporally demean the design matrix
%							before model fitting
%		tfce:				(true) true to perform threshold-free cluster
%							enhancement
%		pcorrect:			({'fwe','fdr'}) a string/cell of strings specifying
%							the type of p-correction to perform. each string is
%							one of:
%								fwe:	do randomise's family-wise error rate
%										p-correction
%								fdr:	do false discovery rate p-correction
%		onesample:			(false) perform a one sample group-mean test instead
%							of the default permutation test
%		clusterthresh:		(<none>) the threshold to use for cluster-based
%							thresholding
%		clustermassthresh:	(<none>) the threshold to use for cluster-mass-based
%							thresholding
%		fclusterthresh:		(<none>) the threshold to use for f cluster
%							thresholding
%		fclustermassthresh:	(<none>) the threshold to use for f cluster-mass
%							thresholding
%		vsmooth:			(<none>) the standard deviation, in mm, of the
%							variance smoothing for t-stats
%		twopass:			(false) true to carry out cluster normalization
%							thresholding
%		raw:				(false) true to output unpermuted statistic images
%		uncorrp:			(false) true to output uncorrected p-value images
%		permtxt:			(false) true to output permutation vector text files
%		nulltxt:			(false) true to output null distribution text files
%		removeconstant:		(true) true to remove constant voxels from the mask
%							(i.e. the inverse of randomise's norcmask option)
%		seed:				(<none>) the integer seed for the random number
%							generator
%		tfce_h:				(<default>) the tfce height parameter
%		tfce_d:				(<default>) the tfce delat parameter
%		tfce_e:				(<default>) the tfce extent parameter
%		tfce_c:				(<default>) the tfce connectivity
%		glmoutput:			(false) true to output glm information for the
%							t-statistics
%		cores:				(1) the number of processor cores to use
%		force:				(true) true to force randomise to run even if the
%							output already exists
%		silent:				(false) true to suppress status messages
% 
% Out:
% 	b			- true for each randomise call that completed successfully
%	cPathOut	- the root output path(s)
% 
% Updated: 2015-05-07
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%process the inputs
	opt	= ParseArgs(varargin,...
			'output'				, []			, ...
			'mask'					, []			, ...
			'tcontrast'				, []			, ...
			'ftest'					, []			, ...
			'exchangeability'		, []			, ...
			'permutations'			, 5000			, ...
			'demean'				, false			, ...
			'tfce'					, true			, ...
			'pcorrect'				, {'fwe','fdr'}	, ...
			'onesample'				, false			, ...
			'clusterthresh'			, []			, ...
			'clustermassthresh'		, []			, ...
			'fclusterthresh'		, []			, ...
			'fclustermassthresh'	, []			, ...
			'vsmooth'				, []			, ...
			'twopass'				, false			, ...
			'raw'					, false			, ...
			'uncorrp'				, false			, ...
			'permtxt'				, false			, ...
			'nulltxt'				, false			, ...
			'removeconstant'		, true			, ...
			'seed'					, []			, ...
			'tfce_h'				, []			, ...
			'tfce_d'				, []			, ...
			'tfce_e'				, []			, ...
			'tfce_c'				, []			, ...
			'glmoutput'				, false			, ...
			'cores'					, 1				, ...
			'force'					, true			, ...
			'silent'				, false			  ...
			);
	
	%make sure we have everything for each call to randomise
		bCell	= iscell(cPathData);
		
		[cPathData,d,cPathOut,cPathMask,tContrast,fTest,exch]	= ForceCell(cPathData,d,opt.output,opt.mask,opt.tcontrast,opt.ftest,opt.exchangeability);
		[cPathData,d,cPathOut,cPathMask,tContrast,fTest,exch]	= FillSingletonArrays(cPathData,d,cPathOut,cPathMask,tContrast,fTest,exch);
		
		bCell	= bCell || numel(cPathData)>1;
	
	%default outputs
		cPathOut	= cellfun(@(fi,fo) unless(fo,PathUnsplit(PathGetDir(fi),PathGetFilePre(fi,'favor','nii.gz'))),cPathData,cPathOut,'uni',false);
	
	%default t-contrasts
		tContrast	= cellfun(@(d,tc) unless(tc,eye(size(d,2))),d,tContrast,'uni',false);
	
	%check the pcorrect values
		opt.pcorrect	= ForceCell(opt.pcorrect);
		opt.pcorrect	= cellfun(@(p) CheckInput(p,'pcorrect',{'fwe','fdr'}),opt.pcorrect,'uni',false);
	
	%parameters to pass on to each call
		param	= rmfield(opt,{'output','mask','tcontrast','ftest','exchangeability','cores','force','isoptstruct','opt_extra'});

%which data do we need to process?
	sz	= size(cPathData);
	
	if opt.force
		bDo	= true(sz);
	else
		bDo	= ~cellfun(@RandomiseOutputExists,cPathOut);
	end

%randomise!
	b	= true(sz);
	
	if any(bDo(:))
		cInput	=	{
						cPathData(bDo)
						d(bDo)
						cPathOut(bDo)
						cPathMask(bDo)
						tContrast(bDo)
						fTest(bDo)
						exch(bDo)
						param
					};
		
		b(bDo)	= MultiTask(@RandomiseOne,cInput,...
					'description'	, 'calling randomise'	, ...
					'uniformoutput'	, true					, ...
					'cores'			, opt.cores				, ...
					'silent'		, opt.silent			  ...
					);
	end

if ~bCell
	cPathOut	= cPathOut{1};
end


%------------------------------------------------------------------------------%
function b = RandomiseOne(strPathData,d,strPathOut,strPathMask,tContrast,fTest,exch,param)
	b	= false;
	
	[strDirOut,strFileOut]	= PathSplit(strPathOut);
	
	%write the FSL design files
		strName	= sprintf('%s_design',strFileOut);
		
		[strPathD,strPathCT,strPathF,strPathE]	= FSLWriteDesign(d,tContrast,fTest,exch,...
													'dir_out'	, strDirOut	, ...
													'name'		, strName	  ...
													);
	
	%construct the call to randomise
		cOption	=	{
						'-i' strPathData		, ...
						'-o' strPathOut			, ...
						'-d' strPathD			, ...
						'-t' strPathCT			, ...
						'-n' param.permutations	  ...
					};
		
		%demean
			if param.demean
				cOption	= [cOption '-D'];
			end
		%one-sample group-mean test
			if param.onesample
				cOption	= [cOption '-1'];
			end
		%mask
			if ~isempty(strPathMask)
				cOption	= [cOption {'-m' strPathMask}];
			end
		%f-test
			if ~isempty(fTest)
				cOption	= [cOption {'-f' strPathF}];
			end
		%exchangeability block
			if ~isempty(exch)
				cOption	= [cOption {'-e' strPathE}];
			end
		%correct p-values
			if ismember('fwe',param.pcorrect)
				cOption	= [cOption '-x'];
			end
		%tfce
			if param.tfce
				cOption	= [cOption '-T'];
			end
			
			if ~isempty(param.tfce_h)
				cOption	= [cOption sprintf('--tfce_H=%.3f',param.tfce_h)];
			end
			if ~isempty(param.tfce_d)
				cOption	= [cOption sprintf('--tfce_D=%.3f',param.tfce_d)];
			end
			if ~isempty(param.tfce_e)
				cOption	= [cOption sprintf('--tfce_E=%.3f',param.tfce_e)];
			end
			if ~isempty(param.tfce_c)
				cOption	= [cOption sprintf('--tfce_C=%.3f',param.tfce_c)];
			end
		%cluster thresholding
			if ~isempty(param.clusterthresh)
				cOption	= [cOption {'-c' param.clusterthresh}];
			end
			if ~isempty(param.clustermassthresh)
				cOption	= [cOption {'-C' param.clustermassthresh}];
			end
			if ~isempty(param.fclusterthresh)
				cOption	= [cOption {'-F' param.fclusterthresh}];
			end
			if ~isempty(param.fclustermassthresh)
				cOption	= [cOption {'-S' param.fclustermassthresh}];
			end
		%variance smooth t-stats
			if ~isempty(param.vsmooth)
				cOption	= [cOption {'-v' param.vsmooth}];
			end
		%cluster normalization thresholding
			if param.twopass
				cOption	= [cOption '--twopass'];
			end
		%output raw stat images
			if param.raw
				cOption	= [cOption '-R'];
			end
		%output uncorrected p-value images
			if param.uncorrp
				cOption	= [cOption '--uncorrp'];
			end
		%output permutation vector text file
			if param.permtxt
				cOption	= [cOption '-P'];
			end
		%output null distribution text files
			if param.nulltxt
				cOption	= [cOption '-N'];
			end
		%remove constant voxels from the mask
			if ~param.removeconstant
				cOption	= [cOption '--norcmask'];
			end
		%random seed
			if ~isempty(param.seed)
				cOption	= [cOption sprintf('--seed=%d',param.seed)];
			end
		%glm output
			if param.glmoutput
				cOption	= [cOption '--glm_output'];
			end
		
		strNameScript	= sprintf('%s_randomise',strFileOut);
		strPathScript	= PathUnsplit(strDirOut,strNameScript,'sh');
		strScript		= CallProcess('randomise',cOption,...
							'script_path'	, strPathScript	, ...
							'backup'		, false			, ...
							'run'			, false			, ...
							'silent'		, true			  ...
							);
	
	%run the script
		[ec,out]	= RunBashScript(strPathScript,...
						'description'	, sprintf('calling %s',strNameScript)	, ...
						'silent'		, param.silent							  ...
						);
		
		if ec
			warning('randomise script failed');
			return;
		end
	
	%FDR-correct the p-values
		if ismember('fdr',param.pcorrect)
			strFileOutRE	= StringForRegExp(strFileOut);
			
			cPathP	= FindFiles(strDirOut,[strFileOutRE '.*_p_']);
			
			cPathPFDR	= StatFDRCorrect(cPathP,...
							'mask'		, strPathMask	, ...
							'silent'	, param.silent	  ...
							);
		end
	
	b	= true;
%------------------------------------------------------------------------------%
function b = RandomiseOutputExists(strPathOut)
	[strDir,strPre]	= PathSplit(strPathOut);
	strPathTest		= PathUnsplit(strDir,sprintf('%s_tstat1',strPre),'nii.gz');
	
	b	= FileExists(strPathTest);
%------------------------------------------------------------------------------%
