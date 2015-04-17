function x = RemoveDrift(x,varargin)
% RemoveDrift
% 
% Description:	remove drift from a signal using a moving average
% 
% Syntax:	x = RemoveDrift(x,<options>)
% 
% In:
% 	x	- a signal or nSignal x nSample array of signals
%	<options>:
%		win:		(<1/10 of signal>) the size of the features to remove, in
%					units of 1/rate
%		rate:		(1) the number of samples per unit of the specified window
%					size (i.e. the sampling rate)
%		sequential:	(false) true to process each signal sequentially (saves
%					memory)
%		silent:		(false) true to suppress status/progress updates (only
%					applies if sequential==true
% 
% Out:
% 	x	- the signal with drift removed
% 
% Updated: 2015-04-08
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'win'			, []	, ...
		'rate'			, 1		, ...
		'sequential'	, false	, ...
		'silent'		, false	  ...
		);
%reshape the data
	bColumn	= size(x,2)==1;
	if bColumn
		x	= reshape(x,1,[]);
	end
%size of the data
	[nSignal,nSample]	= size(x);

if opt.sequential
	progress('action','init','total',nSignal,'label','Removing Drift','silent',opt.silent);
	for kS=1:nSignal
		x(kS,:)	= RemoveDrift(x(kS,:),'win',opt.win,'rate',opt.rate);
		
		progress;
	end
else
	%get the filter window size
		if isempty(opt.win)
			opt.win	= nSample/10;
		end
		opt.win	= max(1,round(opt.win*opt.rate));
	%pad the data to be a multiple of opt.win
		nWin		= ceil(nSample/opt.win);
		nWin2		= nWin*2;
		nSamplePad	= opt.win*nWin;
		
		x	= [x repmat(x(:,end),1,nSamplePad-nSample)];
	%get windows of length opt.win that overlap by half
		%start of each window
			kWinStart	= reshape(round(GetInterval(1,nSamplePad-opt.win,nWin2)),nWin2,1);
		%center of each window
			kWinCenter	= reshape(kWinStart + opt.win/2,nWin2,1);
		%relative in-window indices
			kWinRel	= reshape(0:opt.win-1,1,1,opt.win);
		%signal indices
			kSignal	= reshape(1:nSignal,1,nSignal);
	%get the mean of each window
		xM	= x(sub2ind([nSignal nSamplePad],repmat(kSignal,[nWin2 1 opt.win]),repmat(kWinRel,[nWin2 nSignal 1])+repmat(kWinStart,[1 nSignal opt.win])));
		xM	= mean(xM,3);
	%interpolate to the size of x
		xI	= interp1nd(kWinCenter,xM,reshape(1:nSamplePad,nSamplePad,1),'pchip')';
	%subtract from x
		x	= x - xI;
	%unpad
		x	= x(:,1:nSample);
end

%unreshape
	if bColumn
		x	= reshape(x,[],1);
	end
