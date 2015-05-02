function [b,cPathOut] = FSLROI(cPathIn,cExtent,varargin)
% FSLROI
% 
% Description:	call fslroi to extract volumes from a NIfTI file
% 
% Syntax:	[b,cPathOut] = FSLROI(cPathIn,cExtent,<options>)
% 
% In:
% 	cPathIn	- the path to a data file, or a cell of paths
%	cExtent	- an array of extent options for fslroi, or a cell of arrays (one
%			  for each dataset). e.g. to extract the volumes 1 through 4 from a
%			  4D dataset, this would be [0 4] (indices are 0-based)
%	<options>:
%		output:		(<auto>) the output path, or a cell of paths
%		cores:		(1) the number of processor cores to use
%		force:		(true) true to force extraction of the output file already
%					exists
%		silent:		(false) true to suppress status messages
% 
% Out:
% 	b			- a logical array indicating which files were successfully
%				  extracted
%	cPathOut	- a the output path or a cell of paths
% 
% Updated: 2015-05-01
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%process the input
	opt	= ParseArgs(varargin,...
			'output'	, []	, ...
			'cores'		, 1		, ...
			'force'		, true	, ...
			'silent'	, false	  ...
			);
	
	[cPathIn,cExtent,cPathOut,bNoCell,dummy,dummy]	= ForceCell(cPathIn,cExtent,opt.output);
	
	[cPathIn,cExtent,cPathOut]	= FillSingletonArrays(cPathIn,cExtent,cPathOut);
	
	cPathOut	= cellfun(@ParseOutputPath,cPathIn,cPathOut,cExtent,'uni',false);

%which data need processing?
	sz	= size(cPathIn);
	b	= true(sz);
	
	if opt.force
		bDo	= true(sz);
	else
		bDo	= ~FileExists(cPathOut);
	end

%call fslroi
	if any(bDo(:))
		b(bDo)	= MultiTask(@ROIOne,{cPathIn(bDo) cPathOut(bDo) cExtent(bDo) opt},...
					'description'	, 'extracting volumes'	, ...
					'uniformoutput'	, true					, ...
					'cores'			, opt.cores				, ...
					'silent'		, opt.silent			  ...
					);
	end

if bNoCell
	cPathOut	= cPathOut{1};
end

%------------------------------------------------------------------------------%
function b = ROIOne(strPathIn,strPathOut,extent,opt)
	%call fslroi
		cOption	= [strPathIn strPathOut arrayfun(@num2str,extent,'uni',false)];
		
		[ec,out]	= CallProcess('fslroi',cOption,'silent',true);
	%was it successful?
		b	= ec==0;
%------------------------------------------------------------------------------%
function strPathOut = ParseOutputPath(strPathIn,strPathOut,extent) 
	if isempty(strPathOut)
		strPathOut	= PathAddSuffix(strPathIn,['-' join(extent,'_')],'favor','nii.gz');
	end
%------------------------------------------------------------------------------%