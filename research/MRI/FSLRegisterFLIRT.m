function [bSuccess,cPathOut,cPathMAT] = FSLRegisterFLIRT(cPathIn,cPathRef,varargin)
% FSLRegisterFLIRT
% 
% Description:	wrapper for FSL's flirt tool
% 
% Syntax:	[bSuccess,cPathOut,cPathMAT] = FSLRegisterFLIRT(cPathIn,cPathRef,<options>)
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
%		tkregfirst:	(false) true to construct an initial transformation .mat
%					file using tkregister2
%		init:		([]) a path/cell of paths to the initial transformation .mat
%					files.  overrides tkregfirst.
%		xfm:		([]) a path/cell of paths to transformation .mat files to
%					apply to the input rather than estimating registration
%					parameters.  overrides tkregfirst and init.
%		interp:		(<flirt default>) the interpolation method
%		force:		(true) true to force registration even if output files
%					already exist
%		cores:		(1) the number of processor cores to use
%		silent:		(false) true to suppress status output
% 
% Out:
%	bSuccess	- a logical array indicating which processes were successful 
% 	cPathOut	- path/cell of paths to registered data files
%	cPathMAT	- path/cell of paths to transformation .mat files
% 
% Updated: 2015-05-01
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'suffix'		, []	, ...
		'output'		, []	, ...
		'tkregfirst'	, false	, ...
		'reg2first'		, false	, ...
		'init'			, []	, ...
		'xfm'			, []	, ...
		'interp'		, []	, ...
		'force'			, true	, ...
		'log'			, false	, ...%no longer implemented
		'cores'			, 1		, ...
		'silent'		, false	  ...
		);

[cPathIn,cPathRef,opt.suffix,opt.output,opt.init,opt.xfm,bToChar,b,b,b,b,b]	= ForceCell(cPathIn,cPathRef,opt.suffix,opt.output,opt.init,opt.xfm);
[cPathIn,cPathRef,opt.suffix,opt.output,opt.init,opt.xfm]						= FillSingletonArrays(cPathIn,cPathRef,opt.suffix,opt.output,opt.init,opt.xfm);

nPath		= numel(cPathIn);
sPath		= size(cPathIn);
bToChar		= bToChar && nPath==1;

bSuccess	= true(sPath);
bDo			= false(sPath);

%get the suffixes
	cSuffix		= cellfun(@(s,fr) conditional(~isempty(s),s,PathGetFilePre(fr,'favor','nii.gz')),opt.suffix,cPathRef,'UniformOutput',false);
%get the output files
	cPathOut	= cellfun(@(fi,fo,s) conditional(~isempty(fo),fo,PathAddSuffix(fi,['-' s],'favor','nii.gz')),cPathIn,opt.output,cSuffix,'UniformOutput',false);
	cPathMAT	= cellfun(@(fm,fo) conditional(~isempty(fm),fm,PathAddSuffix(fo,'','mat','favor','nii.gz')),opt.xfm,cPathOut,'UniformOutput',false);
%construct the options string
	strOpt	= conditional(isempty(opt.interp),'',[' -interp ' opt.interp]);

%construct the scripts
	cScript	= repmat({{}},sPath);
	
	for kP=1:nPath
		if ~isempty(opt.xfm{kP})
		%apply a previously created transformation matrix
			if opt.force || ~FileExists(cPathOut{kP})
				bDo(kP)	= true;
				
				cScript{kP}{end+1}	=	[
											'flirt'						...
											' -in "' cPathIn{kP} '"'	...
											' -ref "' cPathRef{kP} '"'	...
											' -init "' opt.xfm{kP} '"'	...
											' -applyxfm'				...
											' -out "' cPathOut{kP} '"'	...
											strOpt ' -v'				...
										];
			end
		else
		%affine registration
			strPathInit	= opt.init{kP};
			
			if opt.tkregfirst && isempty(strPathInit)
			%initial registration using tkregister2
				strPathInit	= PathAddSuffix(cPathOut{kP},'-fslregout','mat','favor','nii.gz');
				strPathReg	= PathAddSuffix(strPathInit,'','dat','favor','nii.gz');
				
				if bDo(kP) || opt.force || ~all(FileExists({strPathInit,strPathReg}))
				%actually do the tkregister2 registration
					bDo(kP)	= true;
					
					cScript{kP}{end+1}	=	[
												'tkregister2'						...
												' --mov "' cPathIn{kP} '"'			...
												' --targ "' cPathRef{kP} '"'		...
												' --fslregout "' strPathInit '"'	...
												' --reg "' strPathReg '"'			...
												' --regheader --noedit'			...
											];
				end
			end
			
			if bDo(kP) || opt.force || ~FileExists(cPathOut{kP})
			%actually do flirt
				bDo(kP)	= true;
				
				cScript{kP}{end+1}	=	[
											'flirt'																	...
											' -in "' cPathIn{kP} '"'												...
											' -ref "' cPathRef{kP} '"'												...
											conditional(~isempty(strPathInit),[' -init "' strPathInit '"'],'')	...
											' -omat "' cPathMAT{kP} '"'											...
											' -out "' cPathOut{kP} '"'												...
											strOpt ' -v'															...
										];
			end
		end
		
		cScript{kP}	= join(cScript{kP},10);
	end
%run the scripts
	if any(bDo(:))
		bSuccess(bDo)	= ~RunBashScript(cScript(bDo),...
							'description'	, 'Running FLIRT'		, ...
							'file_prefix'	, 'fslregisterflirt'	, ...
							'cores'			, opt.cores				, ...
							'silent'		, opt.silent			  ...
							);
	end
%convert to char if needed
	if bToChar
		cPathOut	= cPathOut{1};
		cPathMAT	= cPathMAT{1};
	end
