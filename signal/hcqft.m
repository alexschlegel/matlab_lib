function ft = hcqft(c,D,varargin)
% hcqft
% 
% Description:	construct the high-quefrency constant-Q fourier transform
%				(magnitude) of a signal, given its MFCC
% 
% Syntax:	ft = hcqft(c,D,[kCutoff]=<half>)
% 
% In:
% 	c			- the MFCCs of the signal (see MFCC)
%	D			- the DCT transform applied to the CQFT (see MFCC)
%	[kCutoff]	- the index cutoff between low- and high-quefrencies
% 
% Out:
% 	ft	- the low-quefrency constant-Q fourier transform magnitude
% 
% Updated: 2012-09-23
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
kCutoff	= ParseArgs(varargin,floor(size(D,1)/2));

k	= kCutoff+1:size(D,1);
ft	= 10.^( D(k,:)' * c(k,:) );
