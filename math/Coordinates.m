function varargout = Coordinates(s,varargin)
% Coordinates
% 
% Description:	return an array of coordinates
% 
% Syntax:	x = Coordinates(s,[strSystem]='matrix',[pOrigin]=<see below>) OR
%			[x1,...,xND] = ...
% 
% In:
%	s			- the size of space
%	[strSystem]	- the coordinate system to use-
%					'matrix'	- row/column/etc. index values
%					'pixel'		- top/left index values (dimensions beyond the
%								  first are numbered as in 'matrix', but are
%								  zero-based)
%					'cartesian'	- (x,y,...) coordinates w.r.t. the origin
%					'polar'		- r/theta w.r.t. the origin, for 2D matrices
%								  only
%					'spherical'	- r/theta/phi w.r.t the origin.  theta is the
%								  counter-clockwise angle from the positive
%								  x-axis and phi is the downward angle from the
%								  positive z-axis.  3D matrices only
%					'radius'	- radius w.r.t. the origin
%					'angle'		- polar coordinate theta values w.r.t. the
%								  origin, for 2D matrices only
%	[pOrigin]	- an N-length array specifying the array coordinate position to
%				  treat as the origin.  defaults:
%					'matrix'		- [1 ... 1]
%					'pixel'			- [s(1) 1 ... 1]
%					otherwise		- <center of matrix>
% 
% Out:
% 	x	- an s1 x ... x sN x N matrix of the specified coordinates
%	xK	- the Kth dimension's coordinates
% 
% Example:	x = Coordinates(11,'angle');
%			x = Coordinates([10 20 30],'spherical',[10 1 1]);
%			[x,y] = Coordinates([100 100],'cartesian');
% 
% Updated:	2009-03-31
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
[strSystem,pOrigin]	= ParseArgs(varargin,'matrix',[]);

%get the size of the array
	if numel(s)==1
		s	= [s s];
	end
	nd	= numel(s);
%get the origin
	if isempty(pOrigin)
		switch lower(strSystem)
			case 'matrix'
				pOrigin	= ones(1,nd);
			case 'pixel'
				pOrigin	= [s(1) ones(1,nd-1)];
			otherwise
				pOrigin	= (s+1)/2;
		end
	end
%get the equivalent origin in our matrix space
	switch lower(strSystem)
		case 'matrix'
		case 'pixel'
			pOrigin(1)	= pOrigin(1) - s(1) + 1;
		otherwise
			pOrigin		= pOrigin - (s+1)/2 + 1;
	end
%get the step vectors
	cStep	= cell(nd,1);
	for kd=1:nd
		cStep{kd}	= 1:s(kd);
	end
%get the matrix coordinates
	x	= zeros([s nd]);
	
	for kd=1:nd
		sReshape		= ones(1,nd);
		sReshape(kd)	= s(kd);
		sRepmat			= s;
		sRepmat(kd)		= 1;
		
		x(cStep{:},kd)	= repmat(reshape(1:s(kd),sReshape),sRepmat);
	end
%shift by the origin
	sReshape	= [ones(1,nd) nd];
	sRepmat		= [s 1];
	x			= x - repmat(reshape(pOrigin,sReshape),sRepmat)+1;

%now convert to out output system
	x	= PointConvert(x,'matrix',strSystem,s);

%optionally split up the dimensions
	if nargout>1
		for k=1:nargout
			varargout{k}	= x(cStep{:},k);
		end
	else
		varargout{1}	= x;
	end
	