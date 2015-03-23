function res = FSLMELODIC(varargin)
% FSLMELODIC
% 
% Description:	call FSL's MELODIC tool to perform probabilistic independent
%				components analysis on a set of 4D fMRI NIfTI files
%
% WARNING:	it seems that FSL outputs PCA (and maybe ICA) signals in reversed
%			order, so that the last component in the output is actually the
%			first principal component. beware of that with the comp output from
%			this function.
% 
% Syntax:	res = FSLMELODIC(<options>)
% 
% In:
%	<options>:	see the melodic command line tool for more (and inadequate) help
%				on these options
%		<+ options for MRIParseDataPaths> (use masks option to restrict melodic
%			computation to ROIs)
%		dir_out:		(<auto>) the output directory/cell of directories. note
%						that existing directories will be removed.
%		comptype:		('ica') the return component type ('ica' or 'pca')
%		dim:			(<auto>) number of dimensions for the dimension-
%						reduction step
%		dimest:			(<auto>) the estimation technique for automatic
%						dimension reduction
%		mindim:			(<none>) the minimum number of dimensions to return
%		nonlinearity:	(<auto>) the nonlinearity to use
%		bet:			(true) true to BET the data first (if not using a mask).
%						set this to a value to use it as the brain/background
%						threshold.
%		varnorm:		(true) perform variance normalization
%		report:			(false) generate an html report
%		load_comp:		(false) load the component signals if they wouldn't have
%						been loaded otherwise
%		load_weight:	(false) load the weights
%		nthread:		(1) the number of threads to use
%		force:			(true) true to force processing even if the output files
%						already exist
%		silent:			(false) true to suppress status messages
% 
% Out:
%	res	- a struct of results:
%			success:	a logical indicating which processes completed
%						successfully
%			error:		an error message/cell of messages, if errors occurred
%			comp:		an nSample x nComponent array of PCA/ICA component
%						signals, or a cell of such
%			weight:		a 4D array of the PCA/ICA weights for each component, or
%						a cell of such
%			path:		a struct of output paths
%				data:	the path to the requested transformed data (pca or ica)
%				input:	the input data
%				mask:	the mask (if specified)
%				output:	the output directory
%				result:	a struct for each of ica and pca:
%					comp:			the component text file
%					comp_dataset:	comp transformed to a NIfTI dataset
%					weight:			the weight NIfTI file
% 
% Updated: 2015-03-23
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
%format the inputs
	opt	= ParseArgs(varargin,...
			'dir_out'		, []	, ...
			'comptype'		, 'ica'	, ...
			'dim'			, []	, ...
			'dimest'		, []	, ...
			'mindim'		, []	, ...
			'nonlinearity'	, []	, ...
			'bet'			, true	, ...
			'varnorm'		, true	, ...
			'report'		, false	, ...
			'load_comp'		, false	, ...
			'load_weight'	, false	, ...
			'nthread'		, 1		, ...
			'force'			, true	, ...
			'silent'		, false	  ...
			);
	
	opt.comptype	= CheckInput(opt.comptype,'component type',{'ica','pca'});
	
	assert(isempty(opt.dim) || isempty(opt.mindim) || opt.dim<opt.mindim,'dim option is less than mindim option.');
	
	opt_path	= optreplace(opt.opt_extra,...
					'require'	, {'functional'}	  ...
					);
	sPath		= ParseMRIDataPaths(opt_path);
	
	cPathData	= sPath.functional;
	sData		= size(cPathData);
	cPathMask	= repto(ForceCell(unless(sPath.mask,[])),sData);
	cDirOut		= repto(ForceCell(opt.dir_out),sData);
	
	%cut down on the variables space for workers
		opt	= rmfield(opt,'opt_extra');

%MELODIC!
	%initialize the outputs
		res			= cellfun(@InitializeResults,cPathData,cPathMask,cDirOut,'uni',false);
		[res,uf]	= cellnestflatten(res);
		n			= numel(res);
	
	%determine which data need to be processed
		if opt.force
			bExist	= false(n,1);
		else
			bExist	= cellfun(@OutputExists,res);
		end
	
	%load the existing results
		res(bExist)	= cellfunprogress(@(r) LoadResults(r,opt),res(bExist),...
						'label'		, 'loading existing results'	, ...
						'uni'		, false							, ...
						'silent'	, opt.silent					  ...
						);
	
	%compute the new results
		bDo	= ~bExist;
		if any(bDo)
			res(bDo)	= MultiTask(@DOMELODIC,{res(bDo) opt},...
							'description'	, 'running MELODIC'	, ...
							'nthread'		, opt.nthread		, ...
							'silent'		, opt.silent		  ...
							);
		end

