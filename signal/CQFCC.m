function [c,t,D,f,sk] = CQFCC(x,rate,varargin)
% CQFCC
% 
% Description:	compute the constant-Q frequency cepstral coefficients of a
%				signal
% 
% Syntax:	[c,t,D,f,sk] = CQFCC(x,rate,<options>)
% 
% In:
% 	x		- the signal
%	rate	- the sampling frequency of the signal, in Hz
%	<options>:
%		win:		(0.25) the window duration, in seconds
%		hop:		(<win>/2) the hop size, in seconds
%		n:			(<win size>) compute n-point FFTs for each window
%		fwin:		(@hann) a handle to the windowing function to use (see
%					window). set to false to skip windowing.
%		pad:		('symmetric') the padding method to use to make the signal
%					fit
%					with the specified windows.  one of the following:
%					'replicate', 'symmetric', 'zeros'.
%		fmin		(0) the minimum frequency to include in the output
%		fmax		(<nyquist frequency>) the maximum frequency to include in
%					the output
%		bin:		(<see cqfft>) the number of frequency bins per octave
%		coeffs:		(<total bins>) the number of coefficients to calculate 
%		mem:		(<see cqfft>) 'large' if a large amount of memory is
%					available, 'small' otherwise
%		tsparse:	(<see cqfft>) when mem is 'small', uses a sparse matrix to
%					store the spectral kernel. this is the cut-off value below
%					which data are set to zero.
%		sk:			(<see cqfft>) for the cqfft transform, the spectral kernel
%					to use
%		cores:		(1) the number of processor cores to use
%		silent:		(false) true to suppress status messages
% 
% Out:
% 	c	- an nQ x nT array of the CQFCCs at each timepoint
%	t	- an nT x 1 array of the time point at each column of ft
%	D	- the discrete cosine transform applied to the CQFT (see lcqft)
%	f	- the frequencies associated with the CQFT
%	sk	- the cqfft transform, the spectral kernel used
% 
% Updated: 2015-05-01
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
x		= reshape(x,[],1);
nSample	= numel(x);

%parse the optional arguments
	opt	= ParseArgs(varargin,...
			'win'			, 0.25			, ...
			'hop'			, []			, ...
			'n'				, []			, ...
			'fwin'			, @hann			, ...
			'pad'			, 'symmetric'	, ...
			'fmin'			, 0				, ...
			'fmax'			, []			, ...
			'bin'			, []			, ...
			'coeffs'		, []			, ...
			'mem'			, []			, ...
			'tsparse'		, []			, ...
			'sk'			, []			, ...
			'core'			, 1				, ...
			'silent'		, false			  ...
			);
	opt.pad		= CheckInput(opt.pad,'pad',{'symmetric','replicate','zeros'});
	
	opt.hop	= unless(opt.hop,opt.win/2);
	
	nWin	= t2k(opt.win,rate)-1;
	nHop	= t2k(opt.hop,rate)-1;
	
	opt.n	= unless(opt.n,nWin);
	
	opt.fmax	= unless(opt.fmax,k2f(opt.n/2+1,rate,opt.n));

%calculate the constant-Q transform of x
	[c,f,t,sk]	= STFT(x,rate,...
					'win'		, opt.win		, ...
					'hop'		, opt.hop		, ...
					'n'			, opt.n			, ...
					'fwin'		, opt.fwin		, ...
					'pad'		, opt.pad		, ...
					'fmin'		, opt.fmin		, ...
					'fmax'		, opt.fmax		, ...
					'txfm'		, 'cqfft'		, ...
					'bin'		, opt.bin		, ...
					'mem'		, opt.mem		, ...
					'tsparse'	, opt.tsparse	, ...
					'sk'		, opt.sk		, ...
					'cores'		, opt.cores		, ...
					'silent'	, opt.silent	  ...
					);
	
	nF			= size(c,1);
	opt.coeffs	= unless(opt.coeffs,nF);
%take the log of the powers
	c	= log10(constrain(abs(c),eps,inf));
%take the discrete cosine transform of each spectrum
	D	= dctmtx2(1:opt.coeffs,0:nF-1);
	c	= D * c;
