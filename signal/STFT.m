function [ft,f,t,sk] = STFT(x,rate,varargin)
% STFT
% 
% Description:	compute short-time fourier transforms of a 1D signal
% 
% Syntax:	[ft,f,t,sk] = STFT(x,rate,<options>)
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
%		fmax		(<nyquist frequency>) the maximum frequency to include in the
%					output
%		txfm:		('fft') the transform to use, either 'fft' for the fast
%					fourier transform or 'cqfft' for constant-Q fourier
%					transform.  note that STFTs calculated with cqfft cannot be
%					inverse transformed.
%		bin:		(<see cqfft>) for the cqfft transform, the number of
%					frequency bins per octave
%		mem:		(<see cqfft>) for the cqfft transform, 'large' if a large
%					amount of memory is available, 'small' otherwise
%		tsparse:	(<see cqfft>) for the cqfft transform and when mem is
%					'small', uses a sparse matrix to store the spectral kernel.
%					this is the cut-off value below which data are set to zero.
%		sk:			(<see cqfft>) for the cqfft transform, the spectral kernel
%					to use
%		cores:		(1) the number of processor cores to use
%		silent:		(false) true to suppress status messages
% 
% Out:
% 	ft	- an nF x nT array of the STFTs of x
%	f	- an nF x 1 array of the frequency at each row of ft
%	t	- an nT x 1 array of the time point at each column of ft
%	sk	- the cqfft transform, the spectral kernel used
%
% Updated: 2015-05-01
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
sk	= [];

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
			'txfm'			, 'fft'			, ...
			'bin'			, []			, ...
			'mem'			, []			, ...
			'tsparse'		, []			, ...
			'sk'			, []			, ...
			'cores'			, 1				, ...
			'silent'		, false			  ...
			);
	opt.pad		= CheckInput(opt.pad,'pad',{'symmetric','replicate','zeros'});
	opt.txfm	= CheckInput(opt.txfm,'transform',{'fft','cqfft'});
	
	opt.hop	= unless(opt.hop,opt.win/2);
	
	nWin	= t2k(opt.win,rate)-1;
	nHop	= t2k(opt.hop,rate)-1;
	
	opt.n	= unless(opt.n,nWin);
	
	opt.fmax	= unless(opt.fmax,k2f(opt.n/2+1,rate,opt.n));

%pad x so it lines up with the windows
	nSamplePad	= nHop*floor(nSample/nHop) + nWin;
	
	if nSamplePad>nSample
		nPad	= nSamplePad - nSample;
		
		switch opt.pad
			case 'symmetric'
				x	= [x; x(end:-1:end-nPad+1)];
			case 'replicate'
				x	= [x; x(end-nPad+1:end)];
			case 'zeros'
				x	= [x; zeros(nPad,1)];
		end
	end
%construct the windows
	kStart	= 1:nHop:nSample;
	t		= k2t(kStart',rate);
	kRel	= (0:nWin-1)';
	nSTFT	= numel(kStart);
	
	kWin	= repmat(kStart,[nWin 1]) + repmat(kRel,[1 nSTFT]);
	xWin	= x(kWin);
	
	clear kWin;
%apply the windowing function
	if notfalse(opt.fwin)
		xWin	= xWin .* repmat(window(opt.fwin,nWin),[1 nSTFT]);
	end
%compute the FFTs
	%calculate the spectral kernel
		if isempty(opt.sk)
			[ft,f,sk] = DoFFT([],rate,sk,opt);
		else
			sk	= opt.sk;
		end
	
	if opt.cores>1
		%break the signal up into even pieces
			kBreak	= splitup(1:nSTFT,opt.cores);
			xWin	= cellfun(@(k) xWin(:,k),kBreak,'UniformOutput',false);
		%calculate each piece
			[ft,f]	= MultiTask(@DoFFT,{xWin rate sk opt},...
						'description'	, 'Calculating FFTs'	, ...
						'cores'			, opt.cores				, ...
						'twait'			, 500					, ...
						'silent'		, opt.silent			  ...
						);
		%concatenate the pieces
			ft	= cat(2,ft{:});
			f	= f{1};
	else
		[ft,f]	= DoFFT(xWin,rate,sk,opt);
	end
	
%restrict to the specified frequencies
	kFStart	= find(f>=opt.fmin,1);
	
	fDiff	= f-opt.fmax;
	afDiff	= abs(fDiff);
	bCheck	= fDiff<=0;
	kFEnd	= find(bCheck & afDiff==min(abs(afDiff(bCheck))),1,'first');
	
	ft	= ft(kFStart:kFEnd,:);
	f	= f(kFStart:kFEnd);

%------------------------------------------------------------------------------%
function [ft,f,sk] = DoFFT(x,rate,sk,opt)
	if isempty(x)
		if isequal(opt.txfm,'cqfft') && isempty(x)
		%just calculate the spectral kernel
			fMin	= unless(opt.fmin,[],0);
			
			[ft,f,sk]	= cqfft([],rate,opt.n,...
							'bin'		, opt.bin		, ...
							'fmin'		, fMin			, ...
							'fmax'		, opt.fmax		, ...
							'mem'		, opt.mem		, ...
							'tsparse'	, opt.tsparse	, ...
							'sk'		, sk			, ...
							'silent'	, opt.silent	  ...
							);
		else
			[ft,f,sk]	= deal([]);
		end
		
		return;
	end
	
	switch opt.txfm
		case 'fft'
			ft	= fft(x,opt.n);
	
			f	= k2f((1:opt.n)',rate,opt.n);
			sk	= [];
		case 'cqfft'
			fMin	= unless(opt.fmin,[],0);
			
			[ft,f,sk]	= cqfft(x,rate,opt.n,...
							'bin'		, opt.bin		, ...
							'fmin'		, fMin			, ...
							'fmax'		, opt.fmax		, ...
							'mem'		, opt.mem		, ...
							'tsparse'	, opt.tsparse	, ...
							'sk'		, sk			, ...
							'silent'	, opt.silent	  ...
							);
	end
%------------------------------------------------------------------------------%
