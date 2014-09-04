function stl = STLReduce(stl,r)
% STLReduce
% 
% Description:	reduce the number of triangles in an STL object
% 
% Syntax:	stl = STLReduce(stl,r)
% 
% In:
% 	stl	- an STL object
%	r	- same as input to reducepatch
% 
% Out:
% 	stl	- the stl with triangles reduced
% 
% Updated:	2009-06-07
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

%get the vertices
	v	= permute(stl.Vertex,[3 2 1]);
	v	= reshape(v,3,[])';
	nV	= size(v,1);
%get the faces
	f	= reshape(1:nV,3,[])';
	
	
%reduce
	[f,v]	= reducepatch(f,v,r);
	nF		= size(f,1);
	nV		= size(v,1);
	
%reconstruct
	f		= repmat(f,[1 1 3]);
	kV		= repmat(reshape(1:3,1,1,3),[nF 3 1]);
	
	k	= sub2ind([nV 3],f,kV);
	
	stl.Vertex	= v(k);
%recalculate normals
	stl	= STLRecalcNormals(stl);
