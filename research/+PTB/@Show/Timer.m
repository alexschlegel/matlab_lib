function t = Timer(shw,tStart,tTotal,varargin)
% PTB.Show.Timer
% 
% Description:	show a timer countdown
% 
% Syntax:	t = shw.Circle(col,tStart,tTotal,[r]=2,[p]=<center/top-left>,<options>)
% 
% In:
%	tStart	- the PTB.Now start time
%	tTotal	- the total number of milliseconds in the process
%	[r]	- the timer radius in degrees of visual angle
%	[p]	- the (x,y) coordinates of the timer, in degrees of visual angle
% 	<options>:
%		window:			('main') the name of the window on which to show the
%						timer
%		center:			(false) true if given coordinates are relative to the
%						screen center 
%
% Out:
%	t	- the amount of time remaining, in milliseconds
% 
% Updated: 2012-12-05
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
persistent optDefault cOptDefault;

%parse the arguments
	if isempty(optDefault)
		optDefault	= struct(...
						'window'		, 'main'	, ...
						'center'		, false		  ...
						);
		cOptDefault	= opt2cell(optDefault);
	end
	
	if nargin<4 || (isnumeric(varargin{1}) && (nargin<5 || (isnumeric(varargin{2}) && nargin<6)))
	%if nargin<6 && (nargin<4 || isnumeric(varargin{1})) && (nargin<5 || isnumeric(varargin{2}))
		opt	= optDefault;
		
		[r,p]	= ParseArgs(varargin,1,[0 0]);
	else
		[r,p,opt]	= ParseArgs(varargin,1,[0 0],cOptDefault{:});
	end

[h,sz]	= shw.parent.Window.Get(opt.window);

%get the background color
	colBack	= shw.parent.Color.Get('background');
%get the size/position of things in pixels
	rPx	= shw.parent.Window.va2px(r);
	pPx	= shw.parent.Window.va2px(p);
	
	if opt.center
		pPx		= pPx + sz/2;
		rect	= [pPx-rPx pPx+rPx];
	else
		rect	= [pPx pPx+2*rPx];
	end
%draw the timer
	t	= tStart+tTotal-PTB.Now;
	fRemain	= max(0,t/tTotal);
	a		= 360-360*fRemain;
	col		= interp1([1;0.5;0],[0 255 0; 255 255 0; 255 0 0],fRemain,'linear');

	Screen('FillOval',h,colBack,rect);
	Screen('FillArc',h,col,rect,a,360-a);
