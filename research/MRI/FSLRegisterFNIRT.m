function [bSuccess,cPathOut,cPathWarp] = FSLRegisterFNIRT(cPathIn,cPathRef,varargin)
% FSLRegisterFNIRT
% 
% Description:	wrapper for FSL's fnirt tool
% 
% Syntax:	[bSuccess,cPathOut,cPathWarp] = FLSRegisterFNIRT(cPathIn,cPathRef,<options>)
% 
% In:
% 	cPathIn		- a path/cell of paths to the data to register
%	cPathRef	- path/cell of paths to the reference volumes
%	<options>:
%		suffix:		(PathGetFilePre(cPathRef)) suffix to add to the output file
%					(e.g. path_in becomes path_in-<suffix>).  either a string or
%					a cell, one suffix for each input path.
%		output:		(<auto>) path/cell of paths to output files.  overrides
%					suffix.
%		betfirst:	(<true unless input pre-extension file name begins with
%					'dti_' or ends with 'brain'>) true to perform bet on the
%					input first
%		tkregfirst:	(false) true to construct an initial transformation .mat
%					file using tkregister2
%		flirtfirst:	(true) true to flirt the input to the output first
%		affine:		(<none>) an affine transformation to apply to the input
%					first.  overrides tkregfirst and flirtfirst.
%		warp:		(<none>) the warp output of a previous call to
%					FSLRegisterFNIRT to apply to the input.  overrides
%					flirtfirst and betfirst.
%		config:		(<determine from ref>) the configuration file to use
%		force:		(true) true to force bet/flirt/fnirt stages even if output
%					files already exist
%		log:		(false) true/false to specify whether logs should be saved
%					to the default location, or the path/cell of paths to a log
%					file to save
%		cores:		(1) the number of processor cores to use
%		silent:		(false) true to suppress status messages
% 
% Out:
%	bSuccess	- a logical array indicating which processes were successful
% 	cPathOut	- path/cell of paths to the output files
%	cPathWarp	- path/cell of paths to the warp files (use for applying the
%				  same transformation to other data)
% 
% Updated: 2015-05-01
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'suffix'		, []	, ...
		'output'		, []	, ...
		'betfirst'		, []	, ...
		'tkregfirst'	, false	, ...
		'flirtfirst'	, true	, ...
		'affine'		, []	, ...
		'warp'			, []	, ...
		'config'		, []	, ...
		'opt'			, []	, ...
		'force'			, true	, ...
		'log'			, false	, ...
		'cores'			, 1		, ...
		'silent'		, false	  ...
		);

[cPathIn,cPathRef,opt.suffix,opt.output,opt.affine,opt.warp,opt.config,bToChar,b,b,b,b,b,b]	= ForceCell(cPathIn,cPathRef,opt.suffix,opt.output,opt.affine,opt.warp,opt.config);
[cPathIn,cPathRef,opt.suffix,opt.output,opt.affine,opt.warp,opt.config]						= FillSingletonArrays(cPathIn,cPathRef,opt.suffix,opt.output,opt.affine,opt.warp,opt.config);

sPath		= size(cPathIn);
nPath		= numel(cPathIn);
bToChar		= bToChar && nPath==1;

bSuccess	= true(nPath,1);
bDo			= false(nPath,1);

%should we bet first?
	if isempty(opt.betfirst)
		opt.betfirst	= cellfun(@(fi) isempty(regexp(PathGetFilePre(fi),'(^dti_)|(brain$)')),cPathIn);
	else
		opt.betfirst	= repto(opt.betfirst,sPath);
	end
%get the log paths
	if isequal(opt.log,true)
		[cPathScript,cPathLog]	= deal(cellfun(@(fi) PathGetDir(PathRel2Abs(fi)),cPathIn,'UniformOutput',false));
	elseif isequal(opt.log,false)
		[cPathScript,cPathLog]	= deal([]);
	else
		cPathLog	= ForceCell(opt.log);
		cPathScript	= cellfun(@(fl) PathAddSuffix(fl,'','sh'),cPathLog,'UniformOutput',false);
	end
%get the suffixes
	cSuffix		= cellfun(@(s,fr) conditional(~isempty(s),s,PathGetFilePre(fr,'favor','nii.gz')),opt.suffix,cPathRef,'UniformOutput',false);
%get the output files
	cPathOut	= cellfun(@(fi,fo,s) conditional(~isempty(fo),fo,PathAddSuffix(fi,['-' s],'favor','nii.gz')),cPathIn,opt.output,cSuffix,'UniformOutput',false);
	cPathWarp	= cellfun(@(fw,fo) conditional(~isempty(fw),fw,PathAddSuffix(fo,'-warp','favor','nii.gz')),opt.warp,cPathOut,'UniformOutput',false);

