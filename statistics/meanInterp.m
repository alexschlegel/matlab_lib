function [xi,m,se] = meanInterp(x,y,varargin)
% meanInterp
% 
% Description:	interpolate multiple sets of y values into values at a common
%				set of x values and calculate the mean and standard error
% 
% Syntax:	[xi,m,se] = meanInterp(x,y,<options>)
% 
% In:
% 	x	- a cell of 1d x data
%	y	- a cell of 1d y data
%	<options>:
%		xinterp:	(<auto>) overrides ninterp.  the x values to interpolate to.
%					if left unspecified, the unique x values are used
%		method:		('linear') the interpolation method (see interp1)
% 
% Out:
% 	xi	- the x values interpolated to
%	m	- the mean of the interpolated y values
%	se	- the standard error of the mean
% 
% Updated: 2010-12-06
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgs(varargin,...
		'xinterp'	, []		, ...
		'method'	, 'linear'	  ...
		);
if isempty(opt.xinterp)
	xi	= unique(append(x{:}));
else
	xi	= opt.xinterp;
end

%eliminate blank x's
	bBlank		= cellfun(@isempty,x);
	x(bBlank)	= [];
	y(bBlank)	= [];
%interpolate each set of y's
	y	= cellfun(@(x,y) interp1(x,y,xi,opt.method),x,y,'UniformOutput',false);
%calculate the mean and se
	[y,n]	= stack(y{:});
	m		= nanmean(y,n);
	se		= nanstderr(y,[],n);
