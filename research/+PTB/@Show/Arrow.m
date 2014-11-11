function Arrow(shw,col,p1,p2,varargin)
% PTB.Show.Arrow
% 
% Description:	show an arrow
% 
% Syntax:	shw.Arrow(col,p1,p2,[t]=1/6,[lHead1]=0,[lHead2]=1,<options>)
% 
% In:
%	col			- the arrow color (see PTB.Color)
%	p1			- the (x,y) coordinates of the arrow starting point, in degrees
%				  of visual angle
%	p2			- the (x,y) coordinates of the arrow ending point, in degrees of
%				  visual angle
%	[t]			- the thickness of the line, in degrees of visual angle
%	[lHead1]	- the length of the line segments for the arrow head at the start
%				  of the line, in degrees of visual angle
%	[lHead2]	- the length of the line segments for the arrow head at the end
%				  of the line, in degrees of visual angle
%	<options>:
%		window:			('main') the name of the window on which to show the
%						image
%		center:			(true) true if given coordinates are relative to the
%						screen center
%		border:			(false) true to show a border around the image
%		border_color:	('black') the border color
%		border_size:	(1/6) the border thickness, in degrees of visual angle
% 
% Updated: 2012-05-27
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
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
	
	if nargin<5 || (isnumeric(varargin{1}) && (nargin<6 || (isnumeric(varargin{2}) && (nargin<7 || (isnumeric(varargin{3}) && nargin<8)))))
		opt		= optDefault;
		cOpt	= cOptDefault;
		
		[t,lHead1,lHead2]	= ParseArgs(varargin,1/6,0,1);
	else
		[t,lHead1,lHead2,opt]	= ParseArgs(varargin,1/6,0,1,cOptDefault{:});
		cOpt	= opt2cell(opt);
	end

[h,sz]	= shw.parent.Window.Get(opt.window);

%show the line segment
	shw.Line(col,p1,p2,t,cOpt{:});
%show the arrow heads
	aLine	= atan2(p2(2)-p1(2),p2(1)-p1(1));
	aHead	= pi/3;
	
	if lHead1>0
		pHead11	= p1 + lHead1.*[cos(aLine+aHead/2) sin(aLine+aHead/2)];
		pHead12	= p1 + lHead1.*[cos(aLine-aHead/2) sin(aLine-aHead/2)];
		
		p1Head1	= p1;
		p1Head2	= p1;
		
		shw.Line(col,p1Head1,pHead11,t,cOpt{:});
		shw.Line(col,p1Head2,pHead12,t,cOpt{:});
	end
	
	if lHead2>0
		pHead21	= p2 + lHead2.*[cos(aLine-pi+aHead/2) sin(aLine-pi+aHead/2)];
		pHead22	= p2 + lHead2.*[cos(aLine+pi-aHead/2) sin(aLine+pi-aHead/2)];
		
		%aHead21		= atan2(pHead21(2)-p2(2),pHead21(1)-p2(1));
		%offset21	= t/2*[cos(aHead21+pi/2) sin(aHead21+pi/2)];
		%p2Head21	= p2 - offset21;
		%pHead21		= pHead21 - offset21;
		
		p2Head1	= p2;
		p2Head2	= p2;
		
		shw.Line(col,p2Head1,pHead21,t,cOpt{:});
		shw.Line(col,p2Head2,pHead22,t,cOpt{:});
	end
