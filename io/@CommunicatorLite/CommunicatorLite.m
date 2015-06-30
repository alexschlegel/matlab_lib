classdef CommunicatorLite < handle
% CommunicatorLite
% 
% Description:	a sleeker version of a Communicator that allows single bytes to
%				be transferred between two instances of MATLAB using tcp/ip
% 
% Syntax:	com = Communicator(port,[remote_ip]=<none>,<options>)
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
%				remote:		a struct of info about the remote partner
%				timeout:	the number of seconds to wait before timing out
%				flag:		a flag that can be used for any purpose (e.g. for
%							forgetful workers in a parfor loop)
% 
% In:
%	port		- the port on which to communicate with the other party
%	[remote_ip]	- the ip address of the other party. only one Communiator should
%				  specify this.
% 	<options>:
%		handler:	(<none>) a function that gets called when a new message is
%					available. this object and the message byte will be passed
%					as inputs. the function must Reply to the message.
%		timeout:	(10) the number of seconds to wait for something to happen
%					before timing out
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
		mode	= [];
	end
	properties (Dependent)
		connected;
	end
	%PUBLIC PROPERTIES---------------------------------------------------------%
	
	%PROTECTED PROPERTIES------------------------------------------------------%
	properties (SetAccess=protected, GetAccess=protected)
		tcpip	= [];
		
		bufferMessage	= [];
		bufferStage		= 0;
		
		idOutOccupied	= [];
		idInOccupied	= [];
		
		msgIn	= [];
	end
	properties (GetAccess=protected, Constant)
		NUM_MESSAGES_MAX	= 255;
		
		BASE_PORT	= 30000;
		
		WAIT_LONG	= 0.1;
		WAIT_SHORT	= 0.01;
		
		BUFFER_SIZE	= 1000000;
		
		STAGE_HEADER	= 1;
		STAGE_MESSAGE	= 2;
		STAGE_ROUTE		= 3;
	end
	%PROTECTED PROPERTIES------------------------------------------------------%
	
	
	%PROPERTY GET/SET----------------------------------------------------------%
	methods
		%----------------------------------------------------------------------%
		function b = get.connected(com)
			b	= strcmp(get(com.tcpip,'Status'),'open');
		end
		%----------------------------------------------------------------------%
	end
	%PROPERTY GET/SET----------------------------------------------------------%
	
	
	%PUBLIC METHODS------------------------------------------------------------%
	methods
		function com = CommunicatorLite(port,varargin)
			[remote_ip,opt]	= ParseArgs(varargin,[],...
								'handler'	, []		, ...
								'timeout'	, 10		  ...
								);
			
			com.remote.port	= port;
			com.remote.ip	= remote_ip;
			
			com.handler	= opt.handler;
			com.timeout	= opt.timeout;
			
			com.mode	= conditional(isempty(remote_ip),'server','client');
			
			com.Initialize;
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
			fclose(com.tcpip);
			delete(com.tcpip);
			
			delete@handle(com);
		end
	end
	%OVERLOADED FUNCTIONS------------------------------------------------------%
	
	
	%PRIVATE METHODS-----------------------------------------------------------%
	methods (Access=private)
		%----------------------------------------------------------------------%
		function Initialize(com)
			[com.idInOccupied,com.idOutOccupied]	= deal(false(com.NUM_MESSAGES_MAX,1));
			com.msgIn								= zeros(com.NUM_MESSAGES_MAX,1,'uint8');
			
			com.ResetBuffer;
			
			switch com.mode
				case 'client'
					com.tcpip	= tcpip(com.remote.ip, com.remote.port,...
									'OutputBufferSize'			, com.BUFFER_SIZE					, ...
									'BytesAvailableFcnMode'		, 'byte'							, ...
									'BytesAvailableFcnCount'	, 2									, ...
									'BytesAvailableFcn'			, @(obj, evt) com.DataAvailable()	  ...
									);
				case 'server'
					com.tcpip	= tcpip('0.0.0.0', com.remote.port,...
									'NetworkRole'				, 'server'							, ...
									'OutputBufferSize'			, com.BUFFER_SIZE					, ...
									'BytesAvailableFcnMode'		, 'byte'							, ...
									'BytesAvailableFcnCount'	, 2									, ...
									'BytesAvailableFcn'			, @(obj, evt) com.DataAvailable()	  ...
									);
			end
		end
		%----------------------------------------------------------------------%
		
		%message functions
		%----------------------------------------------------------------------%
		function WriteMessage(com,msg)
			com.WriteTCPIP(msg.id);
			com.WriteTCPIP(msg.message);
		end
		%----------------------------------------------------------------------%
		function PushMessageIn(com,msg)
			com.idInOccupied(msg.id)	= true;
			com.msgIn(msg.id)			= msg.message;
		end
		%----------------------------------------------------------------------%
		function msg = PopMessageIn(com,id)
			assert(com.idInOccupied(id),'message %d does not exist',id);
			
			msg	= struct('id',id,'message',com.msgIn(id));
			
			com.ClearMessageIn(id);
			com.ClearMessageOut(id);
		end
		%----------------------------------------------------------------------%
		function ClearMessageIn(com,id)
			com.idInOccupied(id)	= false;
			com.msgIn(id)			= 0;
		end
		%----------------------------------------------------------------------%
		function ClearMessageOut(com,id)
			com.idOutOccupied(id)	= false;
		end
		%----------------------------------------------------------------------%
		function msg = WaitForReply(com,id)
			tStart	= nowms;
			while ~com.idInOccupied(id) && nowms<tStart+1000*com.timeout
				pause(com.WAIT_SHORT);
			end
			
			if com.idInOccupied(id)
			%got it
				msg	= com.PopMessageIn(id);
			else
			%timed out
				msg	= [];
			end
		end
		%----------------------------------------------------------------------%
		function id = AssignMessageID(com,bReplyExpected)
			switch com.mode
				case 'server'
					idStart	= 1;
					idEnd	= 127;
				case 'client'
					idStart	= 128;
					idEnd	= com.NUM_MESSAGES_MAX;
			end
			
			id	= idStart-1 + find(~com.idOutOccupied(idStart:idEnd),1);
			
			if bReplyExpected
				com.idOutOccupied(id)	= true;
			end
		end
		%----------------------------------------------------------------------%
		
		
		
		%buffer functions
		%----------------------------------------------------------------------%
		function DataAvailable(com,obj,evt)
			while get(com.tcpip,'BytesAvailable')>0
				switch com.bufferStage
					case com.STAGE_HEADER
						com.ReadBufferHeader;
					case com.STAGE_MESSAGE
						com.ReadBufferMessage;
						
						if com.bufferStage==com.STAGE_ROUTE
							com.RouteBufferMessage;
						end
					otherwise
						error('buffer is in unknown stage %d',com.bufferStage);
				end
			end
		end
		%----------------------------------------------------------------------%
		function ReadBufferHeader(com)
			com.bufferMessage.id	= com.ReadTCPIP;
			
			com.SetBufferStage(com.STAGE_MESSAGE);
		end
		%----------------------------------------------------------------------%
		function ReadBufferMessage(com)
			com.bufferMessage.message	= com.ReadTCPIP;
			
			com.SetBufferStage(com.STAGE_ROUTE);
		end
		%----------------------------------------------------------------------%
		function RouteBufferMessage(com)
			if com.idOutOccupied(com.bufferMessage.id) || isempty(com.handler)
			%we've been waiting for this reply or there's no handler
				com.PushMessageIn(com.bufferMessage);
			else
			%send it to the handler
				com.handler(com,com.bufferMessage);
			end
			
			com.ResetBuffer;
		end
		%----------------------------------------------------------------------%
		function ResetBuffer(com)
			com.bufferStage		= com.STAGE_HEADER;
			com.bufferMessage	= struct('id',0,'message',uint8(0));
		end
		%----------------------------------------------------------------------%
		function SetBufferStage(com, stage)
			com.bufferStage		= stage;
		end
		%----------------------------------------------------------------------%
		
		%TCP/IP functions
		%----------------------------------------------------------------------%
		function x = ReadTCPIP(com)
			x	= uint8(fread(com.tcpip,1,'uint8'));
		end
		%----------------------------------------------------------------------%
		function WriteTCPIP(com,byte)
			fwrite(com.tcpip,uint8(byte),'uint8');
		end
		%----------------------------------------------------------------------%
	end
	%PRIVATE METHODS-----------------------------------------------------------%
	
end
