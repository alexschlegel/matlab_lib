function eeg = ParseEvent(eeg,varargin)
% EEG.ParseEvent
% 
% Description:	parse events from an EEG status channel
% 
% Syntax:	eeg = EEG.ParseEvent(eeg,<options>)
% 
% In:
% 	eeg	- an eeg struct read with EEG.Read an including eeg.status data
%	<options>:
%		type:	('number') one of the following to specify how events should be
%				processed:
%					number:	the status channel is treated as event codes
%					bit:	the status channel is treated as individually set
%							bits
%		bits:	(<all>) the bits to consider when processing events (1 is the
%				low bit)
% 
% Out:
% 	eeg	- the eeg struct with the status field replaced by an event field
%
% Updated: 2015-04-10
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%parse the inputs
	opt	= ParseArgs(varargin,...
			'type'	, 'number'	, ...
			'bits'	, []		  ...
			);
	
	opt.type	= CheckInput(opt.type,'type',{'number','bit'});

%error check
	assert(isfield(eeg,'status'),'eeg struct has no status data.');
	assert(size(eeg.status,1)==1,'eeg struct must have exactly one status channel.');
	
%detect the events
	s	= reshape(eeg.status,[],1);
	
	%eliminate the discarded bits
		if ~isempty(opt.bits)
			s	= bitkeep(s,opt.bits,'compress',true);
		end
	%initialize the event struct
		eeg.event	= dealstruct('type','start','duration',[]);
	
	switch opt.type
		case 'number'
			DetectEventsByNumber;
		case 'bit'
			DetectEventsByBit;
	end

%remove the status channel
	eeg	= rmfield(eeg,'status');

%------------------------------------------------------------------------------%
function DetectEventsByNumber()
	%get the event locations
		bChange	= diff([0; s])~=0;
		
		bEvent	= bChange & s~=0;
		
		kStart	= find(bEvent);
		kEnd	= [kStart(2:end); numel(s)+1];
	
	%event info
		eeg.event.type		= s(kStart);
		eeg.event.start		= kStart;
		eeg.event.duration	= kEnd - kStart;
end
%------------------------------------------------------------------------------%
function DetectEventsByBit()
	%get the active bits
		sU		= setdiff(unique(s),0);
		nU		= numel(sU);
		bitMax	= floor(max(log2(double(sU))));
		
		bitU	= int2bit(sU,bitMax);
		
		[kStatus,kBit]	= find(bitU);
		kBit			= unique(kBit);
		kType			= bitshift(1,kBit-1);
		nBit			= numel(kBit);
	
	%get the points when an event starts or ends
		bChange	= diff([0; s])~=0;
		
		kChange		= find(bChange);
		sChange		= s(kChange);
		bitChange	= int2bit(sChange);
	
	%determine when each event type started and ended
		for kB=1:nBit
			bDiff	= diff([0; bitChange(:,kBit(kB))]);
			kStart	= kChange(find(bDiff==1));
			kEnd	= kChange(find(bDiff==-1))-1;
			if numel(kStart)>numel(kEnd)
				kEnd	= [kEnd; numel(s)];
			end
			nEvent	= numel(kStart);
			
			eeg.event.type		= [eeg.event.type;		repmat(kType(kB),[nEvent 1])];
			eeg.event.start		= [eeg.event.start;		kStart];
			eeg.event.duration	= [eeg.event.duration; 	kEnd-kStart+1];
		end
	
	%reorder by start time
		[eeg.event.start,kOrder]	= sort(eeg.event.start);
		eeg.event.type				= eeg.event.type(kOrder);
		eeg.event.duration			= eeg.event.duration(kOrder);
end
%------------------------------------------------------------------------------%

end
