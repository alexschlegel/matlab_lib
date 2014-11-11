function [xS,m,se] = meanScatter(x,y,varargin)
% meanScatter
% 
% Description:	calculate the mean of y values for each x value.  x and y are
%				cells of 1d x and y data.  Not each set must contain data for
%				all x values
% 
% Syntax:	[xS,m,se] = meanScatter(x,y,<options>)
% 
% In:
% 	x	- a cell of 1d x data
%	y	- a cell of 1d y data
%	<options>:
%		thresh:	(1) there must be at least thresh y values for a particular x
%				value in order to include it in the mean
% 
% Out:
% 	xS	- a 1d array of x values occurring in x and for which at least thresh y
%		  values exist
%	m	- the mean of the y values for the corresponding xS values 
%	se	- the standard error of the mean
% 
% Updated: 2011-02-18
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgs(varargin,...
		'thresh'	, 1	  ...
		);

x	= ForceCell(x);
y	= ForceCell(y);

%get a vector of x and y values
	x	= append(x{:});
	y	= append(y{:});
%get the unique x values
	xS	= unique(x);
%get the y positions for each x
	kY	= arrayfun(@(xs) find(x==xs),xS,'UniformOutput',false);
%find suprathreshold x values
	bS	= cellfun(@(k) numel(k)>=opt.thresh,kY);
%get the mean and stderr for suprathreshold x values
	xS	= xS(bS);
	kY	= kY(bS);
	m	= cellfun(@(k) mean(y(k)),kY);
	se	= cellfun(@(k) conditional(numel(k)>1,stderr(y(k)),NaN),kY);
