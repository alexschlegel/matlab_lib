function [b,cPathOut] = MRIMaskDisjoint(cPathMask,varargin)
% MRIMaskDisjoint
% 
% Description:	construct disjoint versions of a set of masks (i.e. masks
%				sharing no voxels in common)
% 
% Syntax:	[b,cPathOut] = MRIMaskDisjoint(cPathMask,<options>)
% 
% In:
% 	cPathMask	- a cell of mask paths, or a cell of cells to create multiple
%				  sets of disjoint masks. in cases where a voxel exists in
%				  multiple masks, the earlier mask in the array wins
%	<options>:
%		output:	(<same name in 'disjoint' subdirectory>) a cell/cell of cells of
%				output mask paths
%		cores:	(1) the number of processor cores to use
%		force:	(true) true to force reconstruction of existing masks
%		silent:	(false) true to suppress status messages
% 
% Out:
% 	b			- an array indicating which sets were successfully created
%	cPathOut	- a cell/cell of cells of output file paths
% 
% Updated: 2015-05-01
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
if isempty(cPathMask)
	b			= [];
	cPathOut	= {};
	return;
end

%parse the inputs
	opt	= ParseArgs(varargin,...
			'output'	, []	, ...
			'cores'		, 1		, ...
			'force'		, true	, ...
			'silent'	, false	  ...
			);
	
	%make sure we have a cell of cells
		if iscell(cPathMask)
			bCellOut	= iscell(cPathMask{1});
			if ~bCellOut
				cPathMask	= {cPathMask};
			end
		else
			error('a cell of mask paths is required');
		end
	
	%get the output file paths
		cPathOut				= ForceCell(opt.output,'level',2);
		[cPathMask,cPathOut]	= FillSingletonArrays(cPathMask,cPathOut);
		[cPathMask,cPathOut]	= cellfun(@FillSingletonArrays,cPathMask,cPathOut,'uni',false);
		cPathOut				= cellfun(@(ci,co) cellfun(@ParseOutput,ci,co,'uni',false),cPathMask,cPathOut,'uni',false);

%determine which sets need to be created
	sz	= size(cPathMask);
	
	if opt.force
		bDo	= true(sz);
	else
		bDo	= cellfun(@(cf) ~all(FileExists(cf)),cPathOut);
	end

%create each disjoint set
	b	= true(sz);
	
	if any(bDo(:))
		b(bDo)	= MultiTask(@DisjointOne,{cPathMask(bDo) cPathOut(bDo)},...
					'description'	, 'computing disjoint mask sets'	, ...
					'uniformoutput'	, true								, ...
					'cores'			, opt.cores							, ...
					'silent'		, opt.silent						  ...
					);
	end

%format the output
	if ~bCellOut
		cPathOut	= cPathOut{1};
	end

%------------------------------------------------------------------------------%
function b = DisjointOne(cPathMask,cPathOut)
	b	= false;
	
	%make sure all the inputs exist
		if isempty(cPathMask)
			b	= true;
			return;
		end
		
		if ~all(FileExists(cPathMask))
			return;
		end
	
	%create the unique directories
		cDirUnique	= unique(cellfun(@PathGetDir,cPathOut,'uni',false));
		if ~all(cellfun(@CreateDirPath,cDirUnique))
			return;
		end
	
	%load the input masks
		msk		= cellfun(@NIfTI.Read,cPathMask,'uni',false);
		nMask	= numel(msk);
	
	%create each output mask
		bNo	= logical(msk{1}.data);
		sz	= size(bNo);
		for kM=2:nMask
			%make sure we have the correct space
				if ~isequal(sz,size(msk{kM}.data))
					return;
				end
			%unmark the disallowed voxels
				msk{kM}.data(bNo)	= false;
			%update the disallowed voxels
				bNo	= bNo | msk{kM}.data;
		end
	
	%save the output masks
		cellfun(@NIfTI.Write,msk,cPathOut);
	
	%success!
		b	= true;
%------------------------------------------------------------------------------%
function strPathOut = ParseOutput(strPathMask,strPathOut)
	if isempty(strPathOut)
		[strDirMask,strFileMask,strExtMask]	= PathSplit(strPathMask,'favor','nii.gz');
		
		strDirOut	= DirAppend(strDirMask,'disjoint');
		
		strPathOut	= PathUnsplit(strDirOut,strFileMask,strExtMask);
	end
%------------------------------------------------------------------------------%
