function cPathEroded = MaskErode(cPathMask,varargin)
% NIfTI.MaskErode
% 
% Description:	erode a mask or set of masks as follows:
%					1) erode the mask until it is at least as small as the
%					   specified final size.
%					2) re-add enough random voxels eliminated during the last
%					   erosion to achieve the desired mask size
% 
% Syntax:	cPathEroded = NIfTI.MaskErode(cPathMask,[nVoxel]=<auto>,<options>)
% 
% In:
% 	cPathMask	- the path to a mask NIfTI file, or a cell of paths
%	[nVoxel]	- the number of voxels to include in the final mask. if this
%				  value is unspecified, it will be set to the size of the
%				  smallest input mask
%	<options>:
%		suffix:		('erode') suffix to add to the output file
%					(e.g. path_in becomes path_in-<suffix>). either a string or
%					a cell, one suffix for each input path.
%		output:		(<auto>) path/cell of paths to output files.  overrides
%					suffix.
%		cores:		(1) the number of processor cores to use
%		force:		(true) true to force creation of already existing masks
%		silent:		(false) true to suppress status messages
% 
% Out:
% 	cPathEroded	- the path/cell of paths to the eroded masks
% 
% Updated: 2015-05-01
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
[nVoxel,opt]	= ParseArgs(varargin,[],...
					'suffix'	, 'erode'	, ...
					'output'	, []		, ...
					'cores'		, 1			, ...
					'force'		, true		, ...
					'silent'	, false		  ...
					);

[cPathMask,opt.suffix,opt.output,bNoCell,b,b]	= ForceCell(cPathMask,opt.suffix,opt.output);
[cPathMask,opt.suffix,opt.output]				= FillSingletonArrays(cPathMask,opt.suffix,opt.output);

%get the output file paths
	cPathEroded	= cellfun(@(fi,fo,s) conditional(~isempty(fo),fo,PathAddSuffix(fi,['-' s],'favor','nii.gz')),cPathMask,opt.output,opt.suffix,'UniformOutput',false);

%get the number of voxels in the eroded mask
	if isempty(nVoxel)
		cMask	= cellfun(@GetMask,cPathMask,'UniformOutput',false);
		nVoxel	= min(cellfun(@(m) sum(m.data(:)),cMask));
	else
		cMask	= cPathMask;
	end

%erode!
	if opt.force
		bDo	= true(size(cPathMask));
	else
		bDo	= ~FileExists(cPathEroded);
	end
	
	MultiTask(@ErodeOne,{cMask(bDo) nVoxel cPathEroded(bDo)},...
		'description'	, 'eroding masks'	, ...
		'cores'			, opt.cores			, ...
		'silent'		, opt.silent		  ...
		);

%format the output
	if bNoCell
		cPathEroded	= cPathEroded{1};
	end

%------------------------------------------------------------------------------%
function msk = GetMask(x)
	if ischar(x)
		msk	= NIfTI.Read(x);
	else
		msk	= x;
	end
%------------------------------------------------------------------------------%
function ErodeOne(msk,nVoxel,strPathEroded)
	%get the mask
		msk			= GetMask(msk);
		msk.data	= logical(msk.data);
	
	%make sure something erodes
		d		= padarray(msk.data,[1 1 1]);
	%erode until we have fewer voxels than we want
		se		= MaskBall([1 1 1]);
		dLast	= -1;
		while sum(d(:))>nVoxel
			dLast	= d;
			d		= imerode(d,se);
		end
	
	if ~isequal(dLast,-1)
	%we at least did something
		%now re-add voxels that were just eliminated
			dDiff	= dLast & ~d;
			kDiff	= find(dDiff);
			kAdd	= randsample(kDiff,nVoxel - sum(d(:)));
			d(kAdd)	= true;
		%unpad the mask
			d	= d(2:end-1,2:end-1,2:end-1);
		%done!
			msk.data	= d;
	end
	
	NIfTI.Write(msk,strPathEroded);
%------------------------------------------------------------------------------%
