function h = star(hA,x,y,varargin)
% star
% 
% Description:	add a star to a plot
% 
% Syntax:	h = star(hA,x,y,<options>)
% 
% In:
% 	hA	- the handle to an axes
%	x	- the x-location of the star center, in data units
%	y	- the y-location of the star center, in data units
%	<options>:
%		color:		([0 0 0]) the star color
%		radius:		(0.05) the normalize star radius
%		points:		(5) the number of points in the star
%		thickness:	(1) the line width
% 
% Out:
% 	h	- an array of handles to the lines that comprise the star
% 
% Updated: 2013-07-25
% Copyright 2013 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'color'		, [0 0 0]	, ...
		'radius'	, 0.01		, ...
		'points'	, 5			, ...
		'thickness'	, 1			  ...
		);

%get the star radii in data units
	xLim	= get(hA,'XLim');
	yLim	= get(hA,'YLim');
	
	rX	= opt.radius*diff(xLim);
	rY	= opt.radius*diff(yLim);
%get the star line start and end points
	aStep	= 2*pi/opt.points;
	a		= pi/2 + (0:aStep:2*pi-aStep);
	
	sX	= repmat(x,[1 opt.points]);
	sY	= repmat(y,[1 opt.points]);
	
	eX	= x + rX*cos(a);
	eY	= y + rY*sin(a);
	
	pX	= [sX; eX];
	pY	= [sY; eY];
%draw the star lines
	h	= line(pX,pY,'Color',opt.color,'LineWidth',opt.thickness);

%make sure we didn't screw up the plot limits
	set(hA,'XLim',xLim,'YLim',yLim);
