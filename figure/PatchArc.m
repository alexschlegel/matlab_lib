function hP = PatchArc(x,y,r,a1,a2,w,varargin)
% PatchArc
% 
% Description:	draw an arc patch on an axes
% 
% Syntax:	hP = PatchArc(x,y,r,a1,a2,w,<options>)
% 
% In:
% 	x	- the x value of the circle center
%	y	- the y value of the circle center
%	r	- the radius of the circle
%	a1	- the first angle endpoint of the arc, in radians
%	a2	- the second angle endpoint of the arc, in radians
%	w	- the thickness of the arc, in axes units
%	<options>:
%		ha:				(<gca>) the handle of the axes to use
%		color:			([0 0 0]) the arc color
%		alpha:			(1) the transparency (0->1)
%		nstep:			(100) the number of vertices to use
% 
% Out:
% 	hP	- the handle to the arc patch
% 
% Updated: 2011-03-15
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgs(varargin,...
		'ha'			, []		, ...
		'color'			, [0 0 0]	, ...
		'alpha'			, 1			, ...
		'nstep'			, 100		  ...
		);

if isempty(opt.ha)
	opt.ha	= gca;
elseif ~isequal(gca,opt.ha)
	axes(opt.ha);
end

%get the inner and outer vertex coordinates
	a	= reshape(GetInterval(a1,a2,opt.nstep),[],1);
	
	pIn		= PointConvert([repmat(r-w/2,[opt.nstep 1]) a],'polar','cartesian');
	pOut	= PointConvert([repmat(r+w/2,[opt.nstep 1]) a],'polar','cartesian');
	
	xIn		= x + pIn(:,1);
	yIn		= y + pIn(:,2);
	xOut	= x + pOut(:,1);
	yOut	= y + pOut(:,2);
%draw the patch
	hP	= patch([xIn; xOut(end:-1:1)],[yIn; yOut(end:-1:1)],opt.color,'LineStyle','none');
%set the transparency
	%set(hP,'FaceVertexAlphaData',opt.alpha,'FaceAlpha','flat');
	set(hP,'FaceAlpha',opt.alpha);
