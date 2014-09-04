function [b,cPathOut] = FSLExtract(cPathIn,kVol,varargin)
% FSLExtract
% 
% Description:	extract volumes from a 4D data file
% 
% Syntax:	[b,cPathOut] = FSLExtract(cPathIn,kVolume,<options>)
% 
% In:
% 	cPathIn	- the path to a 4D data file, or a cell of paths
%	kVol	- the volume to extract, or a cell of volumes (1-based)
%	<options>:
%		output:		(<auto>) the output path, or a cell of paths
%		nthread:	(1) the number of threads to use
%		force:		(true) true to force extraction of the output file already
%					exists
%		silent:		(false) true to suppress status messages
% 
% Out:
% 	b			- a logical array indicating which files were successfully
%				  extracted
%	cPathOut	- a the output path or a cell of paths
% 
% Updated: 2012-04-05
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgsOpt(varargin,...
		'output'	, []	, ...
		'nthread'	, 1		, ...
		'force'		, true	, ...
		'silent'	, false	  ...
		);

[cPathIn,kVol,cPathOut,bNoCell,dummy,dummy]	= ForceCell(cPathIn,kVol,opt.output);

[cPathIn,kVol,cPathOut]	= FillSingletonArrays(cPathIn,kVol,cPathOut);
sExtract				= size(cPathIn);
nExtract				= numel(cPathIn);

cPathOut	= cellfun(@(fo,fi,v) unless(fo,PathAddSuffix(fi,['-' num2str(v)],'favor','nii.gz')),cPathOut,cPathIn,kVol,'UniformOutput',false);

if opt.force
	bExtract	= true(sExtract);
else
	bExtract	= ~FileExists(cPathOut);
end

%make the volume 0-based
	kVol	= cellfun(@(x) x-1,kVol,'UniformOutput',false);

b			= true(sExtract);
b(bExtract)	= ~CallProcess('fslroi',{cPathIn(bExtract) cPathOut(bExtract) kVol(bExtract) 1},...
				'description'	, 'Extracting volumes'	, ...
				'nthread'		, opt.nthread			, ...
				'uniformoutput'	, true					, ...
				'silent'		, opt.silent			  ...
				);
