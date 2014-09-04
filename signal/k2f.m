function f = k2f(k,fs,nFFT)
% f2k
% 
% Description:	convert a position of a power spectrum to its corresponding
%				frequency
% 
% Syntax:	f = k2f(k,fs,nFFT)
% 
% In:
% 	k		- the index of the power spectrum
%	fs		- the sampling frequency of the data
%	nFFT	- the number of elements in the fft
% 
% Out:
% 	f	- the frequency, in Hz, corresponding to k
% 
% Updated:	2012-09-23
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
bBig	= k>(nFFT+1)/2;

f			= zeros(size(k));
f(~bBig)	= fs.*(k(~bBig)-1)./nFFT;
f(bBig)		= fs.*(1-(k(bBig)-1)./nFFT);
