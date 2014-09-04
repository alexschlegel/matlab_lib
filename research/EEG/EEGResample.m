function [eeg,t] = EEGResample(eeg,fs,varargin)
% EEGResample
% 
% Description:	resample the data in an EEG struct.  eeg must have data
%				organized as nSignal x ... x nSample signals
% 
% Syntax:	eeg = EEGResample(eeg,fs,[t])
% 
% In:
% 	eeg	- an EEG struct
%	fs	- the new sampling rate, in Hz
%	t	- the EEG's time vector
% 
% Out:
% 	eeg	- eeg resampled at the specified rate
%	t	- the resampled time vector
% 
% Updated: 2010-09-21
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
t	= ParseArgs(varargin,[]);

%original sampling rate
	nData	= numel(eeg.hdr.channel.data);
	nStatus	= numel(eeg.hdr.channel.status);
	if nData>0
		s							= size(eeg.data);
		fsOrig						= eeg.hdr.channel.data(1).rate;
		[eeg.hdr.channel.data.rate]	= deal(fs);
	elseif nStatus>0
		s								= size(eeg.status);
		fsOrig							= eeg.hdr.channel.status(1).rate;
		[eeg.hdr.channel.status.rate]	= deal(fs);
	else
		return;
	end
	
	nSampleOrig	= s(end);

%resample the data
	if nData>0
		eeg.data	= EEGR_resample(eeg.data);
	end
	if nStatus>0
		eeg.status	= EEGR_resample(eeg.status);
	end
	if isfield(eeg,'event')
		eeg.event.start		= min(nSample,max(1,round(eeg.event.start*fs/fsOrig)));
		eeg.event.duration	= max(1,round(eeg.event.duration*fs/fsOrig));
	end
	if ~isempty(t)
		t	= EEGR_resample(t);
	end
	
	eeg.hdr.nsample	= nSample;

%------------------------------------------------------------------------------%
function d = EEGR_resample(d)
% resample a data set
	strClass	= class(d);
	bReshape	= size(d)==s;
	
	%reshape to nSignal x nSample
		if bReshape
			d	= reshape(d,[],nSampleOrig);
		end
	%resample
		d	= cast(resample(double(d)',fs,fsOrig)',strClass);
	%lowpass filter at half the new sampling frequency
		d	= LowpassFilter(d,fs,fs/2,'silent',true);
	%un-reshape
		if bReshape
			nSample	= size(d,2);
			d		= reshape(d,[s(1:end-1) nSample]);
		end
end
%------------------------------------------------------------------------------%

end