function [b,cPathOut,cDirFEAT] = FSLConcatenate(cPathIn,varargin)
% FSLConcatenate
% 
% Description:	align and concatenate data along the 4th dimension
% 
% Syntax:	[b,cPathOut,cDirFEAT] = FSLConcatenate(cPathIn,<options>)
% 
% In:
% 	cPathIn	- a cell of files to concatenate, or a cell of cells to perform
%			  multiple concatenations
%	<options>:
%		output:				(<auto>) the output path or a cell of paths
%		alignto:			('first') the dataset to align to.  only 'first' is
%							supported.
%		alignvolume:		('mean') the volume to align.  either 'mean' to
%							align the means of each data set, or a number
%							specifying the volume to align.
%		demean:				('align') true to temporally demean each voxel
%							before concatenating, 'align' to set the mean of
%							each file to the alignment volume's mean before
%							concatenating
%		keepintermediate:	(false) true to keep the separated, aligned and
%							demeaned data files
%		copyfeat:			(true) true to copy the feat directory accompanying
%							the alignto dataset, if it can be detected, or the
%							path to the feat directory/cell of paths to copy
%		cores:				(1) the number of processor cores to use
%		force:				(true) true to force concatenation if the output
%							file already exists
%		silent:				(false) true to suppress status messages
% 
% Out:
% 	b			- a logical array indicating which sets of file were
%				  successfully concatenated
%	cPathOut	- the output path or a cell of output paths
%	cDirFEAT	- the output feat directory or cell of output feat directories
% 
% Updated: 2015-05-01
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'output'			, []		, ...
		'alignto'			, 'first'	, ...
		'alignvolume'		, 'mean'	, ...
		'demean'			, 'align'	, ...
		'keepintermediate'	, false		, ...
		'copyfeat'			, true		, ...
		'cores'				, 1			, ...
		'force'				, true		, ...
		'silent'			, false		  ...
		);

%parse the input
	opt.demean	= CheckInput(opt.demean,'demean',{'align',true,false});
	if isequal(opt.demean,'align')
		bDemeanAlign	= true;
		opt.demean		= true;
	else
		bDemeanAlign	= false;
	end
	
	bNoCell	= isempty(cPathIn) || ~iscell(cPathIn{1});
	cPathIn	= ForceCell(cPathIn,'level',2);
	cPathIn	= cellfun(@(c) reshape(c,[],1),cPathIn,'UniformOutput',false);
	
	if isempty(opt.output)
		cPathOut	= cellfun(@GetDefaultOutput,cPathIn,'UniformOutput',false);
	else
		cPathOut	= opt.output;
	end
	
	cPathOut	= reshape(cPathOut,[],1);
	cDirFEAT	= cellfun(@(f) DirAppend(PathGetDir(f),'feat_cat'),cPathOut,'uni',false);
	
	if opt.force
		bProcess	= true(size(cPathOut));
	else
		bProcess	= ~FileExists(cPathOut);
	end
	
	b	= true(size(cPathOut));
	
	if ~any(bProcess)
		return;
	end
	
	cPathInProc		= cPathIn(bProcess);
	cPathOutProc	= cPathOut(bProcess);
	cDirFEATProc	= cDirFEAT(bProcess);
	
	cPathInAll	= cat(1,cPathInProc{:});
%construct the alignment volumes
	if isa(opt.alignvolume,'char')
		opt.alignvolume	= CheckInput(opt.alignvolume,'alignvolume',{'mean'});
		
		switch opt.alignvolume
			case 'mean'
				[bs,cPathAlignAll]	= NIfTI.Mean(cPathInAll,...
										'force'		, opt.force		, ...
										'cores'		, opt.cores		, ...
										'silent'	, opt.silent	  ...
										);
		end
	else
		[bs,cPathAlignAll]	= FSLROI(cPathInAll,[opt.alignvolume-1 1],...
								'force'		, opt.force		, ...
								'cores'		, opt.cores		, ...
								'silent'	, opt.silent	  ...
								);
	end
	
	if ~all(bs)
		status(['failed to construct the following alignment volumes: ' join(cPathAlignAll(~bs),10)],'warning',true,'silent',opt.silent);
		
		b(bProcess)	= false;
		
		return;
	end
	
	cPathAlign	= mat2cell(cPathAlignAll,cellfun(@numel,cPathInProc),1);
