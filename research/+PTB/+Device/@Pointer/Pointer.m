classdef Pointer < PTB.Device.Input
% PTB.Device.Pointer
% 
% Description:	base class for pointer devices
% 
% Syntax:	poi = PTB.Device.Pointer(parent,strType)
% 
% 			subfunctions:
% 				Start(<options>):	start the object
%				End:				end the object
%				Position:			get the (x,y) position of the pointer, in
%									pixels
%				PositionVA:			get the (x,y) position of the pointer, with
%									origin at the center of the screen and in
%									degrees of visual angle
%				Pressure:			get the pressure of the pointer
%				Tilt:				get the (x,y) tilt of the pointer
%				Mode:				get the pointer mode (move, draw, or erase)
%				Reset:				reset the pointer
%				Down:				check to see if a button is down
%				DownOnce:			check to see if a button is down, only
%									returning true once per press
%				Pressed:			check to see if a button was pressed
%				State:				get the state of the device
%				Get:				get the state indices associated with a
%									named button
%				Set:				set the state indices associated with a
%									named button
%				ButtonNames:		get the names of all defined buttons
%				SetBase:			set the base state of the pointer device
% 
% In:
%	parent	- the parent object
%	strType	- a short, fieldname-compatible description of the pointer type
%	<options>:
%		rate_pointer:	(100) the maximum rate at which to query the pointer
%						device, in Hz
%		pointer_swapxy:	(<true if magictouch>) true to swap x and y coordinates
%		pointer_swaplr:	(false) true to swap the left/right direction
%		pointer_swapud:	(<true if magictouch>) true to swap the up/down
%						direction
%
% Examples:
%	s=1; rs=0.5; while true, [x,y] = ptb.Pointer.PositionVA; p=MapValue(ptb.Pointer.Pressure,0,2048,-rs/2,rs); s=max(0,min(30,s+p)); [tx,ty]=ptb.Pointer.Tilt; [tx,ty]=varfun(@(x) MapValue(x,-64,64,0,1),tx,ty); col=hsv2rgb([tx,ty,1]); ptb.Show.Circle(col,s,[x y]); ptb.Window.Flip; WaitSecs(0.001); end
%	ptb.Show.Blank; ptb.Window.Store; pMin=0.025; pMaxErase=3; pMaxDraw=0.5; [xLast,yLast]=ptb.Pointer.Position; while true, m=ptb.Pointer.Mode; pMax=switch2(m,ptb.Pointer.MODE_ERASE,pMaxErase,pMaxDraw); [x,y] = ptb.Pointer.PositionVA; p=MapValue(ptb.Pointer.Pressure,0,2048,pMin,pMax); [tx,ty]=ptb.Pointer.Tilt; [tx,ty]=varfun(@(x) MapValue(x,-64,64,0,1),tx,ty); col=switch2(m,ptb.Pointer.MODE_ERASE,'background',hsv2rgb([tx,ty,1])); ptb.Show.Line(col,[xLast yLast],[x y],p); xLast=x; yLast=y; if p>pMin && m~=ptb.Pointer.MODE_MOVE, ptb.Window.Store; end; ptb.Window.Flip; ptb.Window.Recall; WaitSecs(0.001); end
% 
% Updated: 2012-11-27
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
	
	%CONSTANT PROPERTIES-------------------------------------------------------%
	properties (Constant)
		MODE_MOVE	= 0;
		MODE_DRAW	= 1;
		MODE_ERASE	= 2;
		
		IDX_XPOS		= 1;
		IDX_YPOS		= 2;
		IDX_PRESSURE	= 3;
		IDX_XTILT		= 4;
		IDX_YTILT		= 5;
		IDX_DRAW		= 6;
		IDX_ERASE		= 7;
	end
	%CONSTANT PROPERTIES-------------------------------------------------------%
	
	%PRIVATE PROPERTIES--------------------------------------------------------%
	properties (SetAccess=protected, GetAccess=protected)
		deviceid;
		
		tNextState	= PTB.Now;
		lastState;

		lastMode	= 0;
	end
	%PRIVATE PROPERTIES--------------------------------------------------------%
	
	%PUBLIC METHODS------------------------------------------------------------%
	methods
		%----------------------------------------------------------------------%
		function poi = Pointer(parent,strType)
			poi	= poi@PTB.Device.Input(parent,strType);
			
			poi.p_default_name	= {'draw';'erase'};
			poi.p_default_index	= [poi.IDX_DRAW;poi.IDX_ERASE];
		end
		%----------------------------------------------------------------------%
		function Start(poi,varargin)
		%default pointer start function
			bMT	= isequal(poi.type,'magictouch');
			
			opt	= ParseArgs(varargin,...
					'rate_pointer'		, 100	, ...
					'pointer_swapxy'	, bMT	, ...
					'pointer_swaplr'	, false	, ...
					'pointer_swapud'	, bMT	  ...
					);
			
			poi.parent.Info.Set('pointer','rate',opt.rate_pointer,'replace',false);
			
			poi.parent.Info.Set('pointer',{'swap','xy'},opt.pointer_swapxy,'replace',false);
			poi.parent.Info.Set('pointer',{'swap','lr'},opt.pointer_swaplr,'replace',false);
			poi.parent.Info.Set('pointer',{'swap','ud'},opt.pointer_swapud,'replace',false);
			
			Start@PTB.Device.Input(poi,varargin{:});
			
			poi.Reset;
		end
		%----------------------------------------------------------------------%
	end
	%PUBLIC METHODS------------------------------------------------------------%
	
	%PRIVATE METHODS-----------------------------------------------------------%
	methods (Access=protected)
		x = GetPointer(poi);
	end
	%PRIVATE METHODS-----------------------------------------------------------%
end
