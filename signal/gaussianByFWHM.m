function g = gaussianByFWHM(w,hw,fs,varargin)
% gaussianByFWHM
% 
% Description:	return a gaussian filter with FWHM hw
% 
% Syntax:	g = gaussianByFWHM(w,hw,fs,[wType]='time')
% 
% In:
% 	w		- the width of the filter, in ms or standard deviations
%	hw		- the FWHM of the gaussian peak, in s
%	fs		- the sampling frequency, in Hz
%	[wType]	- 'time' if w is in s, 'sigma' if w is in standard deviations
% 
% Out:
% 	g	- the gaussian filter
% 
% Updated:	2008-11-06
% Copyright 2008 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
wTime	= ParseArgs(varargin,'time');

%calculate the sigma that gives half-width hw
	s	= hw ./ sqrt(-2*log(0.5));
	
g	= gaussianByTime(w,s,fs,wTime);
