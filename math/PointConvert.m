function x = PointConvert(x,strFrom,strTo,varargin)
% PointConvert
% 
% Description:	convert coordinates from one coordinate system to another
% 
% Syntax:	x = PointConvert(x,strFrom,strTo,[s])
% 
% In:
% 	x		- a k1 x ... x kN x ND array of points in ND-space
%	strFrom	- the source coordinate system (see Coordinates)
%	strTo	- the destination coordinate system
%	[s]		- if strFrom or strTo are 'matrix' or 'pixel', the size of the
%			  matrix/pixel array-space.
% 
% Out:
% 	x	- the array with points converted to the destination coordinate system
% 
% Updated:	2009-03-29
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.


%if our source and destination spaces are the same, don't do anything
	if isequal(lower(strFrom),lower(strTo))
		return;
	end

%get the step vectors
	s	= size(x);
	
	if numel(s)==2 && isequal(lower(strFrom),'angle')
		nd	= 1;
		nS	= numel(s);
	else
		nd	= s(end);
		s	= s(1:end-1);
	end
	nS	= numel(s);
	
	cStep	= cell(nS,1);
	for kS=1:nS
		cStep{kS}	= 1:s(kS);
	end
%get the size array
	sIn	= ParseArgs(varargin,[]);
	
%convert to cartesian coordinates
	switch lower(strFrom)
		case 'matrix'
			%subtract 1
				x	= x - 1;
			%reverse y
				x(cStep{:},1)	= sIn(1)-x(cStep{:},1)-1;
			%subtract half of the size
				sReshape	= [ones(1,nS) nd];
				sRepmat		= [s 1];
				
				x			= x - repmat(reshape((sIn+1)/2,sReshape),sRepmat)+1;
			%switch x and y
				x	= x(cStep{:},[2 1 3:nd]);
		case 'pixel'
			%subtract half of the size
				sReshape	= [ones(1,nS) nd];
				sRepmat		= [s 1];
				x			= x - repmat(reshape((sIn+1)/2,sReshape),sRepmat);
			%add 1
				x	= x + 1;
			%switch x and y
				x	= x(cStep{:},[2 1 3:nd]);
		case 'cartesian'
		case 'polar'
			r	= x(cStep{:},1);
			a	= x(cStep{:},2);
			clear x;
			
			x	= cat(nS+1,r.*cos(a),r.*sin(a));
		case 'spherical'
			r		= x(cStep{:},1);
			theta	= x(cStep{:},2);
			phi		= x(cStep{:},3);
			clear x;
			
			x	= cat(nS+1,r.*sin(phi).*cos(theta),r.*sin(phi).*sin(theta),r.*cos(phi));
		case 'angle'
			x	= cat(nS+1,cos(x),sin(x));
		case 'radius'
			x	= cat(nS+1,x,repmat(0,s));
		otherwise
			error(['"' strFrom ' is not a recognized coordinate system.']);
	end
	
%convert to the desination coordinates
	switch lower(strTo)
		case 'matrix'
			%switch x and y
				x	= x(cStep{:},[2 1 3:nd]);
			%add half of the size
				sReshape	= [ones(1,nS) nd];
				sRepmat		= [s 1];
				x			= x + repmat(reshape((sIn+1)/2,sReshape),sRepmat)-1;
			%reverse y
				x(cStep{:},1)	= sIn(1)-x(cStep{:},1)-1;
			%add 1
				x	= x + 1;
		case 'pixel'
			%switch x and y
				x	= x(cStep{:},[2 1 3:nd]);
			%add half of the size
				sReshape	= [ones(1,nS) nd];
				sRepmat		= [s 1];
				
				x			= x + repmat(reshape((sIn+1)/2,sReshape),sRepmat);
			%subtract 1
				x	= x - 1;
		case 'cartesian'
		case 'polar'
			y	= x(cStep{:},2);
			x	= x(cStep{:},1);
			
			x	= cat(nS+1,sqrt(x.^2 + y.^2),atan2(y,x));
		case 'spherical'
			z	= x(cStep{:},3);
			y	= x(cStep{:},2);
			x	= x(cStep{:},1);
			
			x	= cat(nS+1,sqrt(x.^2+y.^2+z.^2),atan2(y,x),atan2(sqrt(x.^2+y.^2),z));
		case 'angle'
			x	= atan2(x(cStep{:},2),x(cStep{:},1));
		case 'radius'
			x	= sqrt(sum(x.^2,nS+1));
		otherwise
			error(['"' strTo ' is not a recognized coordinate system.']);
	end
