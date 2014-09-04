function a = AngleFromPoint(p,varargin)
% ANGLEFROMPOINT
% 
% Description:	returns the angle between a set of points and a center point
% 
% Syntax:	a = AngleFromPoint(p,[pC]=[0 0])
%
% In:
%	p		- an Nx2 array of points
%	[pC]	- a 1x2 array specifying the center point
% 
% Out:
%	a	- an Nx1 array of angles between p and pC
%
% Copyright 2006 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
pC	= ParseArgs(varargin,[0 0]);

nP	= size(p,1);
p	= repmat(pC,[nP 1]) - p;

a	= atan2(p(:,1),p(:,2));
