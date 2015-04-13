function bSuccess = MRIMaskMerge(cPathMask,strPathOut,varargin)
% MRIMaskMerge
% 
% Description:	merge a set of masks into one 3D mask file
% 
% Syntax:	bSuccess = MRIMaskMerge(cPathMask,strPathOut,<options>)
% 
% In:
% 	cPathMask	- a cell of input NIfTI mask paths, all with the same dimensions
%	strPathOut	- the output NIfTI mask path
%	<options>:
%		method:	('or') one of the following to specify how the new mask is
%				constructed:
%					'or':	output voxel is true if any of the input voxels are
%							non-zero
%					'and':	output voxel is true if all the input voxels are
%							non-zero
%					n:	output voxel is true if > n*100 percent of the input
%						voxels are non-zero
%					f:	the handle to a function that takes a list of 3D mask
%						arrays and outputs one 3D mask array
%		force:	(true) true to overwrite the output file if it already exists
%		silent:	(false) true to suppress status messages
% 
% Out:
% 	bSuccess	- true if the masks were sucessfully merged
% 
% Updated: 2015-04-13
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'method'	, 'or'	, ...
		'force'		, true	, ...
		'silent'	, false	  ...
		);

cPathMask	= ForceCell(cPathMask);

%get the merging function
	%for most methods, just copy the file if only one input is specified
		bCheckOne	= true;
	
	if ischar(opt.method)
	%preset merge method
		switch lower(opt.method)
			case 'or'
				fMerge	= @MergeOr;
			case 'and'
				fMerge	= @MergeAnd;
			otherwise
				error(['"' opt.method '" is an unrecognized merge method.']);
		end
	elseif isnumeric(opt.method)
	%threshold method
		fMerge	= @MergeThresh;
	elseif isa(opt.method,'function_handle')
	%user-specified merging function
		bCheckOne	= false;
		fMerge		= opt.method;
	else
		error('Merge method is unrecognized.');
	end

bSuccess	= false;

if opt.force || ~FileExists(strPathOut)
	status(['Merging masks to ' strPathOut],'silent',opt.silent);
	
	nMask	= numel(cPathMask);
	bExist	= FileExists(cPathMask);
	
	%check for number of masks
	if nMask==0
	%nothing to do
		status('No masks were specified.','warning',true,'silent',opt.silent);
		return;
	elseif ~all(bExist)
	%missing masks
		status(['The following masks do not exist:' 10 join(cPathMask(~bExist),10)],'warning',true,'silent',false);
		return;
	elseif bCheckOne && nMask==1
	%just copy the input mask
		if ~FileCopy(cPathMask{1},strPathOut)
			status('Could not copy the mask to the destination.','warning',true,'silent',false);
			return;
		end
	else
	%multiple masks
		%load the masks
			nii		= cellfun(@NIfTI.Read,cPathMask,'UniformOutput',false);
			niiMask	= nii{1};
			nii		= cellfun(@(x) getfield(x,'data'),nii,'UniformOutput',false);
		%merge
			niiMask.data	= fMerge(nii{:});
		
			clear nii;
		%save the merged mask
			NIfTI.Write(niiMask,strPathOut);
	end
end

bSuccess	= true;

%------------------------------------------------------------------------------%
function b = MergeOr(varargin)
	b	= stack(varargin{:});
	b	= any(b,4);
end
%------------------------------------------------------------------------------%
function b = MergeAnd(varargin)
	b	= stack(varargin{:});
	b	= all(b,4);
end
%------------------------------------------------------------------------------%
function b = MergeThresh(varargin)
	nMask	= numel(varargin);
	b		= stack(varargin{:});
	b		= sum(b,4)./nMask >= opt.method;
end
%------------------------------------------------------------------------------%

end
