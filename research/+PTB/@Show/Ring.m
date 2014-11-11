function Ring(shw,col,r,t,varargin)
% PTB.Show.Ring
% 
% Description:	add a ring to the screen
% 
% Syntax:	shw.Ring(col,r,t,[p]=<center/top-left>,[a]=0,<options>)
% 
% In:
%	col	- the ring color (see PTB.Color)
%	r	- the ring outer edge radius (or radii for ellipses), in degrees of
%		  visual angle
%	t	- the ring thickness, in degrees of visual angle
%	[p]	- the (x,y) coordinates of the ring center, in degrees of visual angle
%	[a]	- the rotation of the ring about its center, in clockwise degrees from
%		  vertical
% 	<options>:
%		window:			('main') the name of the window on which to show the
%						circle
%		center:			(true) true if given coordinates are relative to the
%						screen center
%		astart:			(0) the start angle of the arc in degrees, measured
%						clockwise from vertical
%		aend:			(360) the end angle of the arc to draw in degrees,
%						measured clockwise from vertical
%		border:			(false) true to surround the ring with a border
%		border_color:	('black') the border color
%		border_size:	(1/6) the border thickness, in degrees of visual angle
% 
% Updated: 2011-12-19
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
persistent optDefault cOptDefault;

%parse the arguments
	if isempty(optDefault)
		optDefault	= struct(...
						'window'		, 'main'	, ...
						'center'		, true		, ...
						'astart'		, 0			, ...
						'aend'			, 360		, ...
						'border'		, false		, ...
						'border_color'	, 'black'	, ...
						'border_size'	, 1/6		  ...
						);
		cOptDefault	= opt2cell(optDefault);
	end
	
	if nargin<5 || (isnumeric(varargin{1}) && (nargin<6 || (isnumeric(varargin{2}) && nargin<7)))
	%if nargin<7 && (nargin<5 || isnumeric(varargin{1})) && (nargin<6 || isnumeric(varargin{2}))
		opt	= optDefault;
		
		[p,a]	= ParseArgs(varargin,[0 0],0);
	else
		[p,a,opt]	= ParseArgs(varargin,[0 0],0,cOptDefault{:});
	end

[h,sz]	= shw.parent.Window.Get(opt.window);

%parse the color
	col	= shw.parent.Color.Get(col);
%get both radii
	r	= repto(reshape(r,1,[]),[1 2]);
%get the size/position of things in pixels
	rPx	= shw.parent.Window.va2px(r);
	pPx	= shw.parent.Window.va2px(p);
	tPx	= shw.parent.Window.va2px(t);
	
	if opt.center
		pPx		= pPx + sz/2;
		rect	= [pPx-rPx pPx+rPx];
	else
		rect	= [pPx pPx+2*rPx];
	end
%draw the circle
	aWidth	= opt.aend-opt.astart;
	
	if a~=0
		%first draw to the hidden window
			hHidden	= shw.parent.Window.Get('hidden');
			shw.Blank('window','hidden');
			Screen('FrameArc',hHidden,col,rect,opt.astart,aWidth,tPx);
		%now draw onto the window with proper rotation
			Screen('DrawTexture',h,hHidden,rect,rect,a,0);
	else
		Screen('FrameArc',h,col,rect,opt.astart,aWidth,tPx);
	end
%add the borders
	if opt.border
		shw.Ring(opt.border_color,r,opt.border_size,p,a,...
				'window'	, opt.window	, ...
				'center'	, opt.center	, ...
				'astart'	, opt.astart	, ...
				'aend'		, opt.aend		  ...
				);
		
		pInner	= conditional(opt.center,p,p+t);
		shw.Ring(opt.border_color,r-t,opt.border_size,pInner,a,...
				'window'	, opt.window	, ...
				'center'	, opt.center	, ...
				'astart'	, opt.astart	, ...
				'aend'		, opt.aend		  ...
				);
	end
