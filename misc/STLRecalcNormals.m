function stl = STLRecalcNormals(stl)
% STLRecalcNormals
% 
% Description:	recalculate the normals for an STL object
% 
% Syntax:	stl = STLRecalcNormals(stl)
% 
% Updated:	2009-06-07
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

%get vectors along each face
	v1	= permute(stl.Vertex(:,2,:) - stl.Vertex(:,1,:),[1 3 2]);
	v2	= permute(stl.Vertex(:,3,:) - stl.Vertex(:,2,:),[1 3 2]);
%calculate the cross product (i.e. in direction of normal vector)
	n	= cross(v1,v2,2);
%normalize
	M			= repmat(sqrt(sum(n.^2,2)),[1 3]);
	stl.Normal	= n ./ M;
