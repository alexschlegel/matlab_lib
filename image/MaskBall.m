function b = MaskBall(r)
% MaskBall
% 
% Description:	construct an n-dimensional ball mask
% 
% Syntax:	b = MaskBall(r)
% 
% In:
% 	r	- the radius in each dimension
% 
% Out:
% 	b	- the mask
% 
% Updated: 2012-04-11
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
nd	= numel(r);

d	= 2*round(r)+1;

%get the radius of each point
	vD	= arrayfun(@(d) GetInterval(-1,1,d)',d,'UniformOutput',false);
	
	if nd>1
		cX		= cell(nd,1);
		[cX{:}]	= ndgrid(vD{:});
	else
		cX	= vD;
	end
	
	cX2		= cellfun(@(x) x.^2,cX,'UniformOutput',false);
	
	rND	= sqrt(sum(cat(nd+1,cX2{:}),nd+1));
%get the mask
	b	= rND<=1;