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
%		dim:			(NaN) number of dimensions for the dimension-reduction
%						step. set to NaN to perform automated estimation.
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
%		cores:			(1) the number of processor cores to use
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
% Updated: 2016-01-14
% Copyright 2016 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
%format the inputs
	opt	= ParseArgs(varargin,...
			'dir_out'		, []	, ...
			'comptype'		, 'ica'	, ...
			'dim'			, NaN	, ...
			'dimest'		, []	, ...
			'mindim'		, []	, ...
			'nonlinearity'	, []	, ...
			'bet'			, true	, ...
			'varnorm'		, true	, ...
			'report'		, false	, ...
			'load_comp'		, false	, ...
			'load_weight'	, false	, ...
			'cores'			, 1		, ...
			'force'			, true	, ...
			'silent'		, false	  ...
			);
	
	bNoDirOut	= isempty(opt.dir_out);
	
	opt.comptype	= CheckInput(opt.comptype,'component type',{'ica','pca'});
	
	assert(isnan(opt.dim) || isempty(opt.mindim) || opt.dim<opt.mindim,'dim option is less than mindim option.');
	
	opt_path	= optreplace(opt.opt_extra,...
					'require'	, {'functional'}	  ...
					);
	cOptPath	= opt2cell(opt_path);
	sPath		= ParseMRIDataPaths(cOptPath{:});
	
	cPathData	= sPath.functional;
	sData		= size(cPathData);
	cPathMask	= repto(ForceCell(unless(sPath.mask,[])),sData);
	cDirOut		= repto(ForceCell(opt.dir_out),sData);
	
	%cut down on the variable space for workers
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
			
			%handle the special case where no output directory was specified, we
			%only want PCA data, we specified the number of dimensions, we
			%aren't forcing computation, the outputs don't already exist, and a
			%previous run produced at least as many PCA components. in this
			%case, we will just copy a subset of the previously computed
			%components.
			if bNoDirOut && strcmp(opt.comptype,'pca') && ~isnan(opt.dim) && any(~bExist)
				[res(~bExist),bFound]	= cellfunprogress(@CheckForExistingPCA,res(~bExist),...
											'label'		, 'checking for compatible results'	, ...
											'uni'		, false								, ...
											'silent'	, opt.silent						  ...
											);
				bExist(~bExist)			= cell2mat(bFound);
			end
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
			res(bDo)	= MultiTask(@DoMELODIC,{res(bDo) opt},...
							'description'	, 'running MELODIC'	, ...
							'cores'			, opt.cores			, ...
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
function res = InitializeResults(strPathData,strPathMask,strDirOut,varargin)
	if iscell(strPathMask) && ~isempty(strPathMask)
		strDirOut	= repto(ForceCell(strDirOut),size(strPathMask));
		res			= cellfun(@(o,m) InitializeResults(strPathData,m,o),strDirOut,strPathMask,'uni',false);
	else
		[nDim,bSubPCA]	= ParseArgs(varargin,opt.dim,false);
		
		strDirOut	= ParseOutputDir(strPathData,strPathMask,strDirOut,nDim);
		
		res			= struct(...
						'success'	, true		, ...
						'error'		, []		, ...
						'dim'		, nDim		, ...
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
		
		res.path.result	= GetOutputPaths(res,bSubPCA);
		res.path.data	= res.path.result.(opt.comptype).comp_dataset;
	end
end
%------------------------------------------------------------------------------%
function strDirOut = ParseOutputDir(strPathData,strPathMask,strDirOut,nDim)
	if isempty(strDirOut)
		strDirBase	= PathGetDir(strPathData);
		
		cName	= {PathGetFilePre(strPathData,'favor','nii.gz')};
		
		if ~isempty(strPathMask)
			cName{end+1}	= PathGetMaskName(strPathMask);
		end
		if ~isnan(nDim)
			cName{end+1}	= num2str(nDim);
		end
		
		strName	= join(cName,'-');
		
		strDirOut	= DirAppend(strDirBase,sprintf('%s.ica',strName));
	end
end
%------------------------------------------------------------------------------%
function sOut = GetOutputPaths(res,bSubPCA)
	sOut	= struct(...
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
	
	if bSubPCA
		sOut.ica	= structfun2(@(f) '',sOut.ica);
	end
end
%------------------------------------------------------------------------------%
function [res,bFound] = CheckForExistingPCA(res)
	bFound	= false;
	
	%search for existing MELODIC directories
		cDir			= DirSplit(res.path.output);
		if numel(cDir)<2
			return;
		end
		
		strDirParent	= DirUnsplit(cDir(1:end-1));
		
		sMatch	= regexp(cDir{end},'^(?<pre>.+)-\d+\.ica$','names');
		if isempty(sMatch)
			return;
		end
		
		re			= ['^' StringForRegExp(sMatch.pre) '[-]?\d*\.ica$'];
		cDirMatch	= FindDirectories(strDirParent,re);
		nMatch		= numel(cDirMatch);
		if isempty(cDirMatch)
			return;
		end
	
	%get the dimension number for each matching directory
		cMatch	= cellfun(@(d) char(DirSplit(d,'limit',1)),cDirMatch,'uni',false);
		re		= ['^' StringForRegExp(sMatch.pre) '[-]?(?<dim>\d*)\.ica$'];
		sDim	= regexp(cMatch,re,'names');
	
	%do any of these work?
		for kM=1:nMatch
			if isempty(sDim{kM})
				continue;
			end
			
			nDim	= str2double(sDim{kM}.dim);
			
			if isnan(nDim)
				nDimActual	= PCADim(cDirMatch{kM});
			else
				nDimActual	= nDim;
			end
			
			if nDimActual>=opt.dim
			%match!
				[res,bFound]	= CreateSubPCA(res,cDirMatch{kM},nDim,nDimActual);
				return;
			end
		end
end
%------------------------------------------------------------------------------%
function d = PCADim(strDirMELODIC)
	strPathCompD	= PathUnsplit(strDirMELODIC,'data_pca','nii.gz');
	
	if FileExists(strPathCompD)
		sz	= NIfTI.GetSize(strPathCompD);
		d	= sz(1);
	else
		d	= 0;
	end
end
%------------------------------------------------------------------------------%
function [res,bSuccess] = CreateSubPCA(res,strDirMELODIC,nDimPre,nDimPreActual)
	bSuccess	= false;
	
	resPre	= InitializeResults(res.path.input,res.path.mask,strDirMELODIC,nDimPre);
	
	if ~all(structfun(@FileExists,resPre.path.result.pca))
		return;
	end
	
	resSub	= InitializeResults(res.path.input,res.path.mask,res.path.output,[],true);
	if ~CreateDirPath(resSub.path.output)
		return;
	end
	
	%NOTE: for some reason, melodic stores PCA data from least-significant
	%component to most-significant component (wtf?). so, we actually want to
	%keep the last components of the parent data below.
	
	%comp
		if ~FileExists(resSub.path.result.pca.comp)
			comp	= ReadComp(resPre.path.result.pca.comp);
			
			if size(comp,2)<opt.dim
				return;
			end
			
			resSub.comp	= comp(:,end-opt.dim+1:end);
			
			WriteComp(resSub.comp,resSub.path.result.pca.comp);
		end
	%dataset
		if ~FileExists(resSub.path.result.pca.comp_dataset)
			b	= FSLROI(resPre.path.result.pca.comp_dataset,[nDimPreActual-opt.dim opt.dim 0 1 0 1],...
					'output'	, resSub.path.result.pca.comp_dataset	, ...
					'force'		, true									, ...
					'silent'	, true									  ...
					);
			
			if ~b
				return;
			end
		end
	%weights
		if ~FileExists(resSub.path.result.pca.weight)
			b	= FSLROI(resPre.path.result.pca.weight,[nDimPreActual-opt.dim opt.dim],...
					'output'	, resSub.path.result.pca.weight	, ...
					'force'		, true							, ...
					'silent'	, true							  ...
					);
			
			if ~b
				return;
			end
		end
	
	res			= resSub;
	bSuccess	= true;
	
	status(sprintf('%s: using PCA data from %s',JobName(res),JobName(resPre)),'silent',opt.silent);
end
%------------------------------------------------------------------------------%
end


%------------------------------------------------------------------------------%
function res = DoMELODIC(res,opt,varargin)
	mnDim	= ParseArgs(varargin,[]);
	bMask	= ~isempty(res.path.mask);
	
	%check for required files
		if ~FileExists(res.path.input)
			res	= ProcessError(res,sprintf('%s does not exist.',res.path.input),opt);
			return;
		end
		
		if bMask && ~FileExists(res.path.mask)
			res	= ProcessError(res,sprintf('%s does not exist.',res.path.mask),opt);
			return;
		end
	
	%remove any existing files
		if isdir(res.path.output)
			rmdir(res.path.output,'s');
		end
		
	%construct the MELODIC options
		cInput	= {'-i' res.path.input};
		cOutput	= {'-o' res.path.output};
		cMask	= conditional(bMask,{'-m', res.path.mask},{});
		
		if bMask
			cBET	= {};
		else
			switch class(opt.bet)
				case 'logical'
					cBET	= conditional(opt.bet,{},{'--nomask'});
				otherwise
					cBET	= {sprintf('--bgthreshold=%d',opt.bet)};
			end
		end
		
		if ~isempty(mnDim)
			cDim	= {'-d',num2str(mnDim),'-n',num2str(mnDim)};
			cDimEst	= {};
		else
			cDim	= conditional(~isnan(opt.dim),{'-d',num2str(opt.dim),'-n',num2str(opt.dim)},{});
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
			res	= ProcessError(res,sprintf('melodic exited with status %d: %s',ec,out{1}),opt);
			return;
		end
	
	%construct the output data files
		res	= ConstructOutputDatasets(res);
		if ~res.success
			return;
		end
	
	%make sure the output files were created
		if ~OutputExists(res)
			res	= ProcessError(res,'output file paths were not created',opt);
			return;
		end
	
	%construct the outputs
		res	= LoadResults(res,opt);
		if ~res.success
			return;
		end
	
	%did we get the number of dimensions that we need?
		nDim	= size(res.comp,2);
		if ~isempty(opt.mindim) && nDim<opt.mindim
			strBase	= sprintf('output dimensions (%d) were fewer than minimum (%d)',nDim,opt.mindim);
			
			if ~isempty(mnDim) %tried to get to min dim but couldn't
				strError	= sprintf('%s. aborting.',strBase);
				
				res	= ProcessError(res,strError,opt);
				
				try
					rmdir(res.path.output,'s');
				catch me
					warning('could not remove output directory: %s',res.path.output); 
				end
			else
				strWarning	= sprintf('%s: %s. rerunning...',JobName(res),strBase);
				status(strWarning,'warning',true,'silent',opt.silent);
				
				res.comp	= [];
				res.weight	= [];
				res			= DoMELODIC(res,opt,opt.mindim);
			end
		end
%------------------------------------------------------------------------------%
function res = ConstructOutputDatasets(res)
	cType	= fieldnames(res.path.result);
	nType	= numel(cType);
	
	for kT=1:nType
		strType	= cType{kT};
		sp		= res.path.result.(strType);
		
		%load the component
			[res,comp]	= LoadComp(res,opt,strType);
			
			if ~res.success
				return;
			end
		
		%reshape to nFeature x 1 x 1 x nSample
			comp	= permute(comp,[2 3 4 1]);
		
		WriteData(comp,sp.comp_dataset);
	end
end
%------------------------------------------------------------------------------%
end


%------------------------------------------------------------------------------%
function strName = JobName(res)
	strSession	= PathGetSession(res.path.input);
	cName		= {strSession};
	
	if ~isempty(res.path.mask)
		cName{end+1}	= PathGetMaskName(res.path.mask);
	end
	
	strDim			= conditional(isnan(res.dim),'auto',num2str(res.dim));
	cName{end+1}	= strDim;
	
	strName	= join(cName,'/');
end
%------------------------------------------------------------------------------%
function b = OutputExists(res)
	b	= FileExists(res.path.data);
end
%------------------------------------------------------------------------------%
function res = LoadResults(res,opt)
	if opt.load_comp
		res	= LoadComp(res,opt);
		if ~res.success
			return;
		end
	end
	
	if opt.load_weight
		res	= LoadWeight(res,opt);
		if ~res.success
			return;
		end
	end
end
%------------------------------------------------------------------------------%
function [res,comp] = LoadComp(res,opt,varargin)
	strType		= ParseArgs(varargin,opt.comptype);
	strPathComp	= res.path.result.(strType).comp;
	
	if ~FileExists(strPathComp)
		res		= ProcessError(res,sprintf('%s does not exist.',strPathComp),opt);
		comp	= [];
	else
		if strcmp(strType,opt.comptype)
			if isempty(res.comp)
				comp		= ReadComp(strPathComp);
				res.comp	= comp;
			else
				comp	= res.comp;
			end
		else
			comp	= ReadComp(strPathComp);
		end
	end
end
%------------------------------------------------------------------------------%
function comp = ReadComp(strPathComp)
	comp	= importdata(strPathComp);
end
%------------------------------------------------------------------------------%
function WriteComp(comp,strPathComp)
	strComp	= join(cellstr(num2str(comp,10)),10);
	fput(strComp,strPathComp);
end
%------------------------------------------------------------------------------%
function [res,weight] = LoadWeight(res,opt,varargin)
	strType			= ParseArgs(varargin,opt.comptype);
	strPathWeight	= res.path.result.(strType).weight;
	
	if ~FileExists(strPathWeight)
		res		= ProcessError(res,sprintf('%s does not exist.',strPathWeight),opt);
		weight	= [];
	else
		if strcmp(strType,opt.comptype)
			if isempty(res.weight)
				weight		= ReadData(strPathWeight);
				res.weight	= weight;
			else
				weight	= res.weight;
			end
		else
			weight	= ReadData(strPathWeight);
		end
	end
end
%------------------------------------------------------------------------------%
function data = ReadData(strPathData)
	data	= NIfTI.Read(strPathData,'return','data');
end
%------------------------------------------------------------------------------%
function WriteData(data,strPathData)
	NIfTI.Write(NIfTI.Create(data),strPathData);
end
%------------------------------------------------------------------------------%
function res = ProcessError(res,strError,opt)
	res.success	= false;
	res.error	= strError;
	
	if ~opt.silent
		warning('%s: %s',JobName(res),strError);
	end
end
%------------------------------------------------------------------------------%
