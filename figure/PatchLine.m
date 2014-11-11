function hP = PatchLine(x,y,w,varargin)
% PatchLine
% 
% Description:	draw a series of connected line segment patches
% 
% Syntax:	hP = PatchLine(x,y,w,<options>)
% 
% In:
% 	x	- the x values of the line segment control points
%	y	- the y values of the line segment control points
%	w	- the width of the line, in axes units, or an array of widths, one for
%		  each line
%	<options>:
%		ha:		(<gca>) the handle of the axes to use
%		color:	([0 0 0]) the line color
%		alpha:	(1) the transparency (0->1)
% 
% Out:
% 	hP	- the handle to the line patch
% 
% Updated: 2011-03-15
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgs(varargin,...
		'ha'			, []		, ...
		'color'			, [0 0 0]	, ...
		'alpha'			, 1			  ...
		);

if isempty(opt.ha)
	opt.ha	= gca;
elseif ~isequal(gca,opt.ha)
	axes(opt.ha);
end

[x,y,w]	= varfun(@(v) reshape(v,[],1),x,y,w);
nPoint	= numel(x);

rLine	= repto(w/2,[nPoint-1 1]);

%equation for each line segment
	mSeg	= (y(2:end)-y(1:end-1))./(x(2:end)-x(1:end-1));
%offset of each inner and outer line from the center
	%angle of each line segment
		aSeg		= atan2(y(2:end)-y(1:end-1),x(2:end)-x(1:end-1));
	
	p1	= PointConvert([rLine aSeg+pi/2],'polar','cartesian');
	p2	= PointConvert([rLine aSeg-pi/2],'polar','cartesian');
	
	x1Off	= x(1:end-1) + p1(:,1);
	y1Off	= y(1:end-1) + p1(:,2);
	x2Off	= x(1:end-1) + p2(:,1);
	y2Off	= y(1:end-1) + p2(:,2);
%get an equation for each inner and outer line
	[b1Seg,b2Seg]	= deal(NaN(nPoint-1,1));
	
	bFinite	= ~isinf(mSeg);
	
	b1Seg(bFinite)	= y1Off(bFinite) - x1Off(bFinite).*mSeg(bFinite);
	b2Seg(bFinite)	= y2Off(bFinite) - x2Off(bFinite).*mSeg(bFinite);
	
	b1Seg(~bFinite)	= x1Off(~bFinite);
	b2Seg(~bFinite)	= x2Off(~bFinite);
%get the position of each inner and outer line point
	%end points
		[x1,x2,y1,y2]	= deal(zeros(nPoint,1));
		
		x1([1 end])	= x([1 end]) + p1([1 end],1);
		y1([1 end])	= y([1 end]) + p1([1 end],2);
		x2([1 end])	= x([1 end]) + p2([1 end],1);
		y2([1 end])	= y([1 end]) + p2([1 end],2);
	%inner points are the intersections of the inner/outer line segments
		[x1(2:end-1),y1(2:end-1)]	= LineIntersection(mSeg(1:end-1),b1Seg(1:end-1),mSeg(2:end),b1Seg(2:end));
		[x2(2:end-1),y2(2:end-1)]	= LineIntersection(mSeg(1:end-1),b2Seg(1:end-1),mSeg(2:end),b2Seg(2:end));
%draw the patch
	hP	= patch([x1;x2(end:-1:1)],[y1;y2(end:-1:1)],opt.color,'LineStyle','none');
%set the transparency
	%set(hP,'FaceVertexAlphaData',opt.alpha,'FaceAlpha','flat');
	set(hP,'FaceAlpha',opt.alpha);