%format the output struct
	res	= cellnestunflatten(res,uf);
	res	= restruct(res);
	
	if ~sPath.cell_input.mask_inner
		res	= structtreefun(@cellnestflatten,res);
	end
		
	if ~sPath.cell_input.functional
		res	= structtreefun(@(x) x{1},res);
	end


%------------------------------------------------------------------------------%
function res = InitializeResults(strPathData,strPathMask,strDirOut)
	if iscell(strPathMask) && ~isempty(strPathMask)
		strDirOut	= repto(ForceCell(strDirOut),size(strPathMask));
		res			= cellfun(@(o,m) InitializeResults(strPathData,m,o),strDirOut,strPathMask,'uni',false);
	else
		strDirOut	= ParseOutputDir(strPathData,strPathMask,strDirOut);
		
		res			= struct(...
						'success'	, true		, ...
						'error'		, []		, ...
						'comp'		, []		, ...
						'weight'	, []		, ...
						'path'		, struct(...
										'input'		, strPathData	, ...
										'mask'		, strPathMask	, ...
										'output'	, strDirOut		, ...
										'result'	, []			, ...
										'data'		, []			  ...
										)...
						);
		
		res.path.result	= GetOutputPaths(res);
		res.path.data	= res.path.result.(opt.comptype).comp_dataset;
	end
end
%------------------------------------------------------------------------------%
function strDirOut = ParseOutputDir(strPathData,strPathMask,strDirOut)
	if isempty(strDirOut)
		strDirBase	= PathGetDir(strPathData);
		strDirPre	= PathGetFilePre(strPathData,'favor','nii.gz');
		
		cDirPost	= {};
		if ~isempty(strPathMask)
			cDirPost{end+1}	= PathGetFilePre(strPathMask,'favor','nii.gz');
		end
		if ~isempty(opt.dim)
			cDirPost{end+1}	= num2str(opt.dim);
		end
		strDirPost	= conditional(isempty(cDirPost),'',['-' join(cDirPost,'-')]);
		
		strDirOut	= DirAppend(strDirBase,sprintf('%s%s.ica',strDirPre,strDirPost));
	end
end
%------------------------------------------------------------------------------%
function s = GetOutputPaths(res)
	s	= struct(...
			'pca'	, struct(...
						'comp'			, PathUnsplit(res.path.output,'melodic_dewhite')		, ...
						'comp_dataset'	, PathUnsplit(res.path.output,'data_pca','nii.gz')		, ...
						'weight'		, PathUnsplit(res.path.output,'melodic_pca','nii.gz')	  ...
						),...
			'ica'	, struct(...
						'comp'			, PathUnsplit(res.path.output,'melodic_mix')			, ...
						'comp_dataset'	, PathUnsplit(res.path.output,'data_ica','nii.gz')		, ...
						'weight'		, PathUnsplit(res.path.output,'melodic_IC','nii.gz')	  ...
						)...
			);
end
%------------------------------------------------------------------------------%
end


