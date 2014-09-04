function p = RotatePoints(p,varargin)
% RotatePoints
% 
% Description:	rotate points in N-space
% 
% Syntax:	p = RotatePoints(p,x,y,theta) OR
%			p = RotatePoints(p(2-space),theta) OR
%			p = RotatePoints(p(3-space),thetaXY,thetaYZ,thetaXZ)
% 
% In:
% 	p				- an MxN array of M N-dimensional points
%	x,y				- rotate in the plane defined by N x 1 vectors x and y
%	theta			- the angle through which to rotate the points in p, in
%					  radians (positive angle is a counter-clockwise rotation)
%	thetaXY/YZ/XZ	- if M==3, then one angle for rotations about each of the z,
%					  x, and y axes, in radians (rotates points in that order)
% 
% Out:
% 	p	- p rotated as specified
% 
% Notes:	Rotation equation taken from
%			http://quickfur.ath.cx:8080/~hsteoh/math/genrot.pdf.
%
% Updated:	2009-08-03
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
[nPoint,nd]	= size(p);

switch nd
	case 3
		if numel(varargin{1})==1	%three angles
			[thetaXY,thetaYZ,thetaXZ]	= deal(varargin{1:3});
			
			p	= RotatePoints(p,[1;0;0],[0;1;0],thetaXY);
			p	= RotatePoints(p,[0;1;0],[0;0;1],thetaYZ);
			p	= RotatePoints(p,[1;0;0],[0;0;1],thetaXZ);
			
			return;
		else
			[x,y,theta]	= deal(varargin{1:3});
		end
	case 2
		if nargin==2
			x		= [1;0];
			y		= [0;1];
			theta	= varargin{1};
		else
			[x,y,theta]	= deal(varargin{1:3});
		end
	otherwise
		[x,y,theta]	= deal(varargin{1:3});
end

x	= repmat(x',[nPoint 1]);
y	= repmat(y',[nPoint 1]);
pdx	= repmat(dot(p,x,2),[1 nd]);
pdy	= repmat(dot(p,y,2),[1 nd]);
ct	= cos(theta);
st	= sin(theta);
p	= p + (pdx*(ct-1)-pdy*st).*x + (pdy*(ct-1)+pdx*st).*y;
