function [eeg,bDelete] = EEGThreshold(eeg,varargin)
% EEGThreshold
% 
% Description:	remove windows from EEG data with supra-threshold data points
% 
% Syntax:	[eeg,bDelete] = EEGThreshold(eeg,<options>)
% 
% In:
% 	eeg	- an eeg struct of windows loaded by EEGRead and processed with
%		  EEGChangeFromBaseline
%	<options>:
%		threshold:		(100) any windows with values beyond +/- threshold will
%						be removed
%		channel:		(<all>) the channels to consider
%		remove:			(true) true to remove the channels marked for deletion.
%						false to just report them in bDelete
%		silent:			(false) true to suppress status messages
% 
% Out:
% 	eeg			- the eeg struct with supra-threshold windows removed
%	bDelete		- a logical array specifying windows from the input eeg struct
%				  that were removed
% 
% Updated: 2010-11-08
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
[nChannel,nWindow,nSample]	= size(eeg.data);

opt	= ParseArgs(varargin,...
		'threshold'	, 100	, ...
		'channel'	, []	, ...
		'remove'	, true	, ...
		'silent'	, false	  ...
		);
if isempty(opt.channel)
	opt.channel	= 'data';
end

strAction	= conditional(opt.remove,'Removing','Flagging');
status([strAction ' above-threshold windows'],'noffset',-1,'silent',opt.silent);

%get the channels to check
	[sChannel,sKFile,sKHeader]	= EEGChannel(opt.channel,eeg.hdr,'readstatus',false);
	kChannelThreshold			= sKHeader.read;
	
	if any(kChannelThreshold==0)
		error('The required channels for thresholding are not present.');
	end
%check
	dThresh	= reshape(permute(eeg.data(kChannelThreshold,:,:),[2 3 1]),nWindow,[]);
	bDelete	= any(abs(dThresh)>opt.threshold,2);
%delete windows marked for removal
	if opt.remove
		eeg.data(:,bDelete,:)	= [];
	end
