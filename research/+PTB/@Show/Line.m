function Line(shw,col,p1,p2,varargin)
% PTB.Show.Line
% 
% Description:	show a line
% 
% Syntax:	shw.Line(col,p1,p2,[t]=1/6,<options>)
% 
% In:
%	col	- the line color (see PTB.Color)
%	p1	- the (x,y) coordinates of the line starting point, in degrees of visual
%		  angle
%	p2	- the (x,y) coordinates of the line ending point, in degrees of visual
%		  angle
%	[t]	- the thickness of the line, in degrees of visual angle
%	<options>:
%		window:			('main') the name of the window on which to show the
%						image
%		center:			(true) true if given coordinates are relative to the
%						screen center
%		border:			(false) true to show a border around the image
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
	
	if nargin<5 || (isnumeric(varargin{1}) && nargin<6)
	%if nargin<6 && (nargin<5 || isnumeric(varargin{1}))
		opt		= optDefault;
		cOpt	= cOptDefault;
		
		t	= ParseArgs(varargin,1/6);
	else
		[t,opt]	= ParseArgs(varargin,1/6,cOptDefault{:});
		cOpt	= opt2cell(opt);
	end

[h,sz]	= shw.parent.Window.Get(opt.window);

%parse the color
	col	= shw.parent.Color.Get(col);

if ~opt.center
	p1Px	= shw.parent.Window.va2px(p1);
	p2Px	= shw.parent.Window.va2px(p2);
	
	p1		= shw.parent.Window.px2va(p1Px - sz/2);
	p2		= shw.parent.Window.px2va(p2Px - sz/2);
end

len	= sqrt(sum((p1 - p2).^2));
ar	= -atan2(p2(1)-p1(1),p2(2)-p1(2));
a	= r2d(ar);

if ~opt.center
	p1Px	= shw.parent.Window.va2px(p1);
	p2Px	= shw.parent.Window.va2px(p2);
	tPx		= shw.parent.Window.va2px(t);
	
	pPx	= (p1Px+p2Px)/2 + tPx/2.*[cos(ar) sin(ar)];
	p	= shw.parent.Window.px2va(pPx);
else
	p	= (p1+p2)/2;
end

shw.Rectangle(col,[t len],p,a,cOpt{:},'center',true);
