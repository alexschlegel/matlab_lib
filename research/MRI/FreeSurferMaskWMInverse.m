function [bSuccess,cPathWMInv] = FreeSurferMaskWMInverse(cDirSubject,varargin)
% FreeSurferMaskWMInverse
% 
% Description:	create binary mask of everything but white matter using
%				segmentation data from FreeSurfer
% 
% Syntax:	[bSuccess,cPathWMInv] = FreeSurferMaskWMInverse(cDirSubject,<options>)
% 
% In:
% 	cDirSubject	- a subject's FreeSurfer directory, or a cell of directories
%	<options>:
%		grow:		(0) grow the inverse mask by the specified number of pixels.
%					can be negative.
%		output:		(<auto>) output file path(s)
%		log:		(true) true/false to specify whether logs should be saved
%					to the default location, or the path/cell of paths to a log
%					file to save
%		force:		(true) true to force recalculation of the mask even if the
%					output already exists
%		cores:		(1) the number of processor cores to use
%		silent:		(false) true to suppress status messages
% 
% Out:
% 	bSuccess	- a logical array indicating which masks were successfully
%				  created
%	cPathWMInv	- path/cell of paths to the inverse white matter masks
% 
% Updated: 2015-05-01
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'grow'		, 0		, ...
		'output'	, []	, ...
		'log'		, true	, ...
		'force'		, true	, ...
		'cores'		, 1		, ...
		'silent'	, false	  ...
		);

[cDirSubject,cPathWMInv,bToChar,b]	= ForceCell(cDirSubject,opt.output);
[cDirSubject,cPathWMInv]			= FillSingletonArrays(cDirSubject,cPathWMInv);
cSubject							= cellfun(@(d) char(DirSplit(d,'limit',1)),cDirSubject,'UniformOutput',false);
nSubject							= numel(cDirSubject);
sSubject							= size(cDirSubject);

bToChar	= bToChar && nSubject==1;

%use the opposite growth for the non-inverted mask
	opt.grow	= -opt.grow;
%create the binary wm masks first
	[bSuccess,cPathWM]	= FreeSurferMaskWM(cDirSubject,...
							'grow'		, opt.grow		, ...
							'log'		, opt.log		, ...
							'force'		, opt.force		, ...
							'cores'		, opt.cores		, ...
							'silent'	, opt.silent	  ...
							);
%create the inverse masks
	if any(bSuccess(:))
		bDo	= bSuccess;
		
		[b,cPathWMInv(bDo)]	= MultiTask(@MRIMaskInvert,{cPathWM(bDo),...
								'output'		, cPathWMInv(bDo)	, ...
								'force'			, opt.force			, ...
								'silent'		, opt.silent		  ...
								},...
								'description'	, 'Inverting WM Masks'	, ...
								'cores'			, opt.cores				, ...
								'silent'		, opt.silent			  ...
								);
		bSuccess(bDo)		= cell2mat(b);
		
		if ~all(bSuccess(bDo))
			status(['Could not invert white matter masks for the following subjects: ' 10 join(cSubject(bDo & ~bSuccess),10)],'warning',true,'silent',false);
		end
	end
%convert output to string
	if bToChar
		cPathWMInv	= cPathWMInv{1};
	end
