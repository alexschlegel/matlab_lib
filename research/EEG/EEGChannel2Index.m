function [kFile,cChannel,kHeader] = EEGChannel2Index(varargin)
% EEGChannel2Index
% 
% Description:	return the array index of the given EEG channels
% 
% Syntax:	[kFile,cChannel,kHeader] = EEGChannel2Index([cChannel]='all',[hdr]=<default>)
% 
% In:
% 	[cChannel]	- an EEG channel, cell of channels, or struct of cells of
%				  channels.  can be 'A1' through 'A32', 'Status' for the status
%				  channel, a head label (see notes below), an index, or one of
%				  the following:
%					'all':			indices for all labels
%					'head':			indices for all head labels
%					'headother':	indices for non-standard head labels
%					'data':			indices for all data channels
%					'status':		indices for all status channels
%	[hdr]		- an EEG header struct to reference
% 
% Out:
% 	kFile		- an array of indices of the specified channels in the
%				  referenced EEG file 
%	cChannel	- a cell of the channels corresponding to k
%	kHeader		- an array of indices of the specified channels in the
%				  referenced header
% 
% Notes:	head label to channel label mapping:
%	Fp1>A1		AF3>A2		F7>A3		F3>A4
%	FC1/FC3>A5	FC5/FT7>A6	T7>A7		C3>A8
%	CP1>A9		CP5>A10		P7>A11		P3>A12
%	Pz>A13		PO3>A14		O1>A15		Oz>A16
%	O2>A17		PO4>A18		P4>A19		P8>A20
%	CP6>A21		CP2>A22		C4>A23		T8>A24
%	FC6>A25		FC2>A26		F4>A27		F8>A28
%	AF4>A29		Fp2>A30		Fz>A31		Cz>A32
% 
% Updated: 2011-11-04
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
persistent sLabel;

[cChannel,hdr]	= ParseArgs(varargin,'all',[]);

if isstruct(cChannel)
	[kFile,cChannel,kHeader]	= structfun(@(x) EEGChannel2Index(x,hdr),cChannel,'UniformOutput',false);
	return;
end

cChannel		= ForceCell(cChannel);
nChannel		= numel(cChannel);

%default labels
	if isempty(sLabel)
		sLabel.head			= {'Fp1','AF3','F7','F3','FC1','FC5','T7','C3','CP1','CP5','P7' ,'P3' ,'Pz' ,'PO3','O1' ,'Oz' ,'O2' ,'PO4','P4' ,'P8' ,'CP6','CP2' ,'C4','T8' ,'FC6','FC2','F4' ,'F8' ,'AF4','Fp2','Fz' ,'Cz'};
		sLabel.h2channel	= {'A1' ,'A2' ,'A3','A4','A5' ,'A6' ,'A7','A8','A9' ,'A10','A11','A12','A13','A14','A15','A16','A17','A18','A19','A20','A21','A22','A23','A24','A25','A26','A27','A28','A29','A30','A31','A32'};
		
		sLabel.headother	= {'FC3','FT7'};
		sLabel.ho2channel	= {'A5','A6'};
		
		sLabel.channel		= {'A1','A2','A3','A4','A5','A6','A7','A8','A9','A10','A11','A12','A13','A14','A15','A16','A17','A18','A19','A20','A21','A22','A23','A24','A25','A26','A27','A28','A29','A30','A31','A32'};
		sLabel.exg			= {'EXG1','EXG2','EXG3','EXG4','EXG5','EXG6','EXG7','EXG8'};
		sLabel.sensor		= {'GSR1','GSR2','Erg1','Erg2','Resp','Plet','Temp'};
		sLabel.status		= {'Status'};
		
		sLabel.khead		= 1:32;
		sLabel.kheadother	= 5:6;
		sLabel.kchannel		= 1:32;
		sLabel.kexg			= 33:40;
		sLabel.ksensor		= 41:47;
		sLabel.kstatus		= 48;
		
		sLabel.nhead		= numel(sLabel.head);
		sLabel.nheadother	= numel(sLabel.headother);
		sLabel.nchannel		= numel(sLabel.channel);
		sLabel.nexg			= numel(sLabel.exg);
		sLabel.nsensor		= numel(sLabel.sensor);
		sLabel.nstatus		= numel(sLabel.status);
		sLabel.ndata		= sLabel.nhead+sLabel.nchannel+sLabel.nexg+sLabel.nsensor;
		sLabel.n			= sLabel.nstatus+sLabel.ndata;
	end
