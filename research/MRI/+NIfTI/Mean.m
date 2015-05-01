function [b,cPathOut] = Mean(cPathNII,varargin)
% NIfTI.Mean
% 
% Description:	construct the temporal mean of a 4D NIfTI data set
% 
% Syntax:	[b,cPathOut] = NIfTI.Mean(cPathNII,[cPathOut]=<auto>,<options>)
% 
% In:
% 	cPathNII	- the path to a 4D NIfTI file, or a cell of paths
%	cPathOut	- the path to the output mean NIfTI file, or a cell of paths
%	<options>:
%		force:	(true) true to force calculation of the mean if the output file
%				already exists
%		cores:	(1) the number of processor cores to use
%		silent:	(false) true to suppress status messages
% 
% Out:
%	b			- true if the operation was a success
%	cPathOut	- the path/cell of paths to the output mean NIfTI file
% 
% Updated: 2015-05-01
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
[cPathOut,opt]	= ParseArgs(varargin,[],...
						'force'		, true	, ...
						'cores'		, 1		, ...
						'silent'	, false	  ...
						);

if isempty(cPathNII)
	b			= false(0);
	cPathOut	= '';
	return;
end

[cPathNII,bNoCell]	= ForceCell(cPathNII);

if isempty(cPathOut)
	cPathOut	= cellfun(@(f) PathAddSuffix(f,'-mean','favor','nii.gz'),cPathNII,'UniformOutput',false);
end

if opt.force
	bProcess	= true(size(cPathOut));
else
	bProcess	= ~FileExists(cPathOut);
end

b			= true(size(cPathNII));
b(bProcess)	= ~CallProcess('fslmaths',{cPathNII(bProcess) '-Tmean' cPathOut(bProcess)},...
				'description'	, 'calculating temporal means'	, ...
				'cores'			, opt.cores						, ...
				'silent'		, opt.silent					  ...
				);

if bNoCell
	cPathOut	= cPathOut{1};
end