%------------------------------------------------------------------------------%
function res = DoMELODIC(res,opt,varargin)
	mnDim	= ParseArgs(varargin,[]);
	
	if opt.force || ~isempty(mnDim) || ~OutputExists(res)
		%remove any existing files
			if isdir(res.path.output)
				rmdir(res.path.output,'s');
			end
			
		%construct the MELODIC options
			bMask	= ~isempty(res.path.mask);
		
			cInput	= {'-i' res.path.input};
			cOutput	= {'-o' res.path.output};
			cMask	= conditional(bMask,{'-m', res.path.mask},{});
			
			if ~bMask
				switch class(opt.bet)
					case 'logical'
						cBET	= conditional(opt.bet,{},{'--nomask'});
					otherwise
						cBET	= {sprintf('--bgthreshold=%d',opt.bet)};
				end
			else
				cBET	= {};
			end
			
			if ~isempty(mnDim)
				cDim	= {'-d',num2str(mnDim),'-n',num2str(mnDim)};
				cDimEst	= {};
			else
				cDim	= conditional(opt.dim,{'-d',num2str(opt.dim),'-n',num2str(opt.dim)},{});
				cDimEst	= conditional(opt.dimest,{sprintf('--dimest=%s',opt.dimest)},{});
			end
			
			cNL			= conditional(opt.nonlinearity,{sprintf('--nl=%s',opt.nonlinearity)},{});
			cVarNorm	= conditional(opt.varnorm,{},{'-vn'});
			cReport		= conditional(opt.report,{'--report'},{});
			cPCA		= {'--Opca','--Owhite'};
			
			cOption	= [cInput cOutput cMask cBET cDim cDimEst cNL cVarNorm cReport cPCA];
		%call melodic
			[ec,out]	= CallProcess('melodic',cOption,'silent',true);
			
			if ec
				res	= ProcessError(res,sprintf('MELODIC exited with status %d: %s',ec,out{1}),opt);
				return;
			end
		%construct the output data files
			res	= ConstructOutputDatasets(res);
			if ~res.success
				return;
			end
		%make sure the output files were created
			if ~OutputExists(res)
				res	= ProcessError(res,'output file paths were not created.',opt);
				return;
			end
	end
	
	%construct the outputs
		res	= LoadResults(res,opt);
		if ~res.success
			return;
		end
	
	%did we get the number of dimensions that we need?
		nDim	= size(res.comp,2);
		if ~isempty(opt.mindim) && nDim<opt.mindim
			if ~isempty(mnDim)
				%tried to get to min dim but couldn't
				strError	= sprintf('failed to achieve minimum dimensionality (%d) for %s.',opt.mindim,res.path.input);
				res			= ProcessError(res,strError,opt);
				return;
			end
			
			strPath	= res.path.input;
			if ~isempty(res.path.mask)
				strPath	= [strPath sprintf(' (%s)',PathGetFilePre(res.path.mask,'favor','nii.gz'))];
			end
			
			strWarning	= sprintf('output dimensions (%d) were fewer than minimum (%d) for %s. rerunning...',nDim,opt.mindim,strPath);
			status(strWarning,'warning',true,'silent',opt.silent);
			
			res	= DoMELODIC(res,opt,opt.mindim);
		end
%------------------------------------------------------------------------------%
function res = ConstructOutputDatasets(res)
	cType	= fieldnames(res.path.result);
	nType	= numel(cType);
	
	for kT=1:nType
		strType	= cType{kT};
		sp		= res.path.result.(strType);
		
		%load the component
			resCur	= LoadComp(res,sp.comp,opt);
			if ~resCur.success
				res.success	= false;
				res.error	= resCur.error;
				return;
			end
			
			if strcmp(strType,opt.comptype)
				res	= resCur;
			end
		
		%reshape to nFeature x 1 x 1 x nSample
			comp	= permute(resCur.comp,[2 3 4 1]);
		
		%construct a NIfTI dataset
			nii	= make_nii(comp);
		
		%save it
			NIfTIWrite(nii,sp.comp_dataset);
	end
end
%------------------------------------------------------------------------------%
end


%------------------------------------------------------------------------------%
function b = OutputExists(res)
	b	= FileExists(res.path.data);
end
%------------------------------------------------------------------------------%
function res = LoadResults(res,opt)
	sp	= res.path.result.(opt.comptype);
	
	if opt.load_comp
		res	= LoadComp(res,sp.comp,opt);
		if ~res.success
			return;
		end
	end
	
	if opt.load_weight
		res	= LoadWeight(res,sp.weight,opt);
		if ~res.success
			return;
		end
	end
end
%------------------------------------------------------------------------------%
function res = LoadComp(res,strPathComp,opt)
	if ~FileExists(strPathComp)
		res	= ProcessError(res,sprintf('%s does not exist.',strPathComp),opt);
	elseif isempty(res.comp)
		res.comp	= str2array(fget(strPathComp));
	end
end
%------------------------------------------------------------------------------%
function res = LoadWeight(res,strPathWeight,opt)
	if ~FileExists(strPathWeight)
		res	= ProcessError(res,sprintf('%s does not exist.',strPathWeight),opt);
	elseif isempty(res.weight)
		res.weight	= getfield(NIfTIRead(strPathWeight),'data');
	end
end
%------------------------------------------------------------------------------%
function res = ProcessError(res,strError,opt)
	res.success	= false;
	res.error	= strError;
	
	if ~opt.silent
		warn(strError);
	end
end
%------------------------------------------------------------------------------%
