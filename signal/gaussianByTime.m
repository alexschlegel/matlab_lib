function g = gaussianByTime(w,s,fs,varargin)
% gaussianByTime
% 
% Description:	return a gaussian filter constructed using time arguments
% 
% Syntax:	g = gaussianByTime(w,s,fs,[wType]='time')
% 
% In:
% 	w	- the width of the filter, in ms or standard deviations
%	s	- the standard deviation of the filter, in s
%	fs	- the sampling frequency, in Hz
%	[wType]	- 'time' of w is in s, 'sigma' if w is in standard deviations
% 
% Out:
% 	g	- the filter (1xN)
% 
% Updated:	2008-11-07
% Copyright 2008 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
wTime	= ParseArgs(varargin,'time');

s	= s * fs;

switch wTime
	case 'sigma'
		w	= round(w*s);
	otherwise
		w	= round(w*fs);
end

g	= fspecial('gaussian',[1 w],s);
