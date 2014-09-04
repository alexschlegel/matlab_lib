function [x,k] = DeleteOutlierSignals(x,thresh)
% DeleteOutlierSignals
% 
% Description:	remove outlier signals (based on distance from mean) from an
%				array of signals
% 
% Syntax:	[x,k] = DeleteOutlierSignals(x,thresh)
% 
% In:
% 	x		- an nSignal x nSample array of signals
%	thresh	- the maximum number of standard deviations from the mean of the
%			  entire array that a data point can be before its signal is
%			  considered an outlier
% 
% Out:
% 	x	- the signal array with outliers removed
%	k	- the indices of the signals in the original x that were removed
% 
% Updated: 2010-07-01
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

%get the mean and standard deviation
	m	= nanmean(x(:));
	sd	= nanstd(x(:));
%remove the outliers
	k		= find(any(abs(x-m)>thresh*sd,2));
	x(k,:)	= [];
