function [bSuccess,cPathOut] = FSLResample(cPathIn,scale,varargin)
% FSLResample
% 
% Description:	resample a NIfTI file to a different resolution
% 
% Syntax:	[bSuccess,cPathOut] = FSLResample(cPathIn,scale,<options>)
% 
% In:
% 	cPathIn	- a path/cell of paths to the data to resample
%	scale	- the output resolution, or an array of output resolutions
%	<options>:
%		suffix:		([char(scale) 'mm']) suffix to add to the output file (e.g.
%					path_in becomes path_in-<suffix>).  either a string or a
%					cell, one suffix for each input path.
%		output:		(<auto>) path/cell of paths to output files. overrides
%					<suffix>.
%		interp:		(<flirt default>) the interpolation method
%		force:		(true) true to force resampling even if output files
%					already exist
%		cores:		(1) the number of processor cores to use
%		silent:		(false) true to suppress status output
% 
% Out:
%	bSuccess	- a logical array indicating which processes were successful 
% 	cPathOut	- path/cell of paths to resampled data files
% 
% Updated: 2015-05-01
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'suffix'		, []	, ...
		'output'		, []	, ...
		'interp'		, []	, ...
		'force'			, true	, ...
		'cores'			, 1		, ...
		'silent'		, false	  ...
		);

[cPathIn,opt.suffix,opt.output,bToChar,b,b]	= ForceCell(cPathIn,opt.suffix,opt.output);
[cPathIn,opt.suffix,opt.output,scale]		= FillSingletonArrays(cPathIn,opt.suffix,opt.output,scale);

scale	= num2cell(scale);

nPath		= numel(cPathIn);
sPath		= size(cPathIn);
bToChar		= bToChar && nPath==1;

bSuccess	= true(sPath);
bDo			= false(sPath);

%get the output files
	opt.suffix	= cellfun(@(s,res) unless(s,[num2str(res) 'mm']),opt.suffix,scale,'UniformOutput',false);
	cPathOut	= cellfun(@(fi,fo,s) conditional(~isempty(fo),fo,PathAddSuffix(fi,['-' s],'favor','nii.gz')),cPathIn,opt.output,opt.suffix,'UniformOutput',false);

%construct the options string
	strOpt	= conditional(isempty(opt.interp),'',[' -interp ' opt.interp]);

%construct the scripts
	cScript	= cell(sPath);
	
	for kP=1:nPath
		if opt.force || ~FileExists(cPathOut{kP})
			bDo(kP)	= true;
			
			s	= num2str(scale{kP});
			
			cScript{kP}	=	[
								'flirt'						...
								' -in "' cPathIn{kP} '"'	...
								' -ref "' cPathIn{kP} '"'	...
								' -applyisoxfm ' s			...
								' -out "' cPathOut{kP} '"'	...
								strOpt ' -v'				...
							];
		end
	end
%run the scripts
	if any(bDo(:))
		bSuccess(bDo)	= ~RunBashScript(cScript(bDo),...
							'description'	, 'Resampling Data'	, ...
							'cores'			, opt.cores			, ...
							'silent'		, opt.silent		  ...
							);
	end
%convert to char if needed
	if bToChar
		cPathOut	= cPathOut{1};
	end
