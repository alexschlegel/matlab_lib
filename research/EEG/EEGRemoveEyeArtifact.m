function [eeg,bDelete] = EEGRemoveEyeArtifact(eeg,varargin)
% EEGRemoveEyeArtifact
% 
% Description:	remove eye artifacts from EEG data using Joyce et al.'s 2004
%				Psychophysiology method or Haggard & Eimer's 1999 method
% 
% Syntax:	[eeg,bDelete] = EEGRemoveEyeArtifact(eeg,<options>)
% 
% In:
% 	eeg	- an eeg struct of windows loaded by EEGRead and processed with
%		  EEGChangeFromBaseline
%	<options>:
%		method:			('sobi') one of the following strings:
%							'sobi'			- use the Joyce SOBI method
%							'threshold'		- the the Haggard threshold method
%							'sobi_combo'	- find eye artifacts using the
%											  threshold method, try to remove
%											  them using SOBI, and then delete
%											  windows with too much residual eye
%											  blink
%		threshold_chan:	(<auto>) the channels to use for threshold checking
%		threshold:		(80) delete windows that deviate +/- this threshold from
%						baseline
%		n_source:		(<# channels>) number of sources to model for SOBI
%						method
%		n_correlation:	(min(100,nSample/3)) number of correlation matrices to
%						be diagonalized in the SOBI method
%		thresh_corr:	(0.3) the correlation threshold for the SOBI method step
%						3
%		thresh_std:		(0.2) the standard deviation threshold for the SOBI
%						method step 4
%		remove:			(true) true to remove the channels marked for deletion
%						because of eye artifact.  false to just report them in
%						bDelete
%		input:			('head') an EEGChannel specifier of the channels to use
%						during the artifact calculation, other than the required
%						eye channels
%		output:			('all') an EEGChannel specifier of the channels to
%						return
%		session_date:	(<from hdr>) the session date as milliseconds from the
%						epoch, for determining the scheme to use
%		silent:			(false) true to suppress status messages
% 
% Out:
% 	eeg			- the eeg struct with desired data channels and eye artifact
%				  removed using the specified method
%	bDelete		- a logical array specifying windows from the input eeg struct
%				  that were removed because of eye artifact
% 
% Notes:	Joyce et al., 2004:
%				reconstruct source signals using SOBI, remove signals coming
%				from the eye channels.  windows with any NaN or Inf values are
%				ignored
%			Haggard & Eimer, 1999:
%				remove windows in which the Fz/Pz channels deviate greater than
%				80uV from baseline
% 
% Updated: 2015-04-08
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
[nChannel,nWindow,nSample]	= size(eeg.data);
bDelete						= false(nWindow,1);

if nChannel==0
	return;
end

opt	= ParseArgs(varargin,...
		'method'			, 'sobi'				, ...
		'threshold_chan'	, []					, ...
		'threshold'			, 80					, ...
		'n_source'			, []					, ...
		'n_correlation'		, min(100,nSample/3)	, ...
		'thresh_corr'		, 0.3					, ...
		'thresh_std'		, 0.2					, ...
		'remove'			, true					, ...
		'input'				, 'head'				, ...
		'output'			, 'all'					, ...
		'session_date'		, []					, ...
		'silent'			, false					  ...
		);

%get the channels to use in the calculation
	[sChannelInput,sKFileInput,sKHeaderInput]	= EEGChannel(opt.input,eeg.hdr,'readstatus',false,'session_date',opt.session_date);
	opt.input									= reshape(sKHeaderInput.read,[],1);
%remove the artifact
	switch opt.method
		case 'sobi'
			RemoveArtifact_SOBI;
		case 'threshold'
			RemoveArtifact_Threshold;
		case 'sobi_combo'
			RemoveArtifact_SOBICombo;
		otherwise
			error(['"' tostring(opt.method) '" is an unrecognized removal method.']);
	end
%delete non-return channels
	switch opt.output
		case 'all'
			opt.output	= 1:numel(eeg.hdr.channel.data);
		otherwise
			[sChannelOutput,sKFileOutput,sKHeaderOutput]	= EEGChannel(opt.output,eeg.hdr,'readstatus',false,'session_date',opt.session_date);
			opt.output										= reshape(setdiff(sKHeaderOutput.read,0),1,[]);
	end
	
	%crop
		eeg.data				= eeg.data(opt.output,:,:);
		eeg.hdr.channel.data	= eeg.hdr.channel.data(opt.output);
%delete windows marked for removal
	if opt.remove
		eeg.data(:,bDelete,:)	= [];
	end

%------------------------------------------------------------------------------%
function RemoveArtifact_SOBI()
% remove eye artifacts using the Joyce et al. SOBI method
	%get the eye movement channels
		[sChannel,kFile,kHeader]	= EEGChannel('eog',eeg.hdr,'session_date',opt.session_date);
		kChannelEOG					= reshape(kHeader.eog,[],1);
		kChannelEOGCorrelate		= reshape(kHeader.eog_correlate,[],1);
		
		if any(kChannelEOG==0) || any(kChannelEOGCorrelate==0)
			error('The required channels for SOBI-based eye artifact detection are not present.');
		end
	%get the channels on which to perform SOBI
		opt.input	= unique([opt.input; kChannelEOG]);
		nInput		= numel(opt.input);
		
		if isempty(opt.n_source)
			opt.n_source	= nInput;
		end
		
		[bInputCorrelate,kInputCorrelate]	= ismember(kChannelEOGCorrelate,opt.input);
	%remove eye artifact from each window
		progress('action','init','total',nWindow,'label','Removing eye artifact from windows using SOBI','status',true,'status_offset',-1,'silent',opt.silent);
		
		for kW=1:nWindow
			%decompose data into source components using SOBI
				d				= squeeze(eeg.data(opt.input,kW,:));
				if any(isnan(d(:))) || any(isinf(d(:)))
					progress;
					continue;
				end
				
				dCell			= mat2cell(d,ones(nInput,1),nSample);
				
				[wInv,dSource]	= sobi(d,opt.n_source,opt.n_correlation);
				dSourceCell		= mat2cell(dSource,ones(opt.n_source,1),nSample);
			%reverse EOG channel signs and perform sobi again
				dReverse					= d;
				dReverse(kInputCorrelate,:)	= -dReverse(kInputCorrelate,:);
				
				[wInvReverse,dSourceReverse]	= sobi(dReverse,opt.n_source,opt.n_correlation);
				dSourceReverseCell				= mat2cell(dSourceReverse,ones(opt.n_source,1),nSample);
			%flag source components that have reversed
				bReversed	= cellfun(@(x,y) EqualEnough(x,-y,'method',{'corr','normmean'}),dSourceCell,dSourceReverseCell);
			%flag source components that correlate with the EOG correlation
			%channels
				dCorrelate	= dCell(kInputCorrelate);
				
				bCorrelated				= false(opt.n_source,1);
				bCorrelated(~bReversed)	= cellfun(@(x) any(cellfun(@(y) EqualEnough(x,y,'method','abscorr','tol',opt.thresh_corr),dCorrelate)),dSourceCell(~bReversed));
			%flag components with high low-frequency power
				bLowPower				= false(opt.n_source,1);
				
				%calculate the derivative of the sources of interest
					dSOIPrime	= diff(dSource(bCorrelated,:),1,2);
				%calculate the standard deviation of each derivative
					sdSOIPrime	= std(dSOIPrime,0,2);
				
				bLowPower(bCorrelated)	= sdSOIPrime<=opt.thresh_std;
			%remove reversed and correlated+high low-frequency power sources
				bRemove	= bReversed | (bCorrelated & bLowPower);
				
				dSource(bRemove,:)	= 0;
			%reconstruct the artifact-free data
				eeg.data(opt.input,kW,:)	= wInv*dSource;
			
			progress;
		end
end
%------------------------------------------------------------------------------%
function RemoveArtifact_Threshold()
% remove eye artifacts using the Haggard/Eimer threshold method
	%get the eye movement channels
		if isempty(opt.threshold_chan)
			[sChannel,kFile,kHeader]	= EEGChannel('eyemovement',eeg.hdr,'session_date',opt.session_date);
			kChannelEyeMovement			= kHeader.eyemovement;
			
			if any(kChannelEyeMovement==0)
				error('The required channels for threshold-based eye artifact detection are not present.');
			end
		else
			kChannelEyeMovement	= find(ismember([eeg.hdr.channel.data.k],opt.threshold_chan));
		end
	
	strAction	= conditional(opt.remove,'Removing','Flagging');
	status([strAction ' windows with eye artifact using thresholding'],'noffset',-1,'silent',opt.silent);
	
	%find supra-threshold signal in the eye movement channels
		dEye	= reshape(permute(eeg.data(kChannelEyeMovement,:,:),[2 3 1]),nWindow,[]);
		bDelete	= any(abs(dEye)>opt.threshold,2);
end
%------------------------------------------------------------------------------%
function RemoveArtifact_SOBICombo()
% find windows with eye blinks using the threshold method, remove eye artifacts
% using the SOBI method, and then delete window with too much residual eye blink
	error('sobi_combo is not implemented.');
	
	%flag channels with eye blinks
		bRemoveOrig	= opt.remove;
		opt.remove	= false;
		RemoveArtifact_Threshold;
		opt.remove	= bRemoveOrig;
	%find the peaks
	%remove artifact using SOBI
	%are the peaks still there?
end
%------------------------------------------------------------------------------%

end
