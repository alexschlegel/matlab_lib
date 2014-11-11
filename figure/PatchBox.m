function hP = PatchBox(x,y,w,h,varargin)
% PatchBox
% 
% Description:	draw a box patch on an axes
% 
% Syntax:	hP = PatchBox(x,y,w,h,[a]=0,<options>)
% 
% In:
% 	x	- the x value of the box center
%	y	- the y value of the box center
%	w	- the width of the box
%	h	- the height of the box
%	[a]	- the angle at which to rotate the box, in radians
%	<options>:
%		ha:				(<gca>) the handle of the axes to use
%		color:			([0 0 0]) the box color
%		alpha:			(1) the transparency (0->1)
%		borderwidth:	(1) the width of the border
%		bordercolor:	([0 0 0]) the color of the border
% 
% Out:
% 	hP	- the handle to the box patch
% 
% Updated: 2011-03-15
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
[a,opt]	= ParseArgs(varargin,0,...
			'ha'			, []		, ...
			'color'			, [0 0 0]	, ...
			'alpha'			, 1			, ...
			'borderwidth'	, 1			, ...
			'bordercolor'	, [0 0 0]	  ...
			);

if isempty(opt.ha)
	opt.ha	= gca;
elseif ~isequal(gca,opt.ha)
	axes(opt.ha);
end

%get the relative vertex points
	p	=	[	-w/2	-h/2
				-w/2	h/2
				w/2		h/2
				w/2		-h/2
			];
%rotate
	if a~=0
		p	= RotatePoints(p,a);
	end
%translate by the box center
	p	= p + repmat([x y],[4 1]);

%draw the patch
	cBorder	= conditional(opt.borderwidth==0,{'LineStyle','none'},{'LineWidth',opt.borderwidth});
	
	hP	= patch(p(:,1),p(:,2),opt.color,cBorder{:},'EdgeColor',opt.bordercolor);
%set the transparency
	%set(hP,'FaceVertexAlphaData',opt.alpha,'EdgeAlpha','flat','FaceAlpha','flat');
	set(hP,'FaceAlpha',opt.alpha,'EdgeAlpha',opt.alpha);