%construct each script
	cScript	= repmat({{}},[nPath 1]);
	
	for kP=1:nPath
		if ~isempty(opt.warp{kP})
		%call applywarp
			if opt.force || ~FileExists(cPathOut{kP})
				bDo(kP)	= true;
				
				cScript{kP}{end+1}	=	[	
											'applywarp'																		...
											' --ref="' cPathRef{kP} '"'													...
											' --in="' cPathIn{kP} '"'														...
											' --warp="' opt.warp{kP} '"'													...
											conditional(~isempty(opt.affine{kP}),[' --premat="' opt.affine{kP} '"'],[])	...
											' --out="' cPathOut{kP} '"'													...
										];
			end
		else
		%fnirt
			strPathRef		= cPathRef{kP};
			strPathIn		= cPathIn{kP};
			strPathInit		= '';
			strPathMAT		= opt.affine{kP};
			
			if isempty(opt.config{kP})
				strPathConfig	= FSLPathFNIRTConfig(strPathRef);
				
				if isempty(strPathConfig)
					status(['No configuration file found for ' strPathRef '.'],'silent',opt.silent);
				else
					status(['Using configuration file "' PathGetFileName(strPathConfig) '" for ' strPathIn '.'],'silent',opt.silent);
				end
			else
				strPathConfig	= FSLPathFNIRTConfig(opt.config{kP});
			end
			
			if opt.betfirst(kP)
			%bet first
				strPathRef	= PathAddSuffix(cPathRef{kP},'_brain','favor','nii.gz');
				if ~FileExists(strPathRef)
					error(['To BET ' strPathIn ' before FNIRT, ' strPathRef ' must exist.']);
				end
				
				strPathIn	= PathAddSuffix(cPathIn{kP},'-brain','favor','nii.gz');
				if bDo(kP) || opt.force || ~FileExists(strPathIn)
					bDo(kP)	= true;
					
					cScript{kP}{end+1}	= ['bet "' cPathIn{kP} '" "' strPathIn '"'];
				end
			end
			if isempty(strPathMAT) && opt.tkregfirst
			%tkregister2 based on headers first
				strPathInit	= PathAddSuffix(strPathIn,'-fslregout','mat','favor','nii.gz');
				strPathReg	= PathAddSuffix(strPathInit,'','dat');
				
				if bDo(kP) || opt.force || ~FileExists(strPathInit)
					bDo(kP)	= true;
					
					cScript{kP}{end+1}	=	[
												'tkregister2'						...
												' --mov "' strPathIn '"'			...
												' --targ "' strPathRef '"'			...
												' --fslregout "' strPathInit '"'	...
												' --reg "' strPathReg '"'			...
												' --regheader --noedit'			...
											];
				end
			end
			if isempty(strPathMAT) && opt.flirtfirst
			%FLIRT first
				strPathMAT	= PathAddSuffix(strPathIn,['-flirt-' cSuffix{kP}],'mat','favor','nii.gz');
				if bDo(kP) || opt.force || ~FileExists(strPathMAT)
					bDo(kP)	= true;
					
					cScript{kP}{end+1}	=	[
												'flirt'																	...
												' -in "' strPathIn '"'													...
												conditional(~isempty(strPathInit),[' -init "' strPathInit '"'],'')	...
												' -ref "' strPathRef '"'												...
												' -omat "' strPathMAT '"'												...
												' -v'																	...
											];
				end
			end
			
			if bDo(kP) || opt.force || ~FileExists(cPathOut{kP})
				bDo(kP)	= true;
				
				cScript{kP}{end+1}	=	[
											'fnirt'																			...
											' --in="' strPathIn '"'														...
											' --ref="' strPathRef '"'														...
											conditional(~isempty(strPathMAT),[' --aff="' strPathMAT '"'],[])				...
											' --iout="' cPathOut{kP} '"'													...
											' --cout="' cPathWarp{kP} '"'													...
											conditional(~isempty(strPathConfig),[' --config="' strPathConfig '"'],[])	...
											' -v'																			...
										];
			end
		end
		
		cScript{kP}	= join(cScript{kP},10);
	end
%run the scripts
	if any(bDo)
		bSuccess(bDo)	= ~RunBashScript(cScript(bDo),...
							'description'	, 'Running FNIRT'		, ...
							'script_path'	, cPathScript			, ...
							'log_path'		, cPathLog				, ...
							'file_prefix'	, 'fslregisterfnirt'	, ...
							'cores'			, opt.cores				, ...
							'silent'		, opt.silent			  ...
							);
	end
%convert to char if needed
	if bToChar
		cPathOut	= cPathOut{1};
		cPathWarp	= cPathWarp{1};
	end
