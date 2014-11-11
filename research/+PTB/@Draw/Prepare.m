function Prepare(drw,varargin)
% PTB.Draw.Prepare
% 
% Description:	prepare the object for drawing more quickly when Go is called
% 
% Syntax:	drw.Prepare(<options>)
%
% In:
%	<options>:
%		underlay:	(<none>) an underlay image or the handle to a function
%						that takes the current time, the time of the next flip,
%						and a texture handle as inputs and draws the underlay on
%						that texture
% 
% Updated: 2012-12-06
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'underlay'	, []	  ...
		);

tNow	= PTB.Now;

%misc stuff
	drw.penhistory	= [];
	drw.lasttime	= 0;
	drw.lastrecord	= [0 0 0];
	drw.lastmode	= 0;
	drw.lastremain	= 0;
	drw.actualmode	= 0;
	drw.timerleft	= 0;
	drw.timertotal	= 0;
%set the underlay
	drw.underlay	= opt.underlay;
%set the functions
	f	= drw.parent.Info.Get('draw','f');
	
	%should we show the timer?
		drw.showtimer	= drw.parent.Info.Get('draw',{'show','timer'});
		
		if isempty(drw.showtimer)
			if isnumeric(f.end)
			%drawing duration was specified
				drw.showtimer	= true;
			elseif isa(f.end,'function_handle')
			%it's a function
				try
				%see if we get three outputs from the end function
					[b,tR,tT]	= f.end(0,0);
					
					drw.showtimer	= true;
				catch me
				%nope.  no timer
					drw.showtimer	= false;
				end
			else
			%something else, no timer
				drw.showtimer	= false;
			end
		end
	
	drw.f.pen.shape		= p_GetShapeFunction(drw,f.pen.shape,'pen shape');
	drw.f.pen.color		= p_GetColorFunction(drw,f.pen.color,'pen color');
	drw.f.erase.shape	= p_GetShapeFunction(drw,f.erase.shape,'erase shape');
	drw.f.start			= p_GetFunction(drw,f.start,true,true,'start function');
	drw.f.end			= p_GetFunction(drw,f.end,true,true,'end function');
	drw.f.wait			= p_GetFunction(drw,f.wait,false,false,'wait function');
%initialize the result struct
	nInit	= 1000000;
	rBlank	= NaN(nInit,1);
	
	sPaper	= p_GetPaperSize(drw);
	
	drw.result	= struct(...
				'tstart'		, []		, ...
				'tend'			, []		, ...
				'N'				, 0			, ...
				'x'				, rBlank	, ...
				'y'				, rBlank	, ...
				'm'				, rBlank	, ...
				't'				, rBlank	, ...
				's'				, sPaper	, ...
				'im'			, []		, ...
				'fliprate'		, []		, ...
				'recordrate'	, []		, ...
				'abort'			, false		  ...
				);
%reset the drawing
	drw.Reset(false);
%block the monitor
	drw.parent.Window.BlockMonitor;

drw.prepared	= true;