%get the volumes to align to
	opt.alignto	= CheckInput(opt.alignto,'alignto',{'first'});
	
	switch opt.alignto
		case 'first'
			cPathAlignTo	= cellfun(@(c) repmat({c{1}},size(c)),cPathAlign,'UniformOutput',false);
			strAlignSuffix	= '2first';
	end
	
	cPathAlignToAll	= cat(1,cPathAlignTo{:});
%align!
	[bs,cPathAlignedAll,cPathMATAll]	= FSLRegisterFLIRT(cPathAlignAll,cPathAlignToAll,...
											'suffix'	, strAlignSuffix	, ...
											'force'		, opt.force			, ...
											'cores'		, opt.cores			, ...
											'silent'	, opt.silent		  ...
											);
	
	if ~all(bs)
		status(['failed to align the following data: ' join(cPathAlignAll(~bs),10)],'warning',true,'silent',opt.silent);
		
		b(bProcess)	= false;
		
		return;
	end
	
	cPathMAT	= mat2cell(cPathMATAll,cellfun(@numel,cPathInProc),1);
%transform the 4D data
	[bs,cPathInAlignedAll]	= FSLRegisterFLIRT(cPathInAll,cPathAlignToAll,...
								'suffix'	, strAlignSuffix	, ...
								'xfm'		, cPathMATAll		, ...
								'force'		, opt.force			, ...
								'cores'		, opt.cores			, ...
								'silent'	, opt.silent		  ...
								);
	
	if ~all(bs)
		status(['failed to align the following data: ' join(cPathInAll(~bs),10)],'warning',true,'silent',opt.silent);
		
		b(bProcess)	= false;
		
		return;
	end
	
	cPathInAligned	= mat2cell(cPathInAlignedAll,cellfun(@numel,cPathInProc),1);
%demean
	if opt.demean
		if bDemeanAlign
			vMean	= cPathAlignToAll;
		else
			vMean	= 0;
		end
		
		[bs,cPathDemeanedAll]	= FSLDemean(cPathInAlignedAll,...
									'mean'		, vMean			, ...
									'force'		, opt.force		, ...
									'cores'		, opt.cores		, ...
									'silent'	, opt.silent	  ...
									);
		
		if ~all(bs)
			status(['failed to demean the following data: ' join(cPathDemeanedAll(~bs),10)],'warning',true,'silent',opt.silent);
			
			b(bProcess)	= false;
			
			return;
		end
		
		cPathToMerge	= mat2cell(cPathDemeanedAll,cellfun(@numel,cPathInProc),1);
	else
		cPathToMerge	= cPathInAligned;
	end
	
%concatenate the data
	b(bProcess)	= FSLMerge(cPathToMerge,cPathOutProc,...
					'force'		, opt.force		, ...
					'cores'		, opt.cores		, ...
					'silent'	, opt.silent	  ...
					);
%copy the feat directories
	if notfalse(opt.copyfeat)
		%get the source feat directories
			if ischar(opt.copyfeat) || iscell(opt.copyfeat)
				cDirFEATFrom	= repto(ForceCell(opt.copyfeat),size(cPathOutProc));
			else
				cDirFEATFrom	= cellfun(@(cf) FSLDirFEAT(cf{1}),cPathAlignTo,'uni',false);
			end
		%copy the directories
			bCopy					= cellfun(@isdir,cDirFEATFrom);
			cDirFEATProc(~bCopy)	= {[]};
			
			cellfun(@FileCopy,cDirFEATFrom(bCopy),cDirFEATProc(bCopy));
	else
		cDirFEAT	= [];
	end
%delete the intermediate 4d data
	if ~opt.keepintermediate
		cellfun(@delete,cPathInAlignedAll);
		
		if opt.demean
			cellfun(@delete,cPathDemeanedAll);
		end
	end

if bNoCell
	cPathOut	= cPathOut{1};
end


%------------------------------------------------------------------------------%
function strPathOut = GetDefaultOutput(cPathIn)
	%are all the files in the same directory?
		bSameDir	= uniform(cellfun(@PathGetDir,cPathIn,'UniformOutput',false));
	
	if bSameDir
		strPathBase	= PathGetBase(cPathIn,'include_file',true);
		if strPathBase(end)~='_'
			strPathBase	= [strPathBase '_'];
		end
		
		strPathOut	= [strPathBase 'cat.nii.gz'];
	else
		strPathOut	= PathUnsplit(PathGetBase(cPathIn),'cat','nii.gz');
	end
end
%------------------------------------------------------------------------------%

end
