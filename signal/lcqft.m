function ft = lcqft(c,D,varargin)
% lcqft
% 
% Description:	construct the low-quefrency constant-Q fourier transform
%				(magnitude) of a signal, given its CQFCC
% 
% Syntax:	ft = lcqft(c,D,[kCutoff]=<half>)
% 
% In:
% 	c			- the CQFCCs of the signal (see CQFCC)
%	D			- the DCT transform applied to the CQFT (see CQFCC)
%	[kCutoff]	- the index cutoff between low- and high-quefrencies
% 
% Out:
% 	ft	- the low-quefrency constant-Q fourier transform magnitude
% 
% Updated: 2012-11-02
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
kCutoff	= ParseArgs(varargin,floor(size(D,1)/2));

k	= 1:kCutoff;
ft	= 10.^( D(k,:)' * c(k,:) );
