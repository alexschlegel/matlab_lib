classdef base < handle
% capture.base
% 
% Description:	base object for capturing images from a device
% 
% Syntax:	cap = capture.base(<options>)
% 
% 			subfunctions:
%				reset	- reset the acquisition program
%				start	- start the acquisition program
%				stop	- stop the acquisition program
%				capture	- capture an image from the device
% 
% 			properties:
% 
% In:
% 	<options>:
%		outdir:		(<none>) the output directory for captured images
%		subdir:		(true) true to create subdirectories by day
%
% Updated: 2013-07-28
% Copyright 2013 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
	
	%PUBLIC PROPERTIES---------------------------------------------------------%
	properties
		outdir	= '';
		subdir	= false;
		
		result	= struct;
	end
	properties (SetAccess=protected)
		ext		= 'jpg';
		
		armed	= false;
	end
	%PUBLIC PROPERTIES---------------------------------------------------------%
	
	%PRIVATE PROPERTIES--------------------------------------------------------%
	properties(SetAccess=protected, GetAccess=protected)
		tmr_acquire	= [];
	end
	%PRIVATE PROPERTIES--------------------------------------------------------%
	
	%PUBLIC METHODS------------------------------------------------------------%
	methods
		function cap = base(varargin)
			%parse the input
				opt	= ParseArgs(varargin,...
						'outdir'	, []	, ...
						'subdir'	, true	  ...
						);
				
				%make sure the output directory exists
					if ~isempty(opt.outdir)
						CreateDirPath(opt.outdir,'error',true);
					end
					
					cap.outdir	= opt.outdir;
					cap.subdir	= opt.subdir;
			
			%get the timer object
				cap.tmr_acquire	= timer(...
									'TimerFcn'		, @(o,e) cap.p_TimerFcn()		, ...
									'StopFcn'		, @(o,e) cap.p_TimerStopFcn()	, ...
									'ExecutionMode'	, 'fixedRate'					  ...
									);
			%initialize
				cap.init;
		end
		function delete(cap)
			cap.reset(true,false);
			delete(cap.tmr_acquire);
		end
	end
	methods (Static)
		
	end
	%PUBLIC METHODS------------------------------------------------------------%
	
	%PRIVATE METHODS-----------------------------------------------------------%
	methods (Access=protected)
		function [im,t,strPathIm] = p_DoCapture(cap,varargin)
			bWait	= ParseArgs(varargin,true);
			
			strPathIm	= '';
			
			im	= uint8(randi(256,[100 100 3])-1);
			t	= nowms;
		end
		function p_CaptureError(cap)
			
		end
		function p_TimerFcn(cap)
			[im,t]		= cap.capture;
			
			if isempty(cap.outdir)
				[h,w,p]								= size(im);
				cap.result.im(1:h,1:w,1:p,end+1)	= im;
			end
			
			cap.result.t(end+1)		= t;
			cap.result.remaining	= cap.result.remaining - 1;
		end
		function p_TimerStopFcn(cap)
			if get(cap.tmr_acquire,'TasksExecuted') >= get(cap.tmr_acquire,'TasksToExecute')
				cap.stop(false);
			end
		end
		
		function status(cap,str,varargin)
			t	= ParseArgs(varargin,[]);
			
			status(str,0,'time',t,'ms',true);
			WaitSecs(0.001);
		end
	end
	%PRIVATE METHODS-----------------------------------------------------------%
end
