function [x,h] = signalalign(x,xRef,rate,varargin)
% signalalign
% 
% Description:	attempt to temporally align to similar signals
% 
% Syntax:	[x,h] = signalalign(x,xRef,rate,<options>)
% 
% In:
% 	x		- a signal
%	xRef	- the signal to which to align x
%	rate	- the sampling rate of the signals
%	<options>:
%		win:	(0.25) the window duration, in seconds, of the STFT calculation
%		hop:	(0.1) the hop size, in seconds, of the STFT calculation
%		n:		(<win size>) compute n-point FFTs for each window
%		fwin:	(@hann) a handle to the windowing function to use (see window).
%				set to false to skip windowing.
%		pad:	('symmetric') the padding method to use to make the signal fit
%				with the specified windows.  one of the following:  'replicate',
%				'symmetric', 'zeros'.
%		dm:		('dist') the method to use for calculating the dissimilarity
%				matrix.  either 'dist' or 'corr' (see normdissim)
%		step:	([1 1 1;1 0 1;0 1 1;1 2 2;2 1 2]) the step matrix to use when
%				calculating the minimum cost path through the x/xRef
%				dissimilarity matrix
%		debug:	(false) true to produce a debugging plot
% 
% Out:
% 	x	- the aligned signal
%	h	- a handle to the debug figure
% 
% Updated: 2012-09-24
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
h	= [];

%parse the optional arguments
	opt	= ParseArgs(varargin,...
			'win'	, 0.25								, ...
			'hop'	, 0.1								, ...
			'n'		, []								, ...
			'fwin'	, @hann								, ...
			'pad'	, 'symmetric'						, ...
			'dm'	, 'dist'							, ...
			'step'	, [1 1 1;1 0 1;0 1 1;1 2 2;2 1 2]	, ...
			'debug'	, false								  ...
			);
	opt.pad	= CheckInput(opt.pad,'pad',{'symmetric','replicate','zeros'});
	
	opt.hop	= unless(opt.hop,opt.win/2);
	
	nWin	= t2k(opt.win,rate)-1;
	
	opt.n	= unless(opt.n,nWin);

%calculate the STFT of each audio sample
	ft	= STFT(x,rate,...
			'win'	, opt.win	, ...
			'hop'	, opt.hop	, ...
			'n'		, opt.n		, ...
			'fwin'	, opt.fwin	, ...
			'pad'	, opt.pad	  ...
			);
	ftR	= STFT(xRef,rate,...
			'win'	, opt.win	, ...
			'hop'	, opt.hop	, ...
			'n'		, opt.n		, ...
			'fwin'	, opt.fwin	, ...
			'pad'	, opt.pad	  ...
			);
%calculate the low-quefrency MFCCs using the same parameters
	[c,t,D]	= MFCC(x,rate,...
					'win'	, opt.win	, ...
					'hop'	, opt.hop	  ...
					);
	
	[cR,tR,DR]	= MFCC(xRef,rate,...
					'win'	, opt.win	, ...
					'hop'	, opt.hop	  ...
					);
	
	ftL		= lcqft(c,D);
	ftLR	= lcqft(cR,DR);
%calculate a distance matrix between the two signals
	%D	= pdist2(abs(ftR)',abs(ft)');
	%D	= pdist2(ftLR',ftL');
	
	D	= normdissim(ftLR,ftL,'method',opt.dm);
%find the lowest-cost path between the diagonals of D
	[p,q,C] = dpfast(D,opt.step);
	
	if opt.debug
		fT	= 14;
		fA	= 12;
		
		tQ	= MapValue(q,min(q),max(q),min(t),max(t));
		tP	= MapValue(p,min(p),max(p),min(tR),max(tR));
		
		h		= figure;
		ps		= get(h,'Position');
		ps(1)	= 0;
		ps(3)	= 2*ps(3);
		set(h,'Position',ps,'color',[1 1 1]);
		
		h1	= subplot(121);
		imagesc(t,tR,1-D);
		set(h1,'YDir','normal');
		colormap(1-gray);
		hold on; hp=plot(tQ,tP,'r'); hold off
		set(hp,'LineWidth',2);
		set(h1,'YDir','normal');
		title('normed dissimilarity','FontSize',fT,'FontWeight','bold');
		xlabel('align t (s)','FontSize',fA);
		ylabel('reference t (s)','FontSize',fA);
		
		h2	= subplot(122);
		imagesc(t,tR,C);
		hold on; hp=plot(tQ,tP,'r'); hold off
		set(hp,'LineWidth',2);
		set(h2,'YDir','normal');
		title('cost matrix','FontSize',fT,'FontWeight','bold');
		xlabel('align t (s)','FontSize',fA);
		ylabel('reference t (s)','FontSize',fA);
	end
%calculate the warped fft
	kWarp	= arrayfun(@(k) q(find(p>=k,1)),(1:size(ftLR,2)));
	
	ftWarp	= ft(:,kWarp);
% 	tW		= GetInterval(0,1,numel(kWarp))';
% 	tX		= GetInterval(0,1,size(xRef,1))';
% 	kWarp2X	= MapValue(kWarp,1,max(kWarp),1,size(x,1))';
% 	kX		= round(interp1(tW,kWarp2X,tX,'linear'));
% 	x		= x(kX);
%reconstruct the signal
	x	= iSTFT(ftWarp,rate,...
			'win'	, opt.win	, ...
			'hop'	, opt.hop	, ...
			'n'		, opt.n		, ...
			'fwin'	, opt.fwin	  ...
			);
	