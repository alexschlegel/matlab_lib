function [k,t] = ExtractWindowIndices(sData,tWin,varargin)
% ExtractWindowIndices
% 
% Description:	get the indices for window extraction
% 
% Syntax:	[k,t] = ExtractWindowIndices(sData,<options>)
% 
% In:
%	sData	- [n1 n2 ... nN nT], the size of the data from which windows are
%			  being extracted
%	tWin	- a nWin-length array specifying the times at which to base the
%			  windows.  note that t=0 corresponds to k=1.
%	<options>:
%		mask:	(<none>) an n1 x n2 x ... x nN logical array, or an nN-length
%				array, specifying the locations to average to form the extracted
%				windows
%		start:	(0) the start time of each window, relative to the base times
%		end:	(0) the end time of each window, relative to the base times
%		rate:	(1) the rate of data acquisition, using the same temporal units
%				as times given above
%		pad:	(NaN) how to pad window values that extend beyond the data.  can
%				be:
%					'replicate':	repeat the first or last element
%					'symmetric':	extend symmetrically at the boundaries
%					n:				fill with the specified value
% 
% Out:
% 	k	- an nWin x nTWin x nMask array of window indices
%	t	- an nT x 1 array of the time at each sample
% 
% Updated: 2012-04-09
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgs(varargin,...
		'mask'		, []	, ...
		'start'		, 0		, ...
		'end'		, 0		, ...
		'rate'		, 1		, ...
		'pad'		, NaN	  ...
		);

tWin	= reshape(tWin,[],1);
nWin	= numel(tWin);

%fix the input size
	nD		= numel(sData);
	nDSpace	= nD-1;
	bColumn	= nD==2 && sData(2)==1;
	
	if bColumn
		sData	= sData(end:-1:1);
	end
	
	sSpace	= sData(1:end-1);
	nSpace	= prod(sSpace);
	nT		= sData(end);
%parse the mask
	cKMask	= cell(nDSpace,1);
	
	if isempty(opt.mask)
	%use everything
		[cKMask{:}]	= ind2sub(sSpace,(1:nSpace)');
	elseif ~islogical(opt.mask) && isvector(opt.mask)
		cKMask	= reshape(num2cell(opt.mask),[],1);
	elseif islogical(opt.mask)
		[cKMask{:}]	= ind2sub(sSpace,find(opt.mask));
	else
		error('Invalid mask.');
	end
	
	cKMask	= cellfun(@(x) reshape(x,1,1,[]),cKMask,'UniformOutput',false);
	nMask	= numel(cKMask{1});
%get the base, start, and stop in index units
	kWin	= t2k(tWin,opt.rate);
	kStart	= t2k(opt.start,opt.rate)-1;
	kEnd	= t2k(opt.end,opt.rate)-1;
%get the within-window time indices
	kTWin	= kStart:kEnd;
	t		= k2t(kTWin+1,opt.rate);
	
	nTWin	= numel(kTWin);
%get the absolute time indices
	kTAbs	= repmat(kWin,[1 nTWin]) + repmat(kTWin,[nWin 1]);
	
	bLeft	= kTAbs<1;
	bRight	= kTAbs>nT;
	bIn		= ~bLeft & ~bRight;
%pad out of bounds samples
	switch lower(opt.pad)
		case 'replicate'
			kTAbs(bLeft)	= 1;
			kTAbs(bRight)	= nT;
		case 'symmetric'
			kTAbs(bLeft)	= 2 - kTAbs(bLeft);
			kTAbs(bRight)	= 2*nT - kTAbs(bRight);
		otherwise
			kTAbs(bLeft | bRight)	= NaN;
	end
%get the array indices
	cKMask	= cellfun(@(x) repmat(x,[nWin nTWin]),cKMask,'UniformOutput',false);
	kT		= repmat(kTAbs,[1 1 nMask]);
	
	k	= sub2ind(sData,cKMask{:},kT);
