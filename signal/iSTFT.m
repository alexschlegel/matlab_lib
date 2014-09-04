function [x,t] = iSTFT(ft,rate,varargin)
% iSTFT
% 
% Description:	invert an STFT
% 
% Syntax:	[x,t] = iSTFT(ft,rate,<options>)
% 
% In:
% 	ft		- an nF x nT array of the STFTs of x
%	rate	- the sampling frequency of the original signal, in Hz
%	<options>:
%		win:	(0.25) the window duration, in seconds, used in STFT
%		hop:	(<win>/2) the hop size, in seconds, used in the STFT
%		n:		(<win size>) the n value used in the STFT
%		fwin:	(@hann) a handle to the windowing function that was used (see
%				window). set to false to skip windowing.
%		twin:	(0.1) the threshold in the original windowing function below
%				which reconstructed sample data will be ignored
% 
% Out:
% 	x	- an approximation of the original signal
%	t	- the time point of each sample
%
% Updated:	2012-09-30
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
[nPoint,nSTFT]	= size(ft);

%parse the optional arguments
	opt	= ParseArgsOpt(varargin,...
			'win'	, 0.25	, ...
			'hop'	, []	, ...
			'n'		, []	, ...
			'fwin'	, @hann	, ...
			'twin'	, 0.1	  ...
			);
	
	opt.hop	= unless(opt.hop,opt.win/2);
	
	nWin	= t2k(opt.win,rate)-1;
	nHop	= t2k(opt.hop,rate)-1;
	
	opt.n	= unless(opt.n,nWin);
%add the redundant information back to the fft
	if isodd(opt.n)
		ft	= [ft; conj(ft(end:-1:2,:))];
	else
		ft	= [ft; conj(ft(end-1:-1:2,:))];
	end
%invert the transform and the window
	wWin	= repmat(window(opt.fwin,nWin),[1 nSTFT]);
	
	ift	= real(ifft(ft,nWin)) ./ wWin;
%get the sample index associated with each sample
	kStart	= 1 + (0:nSTFT-1)*nHop;
	kRel	= (0:nWin-1)';
	
	kWin	= repmat(kStart,[nWin 1]) + repmat(kRel,[1 nSTFT]);
	nSample	= kWin(end);
%combine each sample into the reconstructed array, keeping track of its weighting
	[x,w]	= deal(zeros(nSample,1));
	
	t	= k2t((1:nSample)',rate);
	
	for kW=1:nSTFT
		bConsider	= wWin(:,kW)>=opt.twin;
		
		w(kWin(bConsider,kW))	= w(kWin(bConsider,kW)) + wWin(bConsider,kW);
		x(kWin(bConsider,kW))	= x(kWin(bConsider,kW)) + wWin(bConsider,kW).*ift(bConsider,kW);
	end
	
	x	= x ./ w;
	
	x(isnan(x))	= 0;