%labels to use for the current call
	if isempty(hdr)
		kData	= [sLabel.khead sLabel.kchannel sLabel.kexg sLabel.ksensor];
		hdrData	= [sLabel.head  sLabel.channel  sLabel.exg  sLabel.sensor];
		
		kStatus		= sLabel.kstatus;
		hdrStatus	= sLabel.status;
	else
		kData	= [hdr.channel.data.k];
		hdrData	= {hdr.channel.data.label};
		
		kStatus		= [hdr.channel.status.k];
		hdrStatus	= {hdr.channel.status.label};
	end
	kLabel		= [kData kStatus];
	kInHeader	= [1:numel(hdrData) 1:numel(hdrStatus)];
	hdrLabel	= [hdrData hdrStatus];
	
	nData	= numel(kData);
	nStatus	= numel(kStatus);
	
%expand strings in cChannel
	kC	= 1;
	while kC<=nChannel
		if isnumeric(cChannel{kC})
			cCur		= num2cell(cChannel{kC});
			nCur		= numel(cCur);
			
			cChannel	= [cChannel(1:kC-1) cCur cChannel(kC+1:end)];
			kC			= kC+nCur-1;
			nChannel	= nChannel+nCur-1;
		else
			switch cChannel{kC}
				case 'all'
					cChannel	= [cChannel(1:kC-1) hdrData hdrStatus cChannel(kC+1:end)];
					kC			= kC+nData+nStatus-1;
					nChannel	= nChannel+nData+nStatus-1;
				case 'head'
					cChannel	= [cChannel(1:kC-1) sLabel.head cChannel(kC+1:end)];
					kC			= kC+sLabel.nhead-1;
					nChannel	= nChannel+sLabel.nhead-1;
				case 'headother'
					cChannel	= [cChannel(1:kC-1) sLabel.headother cChannel(kC+1:end)];
					kC			= kC+sLabel.nheadother-1;
					nChannel	= nChannel+sLabel.nheadother-1;
				case 'data'
					cChannel	= [cChannel(1:kC-1) hdrData cChannel(kC+1:end)];
					kC			= kC+nData-1;
					nChannel	= nChannel+nData-1;
				case 'status'
					cChannel	= [cChannel(1:kC-1) hdrStatus cChannel(kC+1:end)];
					kC			= kC+nStatus-1;
					nChannel	= nChannel+nStatus-1;
				case [sLabel.head sLabel.headother sLabel.channel sLabel.exg sLabel.sensor sLabel.status]
				otherwise
					error(['"' cChannel{kC} '" is an unrecognized channel.']);
			end
		end
		
		kC	= kC+1;
	end
%find the index of each channel
	[kFile,kHeader]	= deal(zeros(size(cChannel)));
	
	%map from string to index
		bMap	= cellfun(@ischar,cChannel);
		kMap	= find(bMap);
		cMap	= cChannel(kMap);
		
		%make sure channel aren't already in hdrLabel
			bNeedToMap	= ~ismember(cMap,hdrLabel);
		
		%change head labels to channel labels
			[bHead,kHead]	= ismember(cMap,sLabel.head);
			
			cMap(bHead & bNeedToMap)	= sLabel.h2channel(kHead(bHead & bNeedToMap));
			
			[bHeadOther,kHeadOther]		= ismember(cMap,sLabel.headother);
			cMap(bHeadOther & bNeedToMap)	= sLabel.ho2channel(kHeadOther(bHeadOther & bNeedToMap));
		%now assign indices
			[bMember,kMember]	= ismember(cMap,hdrLabel);
			kMap				= kMap(bMember);
			kMember				= kMember(bMember);
			
			kHeader(kMap)	= kInHeader(kMember);
			kFile(kMap)		= kLabel(kMember);
	%already an index, make sure it exists
		kIndex			= cell2mat(cChannel(~bMap));
		[bGood,kGood]	= ismember(kIndex,kLabel);
		kIndex(~bGood)	= 0;
		kFile(~bMap)	= kIndex;
		kHeader(~bMap)	= kGood;
	