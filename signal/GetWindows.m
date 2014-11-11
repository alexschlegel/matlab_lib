function [xWin,kWin] = GetWindows(x,sWin,varargin)
% GetWindows
% 
% Description:	return a matrix of windows around each point of x
% 
% Syntax:	[xWin,kWin] = GetWindows(x,sWin,<options>)
% 
% In:
% 	x			- a length N vector of data
%	sWin		- the number of element in each window
%	<options>:
%		'offset'		- (sWin/2) offset of the center of the first window
%		'step'			- (sWin) distance of each window center to the previous
%						  window center
%		'pad'			- (0) how to pad window values that extend beyond the
%						  data.  can be:
%							'replicate':	repeat the first or last element
%							'symmetric':	extend symmetrically at the
%											boundaries
%							n:				fill with the specified value
%		'windowfunc'	- (<none>) a handle to the window function to use.  see
%						  window.
% 
% Out:
%	xWin	- an sWin x nWin array of the windows of x
%	kWin	- the indices in x of each element of xWin
% 
% Updated:	2009-04-03
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgs	(varargin						, ...
						'offset'		, sWin/2	, ...
						'step'			, sWin		, ...
						'pad'			, 0			, ...
						'windowfunc'	, []		  ...
					);

nData	= numel(x);


%get the centers of each window
	kCenter	= opt.offset+1:opt.step:nData;
	nWin	= numel(kCenter);
	kCenter	= repmat(kCenter,[sWin 1]);
%relative indices within each window
	kRel	= reshape(GetInterval(-sWin/2,sWin/2-1,sWin),sWin,1);
	kRel	= repmat(kRel,[1 nWin]);
%construct the window indices
	kWin	= round(kCenter + kRel);
	bLess	= kWin<1;
	bMore	= kWin>nData;
	bValid	= ~bLess & ~bMore;
	
%get the windows in x
	switch lower(opt.pad)
		case 'replicate'
			kWin(bLess)	= 1;
			kWin(bMore)	= nData;
			
			xWin	= x(kWin);
		case 'symmetric'
			kWin(bLess)	= 1-kWin(bLess);
			kWin(bMore)	= 2*nData - kWin(bMore);
			
			xWin	= x(kWin);
		otherwise
			kWin(~bValid)	= NaN;
			
			xWin			= opt.pad*ones([sWin nWin]);
			xWin(bValid)	= x(kWin(bValid));
	end
	
%optionally multiply by the window function
	if ~isempty(opt.windowfunc)
		xWin	= ApplyWindow(xWin,opt.windowfunc);
	end