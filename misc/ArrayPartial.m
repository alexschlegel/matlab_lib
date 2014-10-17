function y = ArrayPartial(x,varargin)
% ArrayPartial
% 
% Description:	get elements of an array using fractional index values
% 
% Syntax:	y = ArrayPartial(x,k1,...,kN,<options>) OR
%			y = ArrayPartial(x,p,<options>) OR
% 
% In:
% 	x	- an N-dimensional array
%	kK	- the fractional indices in the Kth coordinate.  all kK arrays must be
%		  the same size
%	p	- an M1 x ... x Mp x N array of fractional indices (i.e. kK's stacked)
%	<options>:
%		method:	('linear') the interpolation method (see interpn)
%		fill:	(NaN) fill invalid entries with this value
% 
% Out:
% 	y	- the values of x at the specified indices
% 
% Updated: 2010-12-10
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
ndX	= ndims(x);

%parse the input
	kOpt	= find(cellfun(@ischar,varargin),1);
	if isempty(kOpt)
		kOpt	= numel(varargin)+1;
	end
	
	if kOpt==2 && size(varargin{1},ndims(varargin{1}))==ndX
		k	= varargin{1};
		szK	= size(k);
		cD	= [num2cell(szK(1:end-1)) {repmat(1,[1 ndX])}];
		k	= mat2cell(k,cD{:});
	else
		k	= varargin(1:kOpt-1);
	end
	
	opt	= ParseArgs(varargin(kOpt:end),...
			'method'	, 'linear'	, ...
			'fill'		, NaN		  ...
			);
%get the interpolated y values
	cX			= cell(ndims(x),1);
	[cX{1:end}]	= Coordinates(size(x));
	
	y			= interpn(cX{:},x,k{:},opt.method);
%fill the invalid values
	if numel(opt.fill)>1 || ~isnan(opt.fill)
		y(isnan(y))	= opt.fill(:);
	end
