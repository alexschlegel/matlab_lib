function x = filtern(x,f,varargin)
% filtern
% 
% Description:	n-dimensional filter
% 
% Syntax:	x = filtern(x,f,<options>)
% 
% In:
% 	x	- an array
%	f	- the filter to use
%	<options>:
%		pad:		(0) how to pad the array for neighborhoods that include
%					out of bounds values.  see padarray for valid values
%		nan_ignore:	(false) true to ignore NaNs when computing neighbor sums
%		nan_keep:	(true) true to keep NaNs from the original array rather
%					than filling them in
%		nan_normf:	(true) if ignoring NaNs, true to renormalize the sum of the
%					non-NaN filter elements to the sum of all filter elements
%					before applying it to each value.  This is useful for making
%					sure ignored NaNs don't artificially alter the filtered
%					value.
% 
% Out:
% 	x	- the filtered array
% 
% Updated: 2010-05-08
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgs(varargin,...
		'pad'		, 0		, ...
		'nan_ignore', false	, ...
		'nan_keep'	, true	, ...
		'nan_normf'	, true	  ...
		);

ndX	= ndims(x);
ndF	= ndims(f);

sX	= size(x);
sF	= [size(f) ones(1,ndX-ndF)];

nX	= numel(x);
nF	= numel(f);

if opt.nan_ignore && opt.nan_keep
	bNaN	= isnan(x);
end

%pad the array
	sPad	= floor(sF/2);
	x		= padarray(x,sPad,opt.pad);
	sXP		= size(x);
	cpX		= cumprod([1 size(x)]);

%get the neighbor indices
	%relative indices
		[kF{1:ndX}]	= Coordinates(sF,'matrix');
		kF			= sub2ind(sXP,kF{:});
		kCenter		= num2cell(ceil(sF/2));
		kCenter		= sub2ind(sXP,kCenter{:});
		kF			= reshape(kF - kCenter,1,[]);
	%absolute indices
		[kX{1:ndX}]	= Coordinates(sX,'matrix',1-sPad);
		kX			= sub2ind(sXP,kX{:});
		kX			= reshape(kX,[],1);
	%add the two
		kX	= repmat(kX,[1 nF]) + repmat(kF,[nX 1]);

%multiply and sum
	if opt.nan_ignore
		sf		= sum(f(:));
		f		= repmat(reshape(f,1,[]),[nX 1]);
		
		x		= x(kX);
		
		if opt.nan_normf
			f(isnan(x))	= NaN;
			f			= sf*f./repmat(nansum(f,2),[1 nF]);
		end
		
		x	= nansum(x.*f,2);
	else
		f	= repmat(reshape(f,1,[]),[nX 1]);
		x	= sum(x(kX).*f,2);
	end
	
	x	= reshape(x,sX);
	
	if opt.nan_ignore && opt.nan_keep
		x(bNaN)	= NaN;
	end
