function k = f2k(f,fs,nFFT,varargin)
% f2k
% 
% Description:	convert a frequency to the corresponding position of a power
%				spectrum
% 
% Syntax:	k = f2k(f,fs,nFFT,[bUpper]=false)
% 
% In:
% 	f			- the frequency, in Hz
%	fs			- the sampling frequency of the data
%	nFFT		- the number of elements in the fft
%	[bUpper]	- true to return the k corresponding to the higher of the two
%				  fft elements corresponding to the frequency
% 
% Out:
% 	k	- the index of f in an fft/power spectrum
% 
% Updated:	2010-07-01
% Copyright 2008 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
bUpper	= ParseArgs(varargin,false);

if bUpper
	k	= round(nFFT - f.*nFFT./fs+1);
else
	k	= round(f.*nFFT./fs + 1);
end
