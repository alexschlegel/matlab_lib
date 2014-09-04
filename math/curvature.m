function c = curvature(x,y,varargin)
% curvature
% 
% Description:	estimate the curvature of a contour, given its x and y
%				coordinates
% 
% Syntax:	c = curvature(x,y,[nEst]=10,[xCenter]=0,[yCenter]=0)
%
% In:
%	x			- an Nx1 array of x values
%	y			- an Nx1 array of y values
%	[nEst]		- the number of point to include in each curvature calculation
%	[xCenter]	- the x-value of the center point from which to judge curvature
%				  sign
%	[yCenter]	- the y-value of the center
%
% Out:
%	c	- an Nx1 array of the curvature estimate at each point
% 
% Notes: uses code given by Roger Stafford here:
%	http://www.mathworks.com/matlabcentral/newsreader/view_thread/152405
% 
% Updated: 2012-06-04
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
warning('off','MATLAB:rankDeficientMatrix');

[nEst,xCenter,yCenter]	= ParseArgs(varargin,10,0,0);

nPoint	= numel(x);

%get the starting and ending index of each estimation
	kStart	= max(1,(1:nPoint) - floor(nEst/2))';
	kEnd	= min(nPoint,kStart + nEst-1);
	
	nDiff			= kEnd-kStart+1;
	bEnd			= nDiff<nEst;
	kStart(bEnd)	= kEnd(bEnd)-nEst+1;
%calculate the curvature
	[c,xC,yC]	= arrayfun(@(s,e) curvature_point(x(s:e),y(s:e)),kStart,kEnd);
%mark curvature sign based on whether the distance from the best fit circle
%center to the reference center is larger or smaller than the from the point to
%the reference center
	dPoint2		= (x-xCenter).^2 + (y-yCenter).^2;
	dCircle2	= (xC-xCenter).^2 + (yC-yCenter).^2;
	
	c	= c.*(2*(dPoint2>dCircle2)-1);


%------------------------------------------------------------------------------%
function [c,xC,yC] = curvature_point(x,y)
	%means
		mX	= mean(x);
		mY	= mean(y);
	%differences from means
		dX	= x - mX;
		dY	= y - mY;
	%variances
		varX	= mean(dX.^2);
		varY	= mean(dY.^2);
	%solve the least mean squares problem
		t	= [dX,dY]\(dX.^2-varX+dY.^2-varY)/2;
	%t is the 2 x 1 solution array [a0;b0]
		a0	= t(1);
		b0	= t(2); 
	%calculate the radius
		r	= sqrt(varX+varX+a0^2+b0^2);
	%locate the circle's center
		xC	= a0 + mX;
		yC	= b0 + mY;
	%curvature
		c	= 1/r;
end
%------------------------------------------------------------------------------%

end
