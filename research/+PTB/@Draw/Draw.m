classdef Draw < PTB.Object
% PTB.Draw
% 
% Description:	handle drawing functions
% 
% Syntax:	drw = PTB.Draw(parent)
% 
% 			subfunctions:
% 				Start(<options>):	initialize the object
%				End:				end the object
%				Reset:				reset the object to its initial state
%				Prepare:			prepare the object for drawing more quickly
%									when Go is called
%				Go:					start drawing!
%
% In:
%	parent	- the parent object
% 	<options>:
%		draw_pen_shape:		(3) the pen shape. one of the following:
%								s:	a circle with diameter s pixels
%								b:	a logical array specifying the pen shape
%								f:	the handle to a function that takes the
%									time of the next flip and the drawing
%									start time and returns a logical array
%									specifying the pen
%		draw_pen_color:		('black') the pen color.  one of the following:
%								col:	the pen color
%								f:		the handle to a function that takes the
%										time of the next flip and the drawing
%										start time and returns the pen color
%		draw_pen_blend:		(PTB.Draw.BLEND_REPLACE) specify how the pen should
%							blend with the paper and existing pen marks. one of
%							the following:
%								PTB.Draw.BLEND_REPLACE
%		draw_erase_shape:	(30) specify the eraser shape. see draw_pen_shape.
%		draw_paper_size:	('letter') the paper size.  one of the following:
%								s:		the [W H] paper size, in d.v.a
%								str:	one of the following strings:
%									'letter': letter size, filling the window
%									'letter_wide': slightly wider than letter
%									'letter_land': landscape oriented letter
%									size
%									'fill': fill the screen
%		draw_paper_color:	('paper') the paper color
%		draw_back_color:	('black') the color behind the paper
%		draw_rate_flip:		(100) the screen flip rate, in Hz
%		draw_rate_pen:		(10) the pen update rate, in Hz
%		draw_rate_record:	(50) the pen record rate, in Hz
%		draw_rate_timer:	(10) the timer update rate, in Hz
%		draw_f_start:		(0) specify when to start the drawing after Go is
%							called.  one of the following:
%								t:		a time, either absolute or relative to
%										the Go time
%								str:	the name of an Input button that starts
%										the drawing when pressed down
%								f:		the handle to a function that determines
%										when to start the drawing.  takes the
%										current time and the drawing Go time and
%										returns a logical.
%		draw_f_end:			('key_end') specify when to end the drawing after it
%					  		starts. see draw_f_start for valid values, except
%					  		that the drawing start time is used rather than the
%							Go time. may also return the number of milliseconds
%							left in the drawing and the total number of
%							milliseconds in the drawing (see draw_show_timer).
%		draw_f_wait:		(<do nothing>) the handle to a function to call
%							while the drawing is waiting for its next refresh.
%							takes this object, the current time, the time of the
%							next flip, and the drawing start time and returns a
%							logical specifying whether to abort the drawing.
%		draw_show_mode:		(true) true to show the drawing mode
%		draw_show_timer:	(<true if possible>) true if a timer countdown
%							should also be shown.  if this is true, then either
%							draw_f_end must be a time or must return the
%							remaining and total time as well.
%		draw_mode_delay		(100) the number of milliseconds that the pen must
%							be stationary before the mode can switch to draw or
%							erase
% 
% Updated: 2012-12-01
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

	%CONSTANT PROPERTIES-------------------------------------------------------%
	properties (Constant)
		BLEND_REPLACE	= 1;
	end
	%CONSTANT PROPERTIES-------------------------------------------------------%
	
	%PRIVATE CONSTANT PROPERTIES-----------------------------------------------%
	properties (Constant)
		
	end
	%PRIVATE CONSTANT PROPERTIES-----------------------------------------------%
	
	%PUBLIC PROPERTIES---------------------------------------------------------%
	properties (SetAccess=protected)
		result		= struct;
		
		prepared	= false;
		running		= false;
		ran			= false;
	end
	%PUBLIC PROPERTIES---------------------------------------------------------%
	
	
	%PRIVATE PROPERTIES--------------------------------------------------------%
	properties (SetAccess=protected, GetAccess=protected)
		penhistory	= [];
		
		lasttime	= 0;
		lastrecord	= [0 0 0];	%mode x y
		lastmode	= 0;
		lastremain	= 0;
		actualmode	= 0;
		
		underlay	= [];
		
		showtimer	= false;
		timerleft	= 0;
		timertotal	= 0;
		
		t	= struct(...
				'go'	, 0	, ...
				'start'	, 0	, ...
				'flip'	, 0	, ...
				'end'	, 0	, ...
				'first'	, struct(...
							'flip'		, 0	, ...
							'pen'		, 0	, ...
							'record'	, 0	  ...
							),...
				'next'	, struct(...
							'flip'		, 0	, ...
							'pen'		, 0	, ...
							'record'	, 0	  ...
							)...
				);
		f	= struct(...
				'start'	, []				, ...
				'end'	, []				, ...
				'wait'	, []				, ...
				'pen'	, struct(			  ...
							'shape'	, []	, ...
							'color'	, []	  ...
							)				, ...
				'erase'	, struct(			  ...
							'shape'	, []	  ...
							)				  ...
				);
		current	= struct(...
					't'		, 0							, ...
					'pen'	, struct(					  ...
								'position'	, [0 0]		, ...
								'shape'		, 0			, ...
								'color'		, [0 0 0]	, ...
								'mode'		, 0			  ...
								)						, ...
					'erase'	, struct(					  ...
								'shape'	, 0				  ...
								)						  ...
					);
	end
	%PRIVATE PROPERTIES--------------------------------------------------------%
	
	
	%PROPERTY GET/SET----------------------------------------------------------%
	methods
		
	end
	%PROPERTY GET/SET----------------------------------------------------------%
	
	
	%PUBLIC METHODS------------------------------------------------------------%
	methods
		%----------------------------------------------------------------------%
		function drw = Draw(parent)
			drw	= drw@PTB.Object(parent,'draw');
		end
		%----------------------------------------------------------------------%
		function Start(drw,varargin)
		% initialize the draw object
			opt	= ParseArgs(varargin,...
					'draw_pen_shape'		, 3									, ...
					'draw_pen_color'		, 'black'							, ...
					'draw_pen_blend'		, PTB.Draw.BLEND_REPLACE			, ...
					'draw_erase_shape'		, 30								, ...
					'draw_paper_size'		, 'letter'							, ...
					'draw_paper_color'		, 'paper'							, ...
					'draw_back_color'		, 'black'							, ...
					'draw_rate_flip'		, 100								, ...
					'draw_rate_pen'			, 10								, ...
					'draw_rate_record'		, 50								, ...
					'draw_rate_timer'		, 10								, ...
					'draw_f_start'			, 0									, ...
					'draw_f_end'			, 'key_end'							, ...
					'draw_f_wait'			, @(drw,tNow,tFlip,tStart) false	, ...
					'draw_show_mode'		, true								, ...
					'draw_show_timer'		, []								, ...
					'draw_mode_delay'		, 250								  ...
					);
			
			drw.parent.Info.Set('draw',{'f','pen','shape'},opt.draw_pen_shape,'replace',false);
			drw.parent.Info.Set('draw',{'f','pen','color'},opt.draw_pen_color,'replace',false);
			drw.parent.Info.Set('draw',{'f','erase','shape'},opt.draw_erase_shape,'replace',false);
			drw.parent.Info.Set('draw',{'f','start'},opt.draw_f_start,'replace',false);
			drw.parent.Info.Set('draw',{'f','end'},opt.draw_f_end,'replace',false);
			drw.parent.Info.Set('draw',{'f','wait'},opt.draw_f_wait,'replace',false);
			
			drw.parent.Info.Set('draw',{'paper','size'},opt.draw_paper_size,'replace',false);
			
			drw.parent.Color.Set('draw_paper',opt.draw_paper_color,'replace',false);
			drw.parent.Color.Set('draw_back',opt.draw_back_color,'replace',false);
			
			drw.parent.Info.Set('draw',{'rate','flip'},opt.draw_rate_flip,'replace',false);
			drw.parent.Info.Set('draw',{'rate','pen'},opt.draw_rate_pen,'replace',false);
			drw.parent.Info.Set('draw',{'rate','record'},opt.draw_rate_record,'replace',false);
			drw.parent.Info.Set('draw',{'rate','timer'},opt.draw_rate_timer,'replace',false);
			
			drw.parent.Info.Set('draw',{'pen','blend'},opt.draw_pen_blend,'replace',false);
			
			drw.parent.Info.Set('draw',{'show','mode'},opt.draw_show_mode,'replace',false);
			drw.parent.Info.Set('draw',{'show','timer'},opt.draw_show_timer,'replace',false);
			
			drw.parent.Info.Set('draw',{'mode','delay'},opt.draw_mode_delay,'replace',false);
			
			p_OpenTextures(drw);
		end
		%----------------------------------------------------------------------%
		function End(drw,varargin)
		% end the draw object
			p_ReleaseTextures(drw);
		end
		%----------------------------------------------------------------------%
	end
	%PUBLIC METHODS------------------------------------------------------------%
end
