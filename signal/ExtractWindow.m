function [y,t] = ExtractWindow(x,tWin,varargin)
% ExtractWindow
% 
% Description:	extract windows from data
% 
% Syntax:	[y,t] = ExtractWindow(x,tWin,<options>)
% 
% In:
% 	x		- an n1 x n2 x ... x nN x nT (or nT x 1) array of timecourse data
%	tWin	- a nWindow-length array specifying the times at which to base the
%			  windows.  note that t=0 corresponds to k=1.
%	<options>:
%		mask:			(<none>) an n1 x n2 x ... x nN logical array, or an
%						nN-length array, specifying the locations to average to
%						form the extracted windows
%		start:			(0) the start time of each window, relative to the given
%						base times
%		end:			(0) the end time of each window, relative to the base
%		rate:			(1) the rate of data acquisition, using the same
%						temporal units as times given above
%		pad:			(NaN) how to pad window values that extend beyond the
%						data. can be:
%							'replicate':	repeat the first or last element
%							'symmetric':	extend symmetrically at the boundaries
%							n:				fill with the specified value
%		baseline_type:	(false) true to use the default baseline type, false to
%						skip baseline computation or one of the types described
%						in ChangeFromBaseline
%		baseline_start:	(0) the start time of the baseline calculation 
%		baseline_end:	(0) the end time of the baseline calculation
% 
% Out:
% 	y	- an nWindow x nT array of the specified windows
%	t	- an nT x 1 array of the relative time at each point in the window
% 
% Updated: 2012-04-09
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgs(varargin,...
		'mask'				, []	, ...
		'start'				, 0		, ...
		'end'				, 0		, ...
		'rate'				, 1		, ...
		'pad'				, NaN	, ...
		'baseline_type'		, false	, ...
		'baseline_start'	, 0		, ...
		'baseline_end'		, 0		  ...
		);

%get the window indices
	cOptSub	= opt2cell(rmfield(opt,{'baseline_type','baseline_start','baseline_end'}));
	
	[k,t]	= ExtractWindowIndices(size(x),tWin,cOptSub{:});
	bNaN	= isnan(k);
%get the windows
	y			= nan(size(k));
	y(~bNaN)	= x(k(~bNaN));
	
	switch lower(opt.pad)
		case {'replicate','symmetric'}
			%nothing to do, taken care of in ExtractWindowIndices
		otherwise
			y(bNaN)	= opt.pad;
	end
%average across the mask
	y	= nanmean(y,3);
%get the change from baseline
	if notfalse(opt.baseline_type)
		if islogical(opt.baseline_type)
			opt.baseline_type	= [];
		end
		
		y	= ChangeFromBaseline(y,...
				'type'	, opt.baseline_type		, ...
				't'		, t						, ...
				'start'	, opt.baseline_start	, ...
				'end'	, opt.baseline_end		, ...
				'rate'	, opt.rate				  ...
				);
	end
