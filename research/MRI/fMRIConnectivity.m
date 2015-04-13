function [z,kPair] = MRIConnectivity(nii,varargin)
% fMRIConnectivity
% 
% Description:	calculate the functional connectivity between masks
% 
% Syntax:	z = fMRIConnectivity(nii,msk1,msk2,<options>) OR
%			[z,kPair] = fMRIConnectivity(nii,cMask,<options>) OR
% 
% In:
% 	nii		- the path to a functional NIfTI file, a functional NIfTI struct
%			  loaded with NIfTI.Read, or a 4d array
%	msk1	- the path to a NIfTI mask file, a NIfTI mask struct loaded with
%			  NIfTI.Read, or a 3d logical array representing the first mask
%	msk2	- the path to a NIfTI mask file, a NIfTI mask struct loaded with
%			  NIfTI.Read, or a 3d logical array representing the second mask
%	cMask	- a cell of masks as described above, in which case the connectivity
%			  is calculated between each pair
%	<options>:
%		event:	(<entire timecourse>) an nEvent x 2 array specifying events
%				during which to calculate the connectivity.  the first column
%				represents the event onset times (1 is the first time point) and
%				the second column represents the durations, in samples.  the
%				connectivity is calculated from all events appended together. if
%				connectivity for multiple event types should be calculated, then
%				this should be an nEvent x 3 array, where the first column is a
%				number specifying the type of each event.  these numbers will
%				correspond to the columns in the output connectivities.
% 
% Out:
% 	z		- an nMaskPair x nEventType array of Fisher-transformed correlations
%			  between the event-related timecourses taken from the masks.  
%	kPair	- an nMaskPair x 2 array of the indices of the masks associated with
%			  each connectivity row
% 
% Updated: 2015-04-13
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%parse the input
	[msk1,msk2,opt]	= ParseArgs(varargin,[],[],...
						'event'	, []	  ...
						);
	
	if isempty(msk2) && ~isempty(msk1)
		cMask	= msk1;
	else
		cMask	= {msk1; msk2};
	end
	
	nMask	= numel(cMask);
	
	clear msk1 msk2;

%get the data and masks
	nii		= GetData(nii);
	cMask	= cellfun(@(m) logical(GetData(m)),cMask,'UniformOutput',false);
%get the mean timecourses
	dMask	= cellfun(@(m) NIfTI.MaskMean(nii,m),cMask,'UniformOutput',false);
%parse the events
	if isempty(opt.event)
		opt.event	= [1 size(nii,4)];
	end
	
	nEvent	= size(opt.event,1);
	
	if size(opt.event,2)==2
		opt.event	= [ones(nEvent,1) opt.event];
	end
	
	evtType		= opt.event(:,1);
	evtOnset	= opt.event(:,2);
	evtDuration	= opt.event(:,3);
	kTEvent		= arrayfun(@(o,d) o+(0:d-1)',evtOnset,evtDuration,'UniformOutput',false);
	
	nEventType	= max(evtType);
%calculate the correlations between each mask
	kPair	= handshakes(1:nMask);
	nPair	= size(kPair,1);
	
	z	= NaN(nPair,nEventType);
	
	for kP=1:nPair
		for kE=1:nEventType
			%get the portion of the timecourse we are interested in
				kTEventCur	= kTEvent(evtType==kE);
				kTEventCur	= cat(1,kTEventCur{:});
				
				if isempty(kTEventCur)
					continue;
				end
				
				m1	= dMask{kPair(kP,1)}(kTEventCur);
				m2	= dMask{kPair(kP,2)}(kTEventCur);
				
				if isempty(m1) || isempty(m2)
				%empty mask
					z(kP,kE)	= NaN;
				else
				%calculate the correlation between the two
					r			= corrcoef2(m1,m2');
					z(kP,kE)	= fisherz(r);
				end
		end
	end

%------------------------------------------------------------------------------%
function nii = GetData(nii)
	switch class(nii)
		case 'char'
			nii	= NIfTI.Read(nii,'return','data');
		case 'struct'
			nii	= nii.data;
		otherwise
	end
end
%------------------------------------------------------------------------------%

end
