function eeg = EEGChangeFromBaseline(eeg,varargin)
% EEGChangeFromBaseline
% 
% Description:	calculate the change from baseline for a set of EEG windows
% 
% Syntax:	eeg = EEGChangeFromBaseline(eeg,<options>)
% 
% In:
% 	eeg	- an eeg loaded as a group of windows (i.e. use twinbase, twinstart, and
%		  twinend as options to EEGRead
%	<options>:
%		type:		('diff') one of the following:
%						'percent':	percent change from baseline mean
%						'diff':		difference from baseline mean
%						'detrend':	detrend each signal based on a best-fit line
%									through the baseline
%		t:			(0->end based on sample rate) the time corresponding to each
%					point in the data
%		start:		(0) the time at which to begin baseline calculation 
%		end:		(0) the time at which to end baseline calculation
% 
% Out:
% 	eeg	- the eeg struct with eeg data transformed to represent change from the
%		  specified baseline
% 
% Updated: 2011-04-19
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgs(varargin,...
		'type'	, 'diff'	, ...
		't'		, []		, ...
		'start'	, 0			, ...
		'end'	, 0			  ...
		);

%data size info
	[nChannel,nWindow,nSample]	= size(eeg.data);
	if nChannel==0
		return;
	end
%sampling rate
	fs	= eeg.hdr.channel.data(1).rate;
%fill in t if blank
	if isempty(opt.t)
		opt.t	= k2t(1:nSample,fs);
	end
%reshape the data to nSignal x nSample
	eeg.data	= reshape(eeg.data,nChannel*nWindow,nSample);
%calculate change from baseline
	eeg.data	= ChangeFromBaseline(eeg.data,'type',opt.type,'t',opt.t,'start',opt.start,'end',opt.end,'rate',fs);
%reshape back
	eeg.data	= reshape(eeg.data,nChannel,nWindow,nSample);
