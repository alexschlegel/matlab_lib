function [x,kOutlier,xOutlier] = RemoveOutliers(x,varargin)
% RemoveOutliers
% 
% Description:	remove outliers from data x
% 
% Syntax:	[x,kOutlier,xOutlier] = RemoveOutliers(x,[sdOutlier]=6,[prcMean]=90,[repMethod]='squeeze')
% 
% In:
% 	x				- an array
%	[sdOutlier]		- count elements as outliers if they lie more than sd standard
%					  deviations outside the mean
%	[prcMean]		- only consider the middle prcMean% of values when
%					  calculating mean and standard deviation
%	[repMethod]		- the method to use when replacing outliers:
%						'squeeze':	squeezes outliers less than the mean to the
%									minimum non-outlier value of x and outliers
%									greater than the mean to the maximum
%									non-outlier value of x
%						'delete':	delete outlier values from the array
%						<other>:	replace outlier values with the value
%									repMethod
% 
% Out:
% 	x			- x with outliers removed
%	kOutlier	- the indices of the outliers in x
%	xOutlier	- the values of the outliers
% 
% Updated:	2008-11-20
% Copyright 2008 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
[sdOutlier,prcMean,repMethod]	= ParseArgs(varargin,6,90,'squeeze');

prcLower	= prctile(x,50-prcMean/2);
prcUpper	= prctile(x,50+prcMean/2);
xConsider	= x(x>=prcLower & x<=prcUpper);

m	= mean(xConsider(:));
sd	= std(xConsider(:));

limLower	= m - sdOutlier*sd;
limUpper	= m + sdOutlier*sd;

bOutlier	= x < limLower | x > limUpper;
kOutlier	= find(bOutlier);
xOutlier	= x(kOutlier);

switch lower(repMethod)
	case 'squeeze'
		x(bOutlier & x<m)	= min(x(~bOutlier));
		x(bOutlier & x>=m)	= max(x(~bOutlier));
	case 'delete'
		x(bOutlier)	= [];
	otherwise
		x(bOutlier)	= repMethod;
end
