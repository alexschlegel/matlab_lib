function [eeg,kStart,kEnd] = EEGCrop(eeg,varargin);
% EEGCrop
% 
% Description:	crop the data stored in an EEG file
% 
% Syntax:	[eeg,kStart,kEnd] = EEGCrop(eeg,[kStart]=1,[kEnd]=<end>,<options>)
% 
% In:
% 	eeg			- an eeg struct loaded with EEGRead
%	[kStart]	- the first sample to keep
%	[kEnd]		- the last sample to keep
%	<options>:
%		eventstart:	(<none>) if specified, overrides kStart as the first data
%					sample at which the specified event occurs
%		eventend:	(<none>) if specified, overrides kEnd as the last data
%					sample at which the specified event occurs
% 
% Out:
% 	eeg		- the cropped EEG file, with event times relative to the first
%			  cropped sample
%	kStart	- the first cropped index from the original EEG data
%	kEnd	- the last cropped index from the original EEG data
% 
% Updated: 2010-09-07
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
[kStart,kEnd,opt]	= ParseArgs(varargin,1,[],...
						'eventstart'	, []	, ...
						'eventend'		, []	  ...
						);
if isempty(kEnd)
	if isfield(eeg,'data')
		nSampleData	= size(eeg.data,2);
	else
		nSampleData	= 0;
	end
	if isfield(eeg,'status')
		nSampleStatus	= size(eeg.status,2);
	else
		nSampleStatus	= 0;
	end
	kEnd	= max(nSampleStatus,nSampleData);
end
if ~isempty(opt.eventstart)
	kStart	= eeg.event.start(find(eeg.event.type==opt.eventstart,1,'first'));
end
if ~isempty(opt.eventend)
	kEnd	= eeg.event.start(find(eeg.event.type==opt.eventend,1,'last'));
end

%crop the data and status arrrays
	eeg.hdr.nsample	= kEnd-kStart+1;
	if isfield(eeg,'data')
		eeg.data		= eeg.data(:,kStart:kEnd);
	end
	if isfield(eeg,'status')
		eeg.status		= eeg.status(:,kStart:kEnd);
	end
%get rid of events outside the cropped period
	if isfield(eeg,'event');
		bIn	= eeg.event.start>=kStart & eeg.event.start<=kEnd;
		
		eeg.event	= structfun(@(x) x(bIn),eeg.event,'UniformOutput',false);
		%fix the event times
			eeg.event.start	= eeg.event.start - kStart + 1;
	end
