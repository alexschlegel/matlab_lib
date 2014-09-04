function g = gaussianByUnit(w,s,nPer,varargin)
% gaussianByUnit
% 
% Description:	return a gaussian filter constructed using arguments in units
% 
% Syntax:	g = gaussianByUnit(w,s,nPer)
% 
% In:
% 	w		- the width of the filter, in units
%	s		- the standard deviation of the filter, in units
%	nPer	- the number of units per element of the sample (e.g. 0.1s for
%			  data sampled at 10Hz)
% 
% Out:
% 	g	- the filter (1xN)
% 
% Updated:	2008-11-08
% Copyright 2008 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
w	= u2k(w,nPer)-1;
s	= u2k(s,nPer,false)-1;

if iseven(w)
	w	= w+1;
end

g	= fspecial('gaussian',[1 w],s);
