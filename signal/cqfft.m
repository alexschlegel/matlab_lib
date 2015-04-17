function [cqft,f,sk] = cqfft(x,rate,varargin)
% cqfft
% 
% Description:	constant-Q fourier transform
% 
% Syntax:	[cqft,f,sk] = cqfft(x,rate,[n]=<size(x,dim)>,[dim]=<first non-singleton>,<options>)
% 
% In:
% 	x		- 1D signal or 2D array of signals
%	rate	- the sampling frequency of the signal, in Hz
%	[n]		- perform the n-point FFT
%	[dim]	- operate along dimension dim
%	<options>:
%		sk:			(<calculate>) the spectral kernel to use
%		bin:		(12) the number of frequency bins to calculate per octave
%		fmin:		(<min at resolution>) the minimum resolution to resolve
%		fmax:		(<max at resolution>) the maximum resolution to resolve
%		mem:		('large') 'large' if a large amount of memory is available,
%					'small' otherwise
%		tsparse:	(0.0054) when mem is 'small', uses a sparse matrix to store
%					the spectral kernel.  this is the cut-off value below which
%					data are set to zero.
%		silent:		(false) true to suppress status messages
% 
% Out:
% 	cqft	- the constant-Q fourier transform of x
%	f		- the frequency at the center of each cqft component
%	sk		- the spectral kernal used
%
% Notes:
%	algorithm adapted from:
%		http://wwwmath.uni-muenster.de/logik/Personen/blankertz/constQ/constQ.html#eqn:XcqDirect
%	which is based on:
%		Brown JC, and Puckette MS (1992). An efficient algorithm for the calculation of a constant Q transform. J. Acoust. Soc. Am., 92(5): 2698-2701.
% 
% Updated: 2015-04-08
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
s	= size(x);

if numel(s)>2
	error('cqfft does not supported dimensions greater than 2.');
end

%parse the optional arguments
	[n,dim,opt]	= ParseArgs(varargin,[],find(s~=1,1),...
					'sk'		, []		, ...
					'bin'		, 12		, ...
					'fmin'		, []		, ...
					'fmax'		, []		, ...
					'mem'		, 'large'	, ...
					'tsparse'	, 0.0054	, ...
					'silent'	, false		  ...
					);
	n			= unless(n,s(dim));
	dim			= CheckInput(dim,'dim',{1 2});
	opt.fmin	= unless(opt.fmin,rate/n);
	opt.fmax	= unless(opt.fmax,rate/2);
	opt.mem		= CheckInput(opt.mem,'mem',{'large','small'});
	
	if isempty(opt.sk)
		sk	= SpectralKernel(opt.fmin,opt.fmax,opt.bin);
	else
		sk	= opt.sk;
	end

%format the input
	bT	= dim==2;
	if bT
		x	= x';
		s	= s(end:-1:1);
	end
%calculate the transform
	ft		= fft(x,size(sk,1));
	cqft	= zeros(size(sk,2),s(2),class(x));
	
	%multiply each column by the spectral kernel
		for kC=1:s(2)
			cqft(:,kC)	= (ft(:,kC)' * sk)';
		end
%frequencies
	k	= (0:size(cqft,1)-1)';
	f	= opt.fmin * 2.^(k/opt.bin);
%transpose back
	if bT
		cqft	= cqft';
	end

%------------------------------------------------------------------------------%
function sk = SpectralKernel(fMin,fMax,nBin)
	Q		= 1/(2^(1/nBin)-1);
	K		= ceil(nBin*log2(fMax/fMin));
	
	nFFT	= 2^nextpow2(ceil(Q*rate/fMin));
	
	kWin	= 1:K;
	nWin	= ceil(Q.*rate./(fMin.*2.^((kWin-1)./nBin)));
	
	switch opt.mem
		case 'large'
			sk	= zeros(nFFT,K);
			
			for k=kWin
				sk(1:nWin(k),k)	= hamming(nWin(k))/nWin(k) .* exp(2*pi*i*Q*(0:nWin(k)-1)'/nWin(k));
			end
			
			sk							= fft(sk);
			sk(abs(sk)<=opt.tsparse)	= 0;
		case 'small'
			tk	= zeros(nFFT,1);
			
			sk	= [];
			
			progress('action','init','total',K,'label','Calculating spectral kernel','silent',opt.silent);
			for k=K:-1:1
				tk(1:nWin(k))				= hamming(nWin(k))/nWin(k) .* exp(2*pi*i*Q*(0:nWin(k)-1)'/nWin(k));
				pk							= fft(tk);
				pk(abs(pk)<opt.tsparse)	= 0;
				sk							= sparse([pk sk]);
				
				progress;
			end
	end
	
	sk	= conj(sk) / nFFT;
end
%------------------------------------------------------------------------------%

end
