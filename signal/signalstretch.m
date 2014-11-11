function xs = signalstretch(x,rate,dur,varargin)
% signalstretch
% 
% Description:	stretch (or compress) a signal without changing its frequency
%				content
% 
% Syntax:	xs = signalstretch(x,rate,dur,<options>)
% 
% In:
% 	x		- an N x 1 signal
%	rate	- the sampling rate of the signal, in Hz
%	dur		- the stretched duration of the signal, in seconds
%	<options>:
%		win:	(<auto>) the window duration of the STFT, in seconds
%		hop:	(<auto>) the hop duration of the STFT, in seconds
% 
% Out:
% 	xs	- the stretched/compressed signal
% 
% Updated: 2012-09-30
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
nSample	= numel(x);
durIn	= nSample/rate;

opt	= ParseArgs(varargin,...
		'win'	, min(0.25,durIn/2)	, ...
		'hop'	, []				  ...
		);

opt.hop	= unless(opt.hop,min(opt.win/3,opt.win*durIn/dur/2));
hopOut	= opt.hop*dur/durIn;

xs	= iSTFT(STFT(x,rate,'win',opt.win,'hop',opt.hop),rate,'win',opt.win,'hop',hopOut);

nOut	= round(dur*rate);
nCur	= numel(xs);
kStart	= max(floor((nCur-nOut)/2),1);
xs		= xs(min(kStart + (0:nOut-1),nCur));
