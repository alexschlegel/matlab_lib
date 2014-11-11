classdef Trigger < PTB.Object   
% PTB.Device.Trigger
% 
% Description: set and send EEG triggers
% 
% Syntax:	tr = PTB.Device.Trigger(parent)
% 
% 			subfunctions:
% 				Start(<options>):	start the object
%				End:				end the object                
%				Set:				set a named trigger code
%				Get:				get a named trigger code
%				Send:				send a trigger
% 
% In:
%	parent	- the parent object
%   <options>
%		trigger:		(true) true to actually send triggers
%		daq_rate:		(2048) the sampling rate of the data aquisition device
%		baseaddr:		('d880') the base address of the pci card
%		triggermode:	('numeric') 'numeric' to send numeric triggers, 'bit' to
%						send bit type triggers
%       log_trigger:	(false) true to log trigger events
% 
% Updated: 2012-03-29
% Updated by: Scottie Alexander, Alex Schlegel
% Original code by: Alex Schlegel
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

	%CONSTANT PROPERTIES-------------------------------------------------------%
	properties (Constant)
		
	end
	%CONSTANT PROPERTIES-------------------------------------------------------%

	%PUBLIC PROPERTIES---------------------------------------------------------%
	properties (SetAccess=protected)
        
	end
	%PUBLIC PROPERTIES---------------------------------------------------------%
	
	
	%PRIVATE PROPERTIES--------------------------------------------------------%
	properties (SetAccess=protected, GetAccess=protected)

	end
	%PRIVATE PROPERTIES--------------------------------------------------------%
	
	
	%PROPERTY GET/SET----------------------------------------------------------%
	methods
		
	end
	%PROPERTY GET/SET----------------------------------------------------------%
	
	
	%PUBLIC METHODS------------------------------------------------------------%
	methods
		%----------------------------------------------------------------------%
		function tr = Trigger(parent)
			tr	= tr@PTB.Object(parent,'trigger');
		end
		%----------------------------------------------------------------------%
		function Start(tr,varargin)
			
			% get context and debug info
				strContext		= tr.parent.Info.Get('experiment','context');
				vDebug			= tr.parent.Info.Get('experiment','debug');
				bTriggerDefault	= strcmpi(strContext,'eeg') && vDebug < 2;
			
			opt	= ParseArgs(varargin,...
					'trigger'		, bTriggerDefault	,...
					'daq_rate'		, 2048			, ...
					'baseaddr'		, 'd880'			, ...
					'triggermode'	, 'numeric'		, ...
					'log_trigger'	, false			  ...
					);
				
			% check the trigger mode
				opt.triggermode = CheckInput(opt.triggermode,'triggermode',{'numeric','bit'}); 
			
			% add the option values to the info struct
				tr.parent.Info.Set(tr.type,'send',opt.trigger,'replace',false);
				tr.parent.Info.Set(tr.type,'daq_rate',opt.daq_rate,'replace',false);
				tr.parent.Info.Set(tr.type,'address',opt.baseaddr,'replace',false);
				tr.parent.Info.Set(tr.type,'mode',opt.triggermode,'replace',false);
				tr.parent.Info.Set(tr.type,'log',opt.log_trigger,'replace',false);
			
			% check that the trigger works
				p_CheckTrigger(tr);
			
		end
		%----------------------------------------------------------------------%
	end
	%PUBLIC METHODS------------------------------------------------------------%
end
