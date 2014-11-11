function bSuccess = MRIConvert(cPathIn,cPathOut,varargin)
% MRIConvert
% 
% Description:	wrapper for FreeSurfer's mri_convert utility
% 
% Syntax:	bSuccess = MRIConvert(cPathIn,cPathOut,<options>)
% 
% In:
% 	cPathIn		- an input path or cell of inputs paths
%	cPathOut	- an output path or cell of output paths
%	<options>:
%		log:		(true) true/false to specify whether logs should be saved
%					to the default location, or the path/cell of paths to a log
%					file to save
%		force:		(true) reconvert if the output path already exists.  can be
%					a logical array, one for each input path
%		nthread:	(1) the number of threads to use
%		silent:		(false) true to suppress status messages
% 
% Out:
% 	bSuccess	- a logical array indicating which files were successfully
%				  converted
% 
% Updated: 2011-03-07
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgs(varargin,...
		'log'		, true	, ...
		'force'		, true	, ...
		'nthread'	, 1		, ...
		'silent'	, false	  ...
		);

[cPathIn,cPathOut]				= ForceCell(cPathIn,cPathOut);
[cPathIn,cPathOut,opt.force]	= FillSingletonArrays(cPathIn,cPathOut,opt.force);
sConvert						= size(cPathIn);
nConvert						= numel(cPathIn);

%get the log paths
	if isequal(opt.log,true)
		[cPathScript,cPathLog]	= deal(cellfun(@(fi) PathGetDir(PathRel2Abs(fi)),cPathIn,'UniformOutput',false));
	elseif isequal(opt.log,false)
		[cPathScript,cPathLog]	= deal([]);
	else
		cPathLog	= ForceCell(opt.log);
		cPathScript	= cellfun(@(fl) PathAddSuffix(fl,'','sh'),cPathLog,'UniformOutput',false);
	end
%get the files to process
	bDo	= opt.force | ~FileExists(cPathOut);
%process each file
	bSuccess		= true(sConvert);
	if any(bDo(:))
		bSuccess(bDo)	= ~CallProcess('mri_convert',{cPathIn(bDo) cPathOut(bDo)},...
							'description'	, 'Converting MRI Data'	, ...
							'script_path'	, cPathScript			, ...
							'log_path'		, cPathLog				, ...
							'nthread'		, opt.nthread			, ...
							'silent'		, opt.silent			  ...
							);
	end
