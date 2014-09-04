function h = STLShow(stl)
% STLShow
% 
% Description:	show the specified STL object as a patch
% 
% Syntax:	h = STLShow(stl)
% 
% In:
% 	stl	- an STL object
% 
% Out:
% 	h	- a handle the patch
% 
% Updated:	2009-06-07
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

%get the vertices
	v	= permute(stl.Vertex,[3 2 1]);
	v	= reshape(v,3,[])';
	nV	= size(v,1);
%get the faces
	f	= reshape(1:nV,3,[])';

%show it!
	h	= trisurf(f,v(:,1),v(:,2),v(:,3),0.5);
	daspect([1 1 1]);
	view(3);
	camlight;
	lighting phong;
