function sTrigger = TriggerPrepare(varargin)
% TriggerPrepare
% 
% Description:	prepare an ACCES I/O card for trigger output
% 
% Syntax:	sTrigger = TriggerPrepare(<options>)
% 
% In:
% 	<options>:
%		card:		(1) the number of the card to use (1-based)
%		bit:		(1:24) the indices of the I/O card bits to map to Trigger
%					channels. indices 1-24 refer to bits A0-A7, B0-B7, C0-C7, in
%					that order. e.g. if this option is set to 17:24, then the
%					trigger will be able to set one byte of information through
%					I/O channels C0-C7.
%		bitorder:	('lsb') 'lsb' or 'msb' to specify least or most significant
%					bit first
%		blankfirst:	(true) true to send a blank trigger before every trigger
%					value
%		fs:			(2048) the sampling rate of the trigger detection device, in
%					Hz (only matters when blankfirst==true)
%		code:		(struct) a struct of trigger codes to refer to later
%		debug:		(false) true to send status updates to the MATLAB command
%					window
% 
% Out:
% 	sTrigger	- a struct of info to pass to future Trigger function calls
% 
% Updated: 2010-07-13
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgsOpt(varargin,...
		'card'			, 1			, ...
		'bit'			, 1:24		, ...
		'bitorder'		, 'lsb'		, ...
		'blankfirst'	, true		, ...
		'fs'			, 2048		, ...
		'code'			, struct	, ...
		'debug'			, false		  ...
		);

opt.bit	= reshape(opt.bit,[],1);

%load the ACCES libraries
	CheckLibrary('ACCES32.dll','ACCES32.h');
	CheckLibrary('AIOWDM.dll','AIOWDM.h');

%debug?
	sTrigger.debug		= opt.debug;
%send a blank trigger first?
	sTrigger.blankfirst	= opt.blankfirst;
	sTrigger.fs			= opt.fs;
%reverse bit order?
	switch lower(opt.bitorder)
		case 'lsb'
			sTrigger.bitreverse	= false;
		case 'msb'
			sTrigger.bitreverse	= true;
		otherwise
			error(['"' opt.bitorder '" is an unrecognized bit order.']);
	end
%trigger codes
	strigger.code	= opt.code;
%number of trigger bits
	sTrigger.nbit	= numel(opt.bit);
%map the bits to port/bit combos (1:8->A, 9:16->B, 17:24->C)
	sTrigger.port	= fix((opt.bit-1)/8)+1;
	sTrigger.bit	= opt.bit - (sTrigger.port-1)*8;
	
	sTrigger.uport	= unique(sTrigger.port);
	sTrigger.nport	= numel(sTrigger.uport);
%initialize the struct for keeping track of events
	sTrigger.event	= struct('type',[],'start',[],'duration',[]);
%struct members to store state info
	%output/input mode of each port
		sTrigger.mode	= ~ismember([1;2;3],sTrigger.uport);
%get the card info
	ptr_idDevice		= libpointer('ulongPtr',0);
	ptr_baseAddress		= libpointer('ulongPtr',0);
	ptr_nDeviceName		= libpointer('ulongPtr',0);
	ptr_strDeviceName	= libpointer('uint8Ptr',zeros(1,255));
	
	%two calls seem to be necessary to get the device name
		[dummy,sTrigger.deviceID,sTrigger.baseAddress,nDeviceName,strDeviceName]	= calllib('AIOWDM','QueryCardInfo',opt.card-1,ptr_idDevice,ptr_baseAddress,ptr_nDeviceName,ptr_strDeviceName);
		[dummy,sTrigger.deviceID,sTrigger.baseAddress,nDeviceName,strDeviceName]	= calllib('AIOWDM','QueryCardInfo',opt.card-1,ptr_idDevice,ptr_baseAddress,ptr_nDeviceName,ptr_strDeviceName);
	
	sTrigger.deviceName	= char(strDeviceName(1:nDeviceName));
%set the card up for output to the specified ports and input from the others
	%construct the control byte (MSB first)
		%						[port C lo			port B				mode select	port C hi			port A				mode select	mode select	mode set flag	] 
		bytControl	= bit2int(	[sTrigger.mode(3)	sTrigger.mode(2)	0			sTrigger.mode(3)	sTrigger.mode(1)	0			0			1				]);
	%set the control byte
		calllib('ACCES32','OutPortB',sTrigger.baseAddress+3,bytControl);
%set all output port bits to 0
	sTrigger	= TriggerSet(sTrigger,0);

%------------------------------------------------------------------------------%
function CheckLibrary(strLib,strH)
% check to make sure a library is loaded, fail if it can't be loaded
	if ~libisloaded(PathGetFilePre(strLib))
		try
			loadlibrary(strLib,strH);
		catch
			error(['Library "' strLib '" could not be loaded.']); 
		end
	end
%------------------------------------------------------------------------------%
