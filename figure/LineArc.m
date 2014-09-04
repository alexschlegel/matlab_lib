function hL = LineArc(x,y,r,a1,a2,w,varargin)
% LineArc
% 
% Description:	draw an arc line on an axes
% 
% Syntax:	hP = LineArc(x,y,r,a1,a2,w,<options>)
% 
% In:
% 	x	- the x value of the circle center
%	y	- the y value of the circle center
%	r	- the radius of the circle
%	a1	- the first angle endpoint of the arc, in radians
%	a2	- the second angle endpoint of the arc, in radians
%	w	- the thickness of the arc
%	<options>:
%		ha:				(<gca>) the handle of the axes to use
%		color:			([0 0 0]) the arc color
%		nstep:			(100) the number of vertices to use
% 
% Out:
% 	hP	- the handle to the arc patch
% 
% Updated: 2014-05-13
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgs(varargin,...
		'ha'			, []		, ...
		'color'			, [0 0 0]	, ...
		'nstep'			, 100		  ...
		);

if isempty(opt.ha)
	opt.ha	= gca;
elseif ~isequal(gca,opt.ha)
	axes(opt.ha);
end

%get the line coordinates
	a	= reshape(GetInterval(a1,a2,opt.nstep),[],1);
	
	p	= PointConvert([repmat(r,[opt.nstep 1]) a],'polar','cartesian');
	
	xArc		= x + p(:,1);
	yArc		= y + p(:,2);
%draw the patch
	hL	= line(xArc,yArc,'Color',opt.color,'LineWidth',w);
