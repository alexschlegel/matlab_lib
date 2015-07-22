classdef Communicator < handle
% Communicator
% 
% Description:	communicate between two instances of MATLAB using tcp/ip
% 
% Syntax:	com = Communicator(port,msgType,[remote_ip]=<none>,<options>)
% 
% 			methods:
%				Connect:		connect to the other party
%				CheckMessages:	check for messages from the other party
%				Send:			send a message to the other party
%				Reply:			reply to a message sent by the other party
%				SetFlag:		set the value of the flag property
% 
% 			properties:
%				connected:	true if the two parties are connected
% 				handler:	the message handler function
%				msgType:	a cell of valid message types
%				remote:		a struct of info about the remote partner
%				timeout:	the number of seconds to wait before timing out
%				flag:		a flag that can be used for any purpose (e.g. for
%							forgetful workers in a parfor loop)
% 
% In:
%	port		- the port on which to communicate with the other party
%	msgType		- a cell of strings of message types that might be sent
%	[remote_ip]	- the ip address of the other party. only one Communiator should
%				  specify this.
% 	<options>:
%		handler:	(<none>) a function that gets called when a new message is
%					available. this object and the message struct will be passed
%					as inputs. the function must Reply to the message.
%		timeout:	(10) the number of seconds to wait for something to happen
%					before timing out
%		debug:		('error') the level of debug messages (can be 'error',
%					'warn', 'info', 'most', or 'all')
%		silent:		(false) true to suppress all status messages
% 
% Updated: 2015-06-09
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

	%PUBLIC PROPERTIES---------------------------------------------------------%
	properties
		handler	= [];
		timeout	= [];
		flag	= 0;
	end
	properties (SetAccess=protected)
		remote	= dealstruct('ip','port',[]);
		
		msgType	= {};
	end
	properties (Dependent)
		connected;
	end
	%PUBLIC PROPERTIES---------------------------------------------------------%
	
	%PROTECTED PROPERTIES------------------------------------------------------%
	properties (SetAccess=protected, GetAccess=protected)
		lenHeader		= [];
		
		tcpip	= [];
		mode	= [];
		
		L	= [];
		
		messages	= mapping;
		
		msgID	= false(65535,1);
		
		buffer			= struct;
		headerParsed	= false;
		messageParsed	= false;
	end
	properties (GetAccess=protected, Dependent)
		messageComplete;
	end
	properties (GetAccess=protected, Constant)
		HDR_TYPE	= 'uint16';
		
		BASE_PORT	= 30000;
		
		WAIT	= 0.1;
		
		BUFFER_SIZE	= 1000000;
		
		DATA_TYPE	=	{
							'char'
							'uint8'
							'uint16'
							'int8'
							'int16'
							'single'
							'double'
						};
	end
	%PROTECTED PROPERTIES------------------------------------------------------%
	
	
	%PROPERTY GET/SET----------------------------------------------------------%
	methods
		%----------------------------------------------------------------------%
		function b = get.connected(com)
			b	= isequal(get(com.tcpip,'Status'),'open');
		end
		%----------------------------------------------------------------------%
		function b = get.messageComplete(com)
			b	= com.headerParsed && com.messageParsed;
		end
		%----------------------------------------------------------------------%
	end
	%PROPERTY GET/SET----------------------------------------------------------%
	
	
	%PUBLIC METHODS------------------------------------------------------------%
	methods
		function com = Communicator(port,msgType,varargin)
			[remote_ip,opt]	= ParseArgs(varargin,[],...
								'handler'	, []		, ...
								'timeout'	, 10		, ...
								'debug'		, 'error'	, ...
								'silent'	, false		  ...
								);
			
			com.remote.port	= port;
			com.remote.ip	= remote_ip;
			com.msgType		= reshape(ForceCell(msgType),[],1);
			
			com.handler	= opt.handler;
			com.timeout	= opt.timeout;
			
			com.mode			= conditional(isempty(remote_ip),'server','client');
			com.lenHeader		= com.HeaderLength;
			
			com.L	= Log('level',opt.debug,'silent',opt.silent);
			
			com.Initialize();
		end
		function SetFlag(com,value)
			com.flag	= value;
		end
		function value = GetFlag(com)
			value	= com.flag
		end
	end
	%PUBLIC METHODS------------------------------------------------------------%
	
	
	%OVERLOADED FUNCTIONS------------------------------------------------------%
	methods
		function delete(com)
			%close the tcpip object
			com.L.Print('closing tcpip connection','info');
			fclose(com.tcpip);
			delete(com.tcpip);
			
			com.L.Print('melting!','info');
			delete@handle(com);
		end
	end
	%OVERLOADED FUNCTIONS------------------------------------------------------%
	
	
	%PRIVATE METHODS-----------------------------------------------------------%
	methods (Access=private)
		%----------------------------------------------------------------------%
		function nHdr = HeaderLength(com)
			hdr		= com.HeaderStream('blah',com.msgType{1},1); 
			nHdr	= numel(hdr);
		end
		%----------------------------------------------------------------------%
		function bytes = UnitBytes(com,dataType)
			switch dataType
				case 'char'
					bytes	= 1;
				otherwise
					bytes	= varsize(cast(1,dataType));
			end
		end
		%----------------------------------------------------------------------%
		
		
		%----------------------------------------------------------------------%
		function Initialize(com)
			com.L.Print('initializing','info');
			
			com.ResetMessage;
			
			switch com.mode
				case 'client'
					com.L.Print('client mode','info');
					com.tcpip	= tcpip(com.remote.ip, com.remote.port,...
									'OutputBufferSize'			, com.BUFFER_SIZE					, ...
									'BytesAvailableFcnMode'		, 'byte'							, ...
									'BytesAvailableFcnCount'	, 1									, ...
									'BytesAvailableFcn'			, @(obj, evt) com.DataAvailable()	  ...
									);
				case 'server'
					com.L.Print('server mode','info');
					com.tcpip	= tcpip('0.0.0.0', com.remote.port,...
									'NetworkRole'				, 'server'							, ...
									'OutputBufferSize'			, com.BUFFER_SIZE					, ...
									'BytesAvailableFcnMode'		, 'byte'							, ...
									'BytesAvailableFcnCount'	, 1									, ...
									'BytesAvailableFcn'			, @(obj, evt) com.DataAvailable()	  ...
									);
			end
		end
		%----------------------------------------------------------------------%
		
		%message functions
		%----------------------------------------------------------------------%
		function RouteMessage(com)
			msgID	= com.buffer.hdr.msg_id;
			
			com.L.Print(sprintf('routing message %d of type %s: %s',msgID, com.buffer.hdr.msg_type, com.MessageSnippet(com.buffer.msg)),'info');
			
			if com.msgID(msgID) || isempty(com.handler)
			%we're waiting for this reply or there's no handler
				com.PushMessage;
			else
			%send it to the handler
				com.L.Print('calling the message handler','info');
				
				msg	= com.PackageMessage;
				
				try
					com.handler(com, msg);
				catch me
					com.L.Print('an error occurred in the handler','error','exception',me);
					com.L.Print('autosending an error reply','info');
					
					com.Reply(msg,'error');
				end
			end
			
			com.ResetMessage;
		end
		%----------------------------------------------------------------------%
		function PushMessage(com)
			com.L.Print(sprintf('pushing message %d to the stack',com.buffer.hdr.msg_id),'most');
			
			com.messages(com.buffer.hdr.msg_id)	= com.PackageMessage;
		end
		%----------------------------------------------------------------------%
		function msg = PopMessage(com, msgID)
			com.L.Print(sprintf('popping message %d from the stack',msgID),'most');
			
			msg	= com.messages(msgID);
			
			com.messages	= com.messages - msgID;
			
			com.ClearMessageID(msgID);
		end
		%----------------------------------------------------------------------%
		function msg = PackageMessage(com)
			msg	= struct(...
					'id'		, com.buffer.hdr.msg_id		, ...
					'type'		, com.buffer.hdr.msg_type	, ...
					'message'	, {com.buffer.msg}			  ...
					);
		end
		%----------------------------------------------------------------------%
		function ResetMessage(com)
			com.L.Print('reseting the message buffer','most');
			
			if isfield(com.buffer,'hdr')
				com.ClearMessageID(com.buffer.hdr.msg_id);
			end
			
			com.buffer	= struct(...
							'mode'		, 'header'	, ...
							'stream'	, []		, ...
							'hdr'		, []		, ...
							'msg'		, []		  ...
							);
			
			com.headerParsed	= false;
			com.messageParsed	= false;
		end
		%----------------------------------------------------------------------%
		function msg = WaitReply(com,msgID)
			com.L.Print(sprintf('waiting for a reply to message %d',msgID),'info');
			
			tStart	= nowms;
			while isempty(com.messages(msgID)) && nowms<tStart+1000*com.timeout
				pause(com.WAIT);
			end
			
			if isempty(com.messages(msgID))
				msg	= [];
				com.L.Print(sprintf('timed out while waiting for a reply to message %d',msgID),'warn');
			else
				msg	= com.PopMessage(msgID);
				com.L.Print(sprintf('reply to message %d received: %s',msgID,com.MessageSnippet(msg.message)),'info');
			end
		end
		%----------------------------------------------------------------------%
		function str = MessageSnippet(com,message)
			lenSnippet	= 32;
			
			str	= tostring(message);
			
			if numel(str)>lenSnippet
				str	= [str(1:lenSnippet) '...'];
			end
		end
		%----------------------------------------------------------------------%
		
		
		%buffer functions
		%----------------------------------------------------------------------%
		function DataAvailable(com)
			try
				bytes	= get(com.tcpip,'BytesAvailable');
				com.L.Print(sprintf('%d byte%s available',bytes,plural(bytes,'','s')),'all');
				
				switch com.buffer.mode
					case 'header'
						com.ReadHeader;
					case 'message'
						com.ReadMessage;
				end
				
				if com.messageComplete
					com.RouteMessage;
				end
			catch me
				com.L.Print('error while reading data','error','exception',me);
				rethrow(me);
			end
		end
		%----------------------------------------------------------------------%
		function ReadHeader(com)
			com.L.Print('reading the header','all');
			
			if com.PushStream(com.HDR_TYPE) && com.StreamFilled(com.lenHeader)
				com.buffer.hdr	= com.ParseHeader;
				
				com.SetBufferMode('message');
			end
		end
		%----------------------------------------------------------------------%
		function hdr = ParseHeader(com)
			com.L.Print('parsing the header','most');
			
			hdr	= struct(...
					'msg_id'	, com.PopStream(1)					, ...
					'msg_type'	, com.MessageType(com.PopStream(1))	, ...
					'msg_size'	, com.PopStream(2)					, ...
					'data_type'	, com.DataType(com.PopStream(1))	  ...
					);
						
			hdr.msg_length	= prod(hdr.msg_size);
			
			com.headerParsed	= true;
		end
		%----------------------------------------------------------------------%
		function ReadMessage(com)
			com.L.Print('reading the message','all');
			
			if com.PushStream(com.buffer.hdr.data_type) && com.StreamFilled(com.buffer.hdr.msg_length)
				com.buffer.msg	= com.ParseMessage;
				
				com.SetBufferMode('header');
			end
		end
		%----------------------------------------------------------------------%
		function msg = ParseMessage(com)
			com.L.Print('parsing the message','most');
			
			msg	= reshape(com.buffer.stream,com.buffer.hdr.msg_size);
			
			com.messageParsed	= true;
		end
		%----------------------------------------------------------------------%
		function SetBufferMode(com, bufferMode)
			com.buffer.mode		= bufferMode;
			com.buffer.stream	= [];
		end
		%----------------------------------------------------------------------%
		
		%stream functions
		%----------------------------------------------------------------------%
		function bRead = PushStream(com, dataType)
			bRead	= com.UnitAvailable(dataType);
			
			if bRead
				com.L.Print('pushing a unit of data into the buffer stream','all');
				
				data	= com.ReadTCPIP(dataType,1);
				
				if isempty(com.buffer.stream)
					com.buffer.stream			= data;
				else
					com.buffer.stream(end+1)	= data;
				end
			end
		end
		%----------------------------------------------------------------------%
		function b = UnitAvailable(com, dataType)
			if numel(com.buffer.stream) == 20
				x	= 1;
			end
			
			b	= get(com.tcpip,'BytesAvailable') >= com.UnitBytes(dataType);
		end
		%----------------------------------------------------------------------%
		function b = StreamFilled(com, n)
			b	= numel(com.buffer.stream) >= n;
		end
		%----------------------------------------------------------------------%
		function x = PopStream(com,n)
			com.L.Print(sprintf('popping %d unit%s of data from the buffer stream',n,plural(n,'','s')),'all');
			
			x	= com.buffer.stream(1:n);
			com.buffer.stream(1:n)	= [];
		end
		%----------------------------------------------------------------------%
		function msgID = WriteMessage(com,msgType,msg,varargin)
			msgID	= ParseArgs(varargin,[]);
			
			if isempty(msgID)
				msgID	= com.AssignMessageID;
			end
			
			com.L.Print(sprintf('writing message %d of type %s: %s',msgID,msgType,com.MessageSnippet(msg)),'info');
			
			com.WriteHeader(msg, msgType, msgID);
			com.WriteBody(msg);
		end
		%----------------------------------------------------------------------%
		function WriteHeader(com, msg, msgType, msgID)
			com.L.Print(sprintf('writing the header for message %d',msgID),'most');
			
			com.WriteTCPIP(com.HeaderStream(msg, msgType, msgID));
		end
		%----------------------------------------------------------------------%
		function stream = HeaderStream(com, msg, msgType, msgID)
			stream	=	cast([...
							msgID						, ...
							com.MessageType(msgType)	, ...
							com.MessageSize(msg)		, ...
							com.DataType(class(msg))	  ...
						],com.HDR_TYPE);
		end
		%----------------------------------------------------------------------%
		function WriteBody(com, msg)
			com.L.Print('writing the message body','most');
			
			com.WriteTCPIP(msg);
		end
		%----------------------------------------------------------------------%
		
		
		%encoding functions
		%----------------------------------------------------------------------%
		function dataType = DataType(com,dataType)
			switch class(dataType)
				case com.HDR_TYPE
					dataType	= com.DATA_TYPE{dataType};
				case 'char'
					dataType	= find(strcmp(dataType,com.DATA_TYPE));
					
					if isempty(dataType)
						error('unsupported data type');
					end
					
					dataType	= cast(dataType, com.HDR_TYPE);
				otherwise
					error('dataType should be either a class name or a data type code.');
			end
		end
		%----------------------------------------------------------------------%
		function msgType = MessageType(com,msgType)
			switch class(msgType)
				case com.HDR_TYPE
					msgType	= com.msgType{msgType};
				case 'char'
					msgType	= find(strcmp(msgType,com.msgType));
					
					if isempty(msgType)
						error('unsupported message type');
					end
					
					msgType	= cast(msgType, com.HDR_TYPE);
				otherwise
					error('msgType should be a message type string or code');
			end
		end
		%----------------------------------------------------------------------%
		function msgSize = MessageSize(com,msg)
			msgSize	= cast(size(msg), com.HDR_TYPE);
			
			if numel(msgSize)>2
				error('unsupported message dimensions');
			end
		end
		%----------------------------------------------------------------------%
		
		%message IDs
		%----------------------------------------------------------------------%
		function id = AssignMessageID(com)
			switch com.mode
				case 'server'
					idStart	= 1;
					idEnd	= floor(numel(com.msgID)/2);
				case 'client'
					idStart	= floor(numel(com.msgID)/2) + 1;
					idEnd	= numel(com.msgID);
			end
			
			idFree	= idStart-1 + find(~com.msgID(idStart:idEnd));
			id		= cast(randFrom(idFree),com.HDR_TYPE);
			
			com.msgID(id)	= true;
			
			com.L.Print(sprintf('assigned message ID %d',id),'most');
		end
		%----------------------------------------------------------------------%
		function ClearMessageID(com, id)
			com.L.Print(sprintf('cleared message ID %d',id),'most');
			
			com.msgID(id)	= false;
		end
		%----------------------------------------------------------------------%
		
		%TCP/IP functions
		%----------------------------------------------------------------------%
		function x = ReadTCPIP(com,dataType,nUnit)
			com.L.Print(sprintf('reading %d %s element%s',nUnit,dataType,plural(nUnit,'','s')),'all');
			
			x	= reshape(cast(fread(com.tcpip,nUnit,dataType),dataType),1,nUnit);
		end
		%----------------------------------------------------------------------%
		function WriteTCPIP(com,data)
			nUnit		= numel(data);
			dataType	= class(data);
			
			com.L.Print(sprintf('writing %d %s element%s',nUnit,dataType,plural(nUnit,'','s')),'all');
			
			fwrite(com.tcpip,data,dataType);
		end
		%----------------------------------------------------------------------%
	end
	%PRIVATE METHODS-----------------------------------------------------------%
	
end
