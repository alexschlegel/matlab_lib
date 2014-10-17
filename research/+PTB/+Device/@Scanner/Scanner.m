classdef Scanner < PTB.Object
% PTB.Device.Scanner
% 
% Description:	query and simulate the scanner
% 
% Syntax:	scn = PTB.Device.Scanner(parent)
% 
% 			subfunctions:
% 				Start(<options>):	start the object
%				End:				end the object
%				StartScan:			call before the scan starts
%				StopScan:			call after the scan ends
%				TR:					get the current TR
%				TR2ms:				convert a TR to a PTB.Now time
%				ms2TR:				convert a PTB.Now time to a TR
%				SimulateTR:			simulate a TR trigger
% 
% In:
%	parent	- the parent object
% 	<options:
%		tr:					(2000) the expected scanner trigger interval, in ms
%		scanner_simulate:	(<auto>) true to simulate the scanner.  if
%							simulating, calling StartScan will cause simulated
%							scanner triggers to be sent to the serial port and
%							F9-F12 will mimic the blue, yellow, red, and green
%							button box buttons, respectively.
% 
% Updated: 2012-12-01
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
	
	%CONSTANT PROPERTIES-------------------------------------------------------%
	properties (Constant)
		%DBIC scanner outputs
			SCANNER_TRIGGER		= 53;
			SCANNER_BB_BLUE		= 49;
			SCANNER_BB_YELLOW	= 50;
			SCANNER_BB_GREEN	= 51;
			SCANNER_BB_RED		= 52;
	end
	%CONSTANT PROPERTIES-------------------------------------------------------%

	%PRIVATE PROPERTIES--------------------------------------------------------%
	properties (SetAccess=private, GetAccess=private)
		TKey;
		TSim;
	end
	%PRIVATE PROPERTIES--------------------------------------------------------%
	
	
	%PROPERTY GET/SET----------------------------------------------------------%
	methods
		
	end
	%PROPERTY GET/SET----------------------------------------------------------%
	
	
	%PUBLIC METHODS------------------------------------------------------------%
	methods
		%----------------------------------------------------------------------%
		function scn = Scanner(parent)
			scn	= scn@PTB.Object(parent,'scanner');
		end
		%----------------------------------------------------------------------%
		function Start(scn,varargin)
		% start the Scanner object
			opt	= ParseArgs(varargin,...
					'tr'				, 2000	, ...
					'scanner_simulate'	, []	  ...
					);
			
			if isempty(opt.scanner_simulate)
				strContext	= scn.parent.Info.Get('experiment','context');
				dbg			= scn.parent.Info.Get('experiment','debug');
				
				opt.scanner_simulate	= isequal(strContext,'fmri') && dbg>1;
			end
			
			scn.parent.Info.Set('scanner',{'tr','per'},opt.tr,'replace',false);
			scn.parent.Info.Set('scanner',{'tr','heard'},0,'replace',false);
			scn.parent.Info.Set('scanner',{'tr','total'},0,'replace',false);
			scn.parent.Info.Set('scanner',{'tr','time'},[],'replace',false);
			
			scn.parent.Info.Set('scanner','reset',true,'replace',false);
			scn.parent.Info.Set('scanner','simulate',opt.scanner_simulate,'replace',false);
			
			scn.parent.Info.Set('scanner','running',false,'replace',false);
			
			%timer for setting TRs
				scn.TSim	= timer(...
								'Name'			, 'scannersim_tr'				, ...
								'TimerFcn'		, @(varargin) scn.SimulateTR	, ...
								'Period'		, opt.tr						, ...
								'ExecutionMode'	,'fixedRate'					, ...
								'StartDelay'	, 3								  ...
								);
			
			if scn.parent.Info.Get('scanner','simulate')
				scn.AddLog('simulation mode');
				
				%timer for checking buttonbox keys (to simulate serial
				%communication where the button press is registered even if we're
				%not checking when it is down)
					scn.TKey	= timer(...
									'Name'			, 'scannersim_key_check'			, ...
									'TimerFcn'		, @(varargin) p_CheckSimKeys(scn)	, ...
									'Period'		, 0.01								, ...
									'ExecutionMode'	, 'fixedSpacing'					  ...
									);
				
				if scn.parent.Info.Get('scanner','running')
				%"scanner" is currently running
					p_StartSimTimers(scn);
				end
			end
		end
		%----------------------------------------------------------------------%
		function End(scn,varargin)
		% end the Scanner object
			scn.StopScan;
			
			try
				delete(scn.TKey);
				delete(scn.TSim);
			catch me
				scn.AddLog(['error deleting timers (' me.message ')']); 
			end
			
			%try to delete stray timers
				try
					tmr	= timerfind('Name','scannersim_key_check');
					if ~isempty(tmr)
						delete(tmr);
					end
				catch me
				end
				try
					tmr	= timerfind('Name','scannersim_tr');
					if ~isempty(tmr)
						delete(tmr);
					end
				catch me
				end
		end
		%----------------------------------------------------------------------%
	end
	%PUBLIC METHODS------------------------------------------------------------%
end
