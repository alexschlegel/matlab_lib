function [b,cPathOut] = FSLDemean(cPathIn,varargin)
% FSLDemean
% 
% Description:	use fslmaths to temporally demean a set of 4D data files
% 
% Syntax:	[b,cPathOut] = FSLDemean(cPathIn,<output>)
% 
% In:
% 	cPathIn	- the path to a 4D data file, or a cell of paths
%	<options>:
%		output:		(<auto>) the path to the output file, or a cell of paths
%		mean:		(0) the new mean value.  can be a scalar or the path to a
%					3D data file or cell of paths to set the mean of each voxel
%		force:		(true) true to force demeaning if the output already exists
%		cores:		(1) the number of processor cores to use
%		silent:		(false) true to suppress status messages
% 
% Out:
% 	b			- a logical array indicating which files were successfully
%				  demeaned
%	cPathOut	- the output path, or a cell of paths
% 
% Updated: 2015-05-01
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'output'	, []	, ...
		'mean'		, 0		, ...
		'force'		, true	, ...
		'cores'		, 1		, ...
		'silent'	, false	  ...
		);

bNonZeroMean	= ~isequal(opt.mean,0);

[cPathIn,cPathOut,cMean,bNoCell,d,d]	= ForceCell(cPathIn,opt.output,opt.mean);
[cPathIn,cPathOut,cMean]				= FillSingletonArrays(cPathIn,cPathOut,cMean);

cPathOut	= cellfun(@(fi,fo) unless(fo,PathAddSuffix(fi,'-demean','favor','nii.gz')),cPathIn,cPathOut,'UniformOutput',false);

sPath	= size(cPathIn);

if opt.force
	bProcess	= true(sPath);
else
	bProcess	= ~FileExists(cPathOut);
end

b			= true(sPath);

if any(bProcess)
	cExtra	= conditional(bNonZeroMean,{'-add' cMean(bProcess)},{});
	
	b(bProcess)	= ~CallProcess('fslmaths',{cPathIn(bProcess),'-Tmean','-mul',-1,'-add',cPathIn(bProcess),cExtra{:},cPathOut(bProcess)},...
					'description'	, 'Demeaning data'	, ...
					'cores'			, opt.cores			, ...
					'silent'		, opt.silent		  ...
					);
end

if bNoCell
	cPathOut	= cPathOut{1};
end
