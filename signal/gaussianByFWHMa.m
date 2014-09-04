function g = gaussianByFWHMa(w,fwhm,nPer)
% gaussianByFWHMa
% 
% Description:	return a gaussian filter with full-width at half-max fwhm
% 
% Syntax:	g = gaussianByFWHMa(w,fwhm,nPer)
% 
% In:
% 	w		- the width of the filter, in units
%	fwhm	- the FWHM of the gaussian peak, in units
%	nPer	- the number of units per element of the sample (e.g. 0.1s for
%			  data sampled at 10Hz)
% 
% Out:
% 	g	- the gaussian filter
% 
% Updated:	2008-11-08
% Copyright 2008 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
%calculate the sigma that gives fwhm
	s	= fwhm ./ sqrt(-2*log(0.5));
	
g	= gaussianByUnit(w,s,nPer);
