function y = flatten(x,varargin)
% flatten
% 
% Description:	flatten a 3d array into a 2d array
% 
% Syntax:	y = flatten(x,<options>)
% 
% In:
% 	x	- a 3d array
%	<options>:
%		dim: 		(1)
%		method:		('max') the flattening method
%		mask:		(<none>) the mask for determining what survives thresholding.
%					either a 3d logical array the same size as x, a 3d array of
%					integers indexing separate regions in x, or a lower cutoff
%					value
%		separate:	(false) true if the mask is an index array and regions should
%					be spread out to avoid mixing
% 
% Out:
% 	y	- the flattened array
% 
% Updated: 2012-07-10
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%parse the input
	opt	= ParseArgs(varargin,...
			'dim'		, 1		, ...
			'method'	, 'max'	, ...
			'mask'		, []	, ...
			'separate'	, false	  ...
			);
	
	opt.method	= CheckInput(opt.method,'method',{'max','squish'});
%mask the array
	if ~isempty(opt.mask)
		if isequal(size(opt.mask),size(x))
			x(~logical(opt.mask))	= NaN;
		else
			x(x<opt.mask(1))		= NaN;
		end
	end

switch opt.method
	case 'max'
		y	= squeeze(nanmax(x,[],opt.dim));
	case 'squish'
		
end