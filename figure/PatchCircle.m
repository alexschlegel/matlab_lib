function hP = PatchCircle(x,y,r,varargin)
% PatchCircle
% 
% Description:	draw a circle patch on an axes
% 
% Syntax:	hP = PatchCircle(x,y,r,<options>)
% 
% In:
% 	x	- the x value of the circle center
%	y	- the y value of the circle center
%	r	- the radius of the circle
%	<options>:
%		ha:				(<gca>) the handle of the axes to use
%		color:			([0 0 0]) the circle color
%		alpha:			(1) the transparency (0->1)
%		borderwidth:	(1) the width of the border
%		bordercolor:	([0 0 0]) the color of the border
%		nstep:			(100) the number of vertices to use
% 
% Out:
% 	hP	- the handle to the circle patch
% 
% Updated: 2011-03-15
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgs(varargin,...
		'ha'			, []		, ...
		'color'			, [0 0 0]	, ...
		'alpha'			, 1		, ...
		'borderwidth'	, 1			, ...
		'bordercolor'	, [0 0 0]	, ...
		'nstep'			, 100		  ...
		);

if isempty(opt.ha)
	opt.ha	= gca;
elseif ~isequal(gca,opt.ha)
	axes(opt.ha);
end

%get the vertex coordinates
	a	= reshape(GetInterval(0,2*pi,opt.nstep+1),[],1);
	a	= a(1:end-1);
	
	p	= PointConvert([repmat(r,[opt.nstep 1]) a],'polar','cartesian');
%draw the patch
	cBorder	= conditional(opt.borderwidth==0,{'LineStyle','none'},{'LineWidth',opt.borderwidth});
	
	hP	= patch(p(:,1)+x,p(:,2)+y,opt.color,cBorder{:},'EdgeColor',opt.bordercolor);
%set the transparency
	%set(hP,'FaceVertexAlphaData',opt.alpha,'EdgeAlpha','flat','FaceAlpha','flat');
	set(hP,'FaceAlpha',opt.alpha);
