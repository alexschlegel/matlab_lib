function fmr = bvFMRAverageVolume(cPathFMR,varargin)
% bvFMRAverageVolume
% 
% Description:	create a single volume FMR that represents the average of all
%				volumes of a set of FMRs
% 
% Syntax:	fmr = bvFMRAverageVolume(cPathFMR,<options>)
% 
% In:
% 	cPathFMR	- the path to an FMR file or a cell of paths
%	<options>:
%		'stcprefix':	('average-') prefix for STC files
%		'silent':		(false) true to not display progress messages
% 
% Assumptions:	assumes all FMRs have the same number of slices
% 
% Out:
% 	fmr	- the average FMR
% 
% Updated:	2010-04-17
% Copyright 2010 Alex Schlegel (alex@roguecheddar.com).  All Rights Reserved.
opt	= ParseArgsOpt(varargin, ...
					'stcprefix'	, 'average-'	, ...
					'silent'	, false	 		  ...
					);

cPathFMR	= ForceCell(cPathFMR);
nFMR		= numel(cPathFMR);

%sum each volume
	if ~opt.silent
		progress(nFMR,'label','FMR');
	end
	
	for kFMR=nFMR:-1:1
		%load the FMR
			fmr	= bless(BVQXfile(cPathFMR{kFMR}));
			
		if kFMR==nFMR
			nSlice	= numel(fmr.Slice);
			sFMR	= size(fmr.Slice(1).STCData);
			nVolPer	= sFMR(3);
			
			v		= zeros([sFMR(1:2),nSlice]);
			s		= zeros(sFMR);
		end
		
		%sum each slice
			for kSlice=1:nSlice
				s(:)			= fmr.Slice(kSlice).STCData;
				v(:,:,kSlice)	= sum(s,3);
			end
			
		if ~opt.silent
			progress;
		end
		
		if kFMR~=1
			fmr	= fmr.ClearObject;
		end
	end
	
%get the mean
	v	= v ./ (nFMR.*nVolPer);
	
%insert into the fmr
	for kSlice=1:nSlice
		fmr.Slice(kSlice).STCData	= v(:,:,kSlice);
	end

	fmr.Prefix	= opt.stcprefix;