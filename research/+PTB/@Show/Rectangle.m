function Rectangle(shw,col,s,varargin)
% PTB.Show.Rectangle
% 
% Description:	add a rectangle to the screen
% 
% Syntax:	shw.Rectangle(col,s,[p]=<center/top-left>,[a]=0,<options>)
% 
% In:
%	col	- the rectangle color (see PTB.Color)
%	s	- the (w,h) rectangle size (or (s) for squares, in degrees of visual
%		  angle
%	[p]	- the (x,y) coordinates of the rectangle center, in degrees of visual
%		  angle
%	[a]	- the rotation of the rectangle about its center, in clockwise degrees
%		  from vertical
% 	<options>:
%		window:			('main') the name of the window on which to show the
%						circle
%		center:			(true) true if given coordinates are relative to the
%						screen center
%		border:			(false) true to surround the rectangle with a border
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
						'border'		, false		, ...
						'border_color'	, 'black'	, ...
						'border_size'	, 1/6		  ...
						);
		cOptDefault	= opt2cell(optDefault);
	end
	
	if nargin<4 || (isnumeric(varargin{1}) && (nargin<5 || (isnumeric(varargin{2}) && nargin<6)))
	%if nargin<6 && (nargin<4 || isnumeric(varargin{1})) && (nargin<5 || isnumeric(varargin{2}))
		opt	= optDefault;
		
		[p,a]	= ParseArgs(varargin,[0 0],0);
	else
		[p,a,opt]	= ParseArgs(varargin,[0 0],0,cOptDefault{:});
	end

[h,sz]	= shw.parent.Window.Get(opt.window);

%parse the color
	col	= shw.parent.Color.Get(col);
%get the (w,h)
	s	= repto(reshape(s,1,[]),[1 2]);
%get the size/position of things in pixels
	sPx	= shw.parent.Window.va2px(s);
	pPx	= shw.parent.Window.va2px(p);
	
	if opt.center
		pPx		= pPx + sz/2;
		rect	= [pPx-sPx/2 pPx+sPx/2];
	else
		rect	= [pPx pPx+sPx];
	end
%draw the rectangle
	if a~=0
		%first draw to the hidden window
			hHidden	= shw.parent.Window.Get('hidden');
			shw.Blank('window','hidden');
			Screen('FrameRect',hHidden,col,rect,min(sPx));
		%now draw onto the window with proper rotation
			Screen('DrawTexture',h,hHidden,rect,rect,a,0);
	else
		Screen('FrameRect',h,col,rect,min(sPx));
	end
%add the borders
	if opt.border
		shw.Frame(opt.border_color,s,opt.border_size,p,a,...
				'window'	, opt.window	, ...
				'center'	, opt.center	  ...
				);
	end
