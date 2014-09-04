function stl = bvSRF2STL(srf,varargin)
% bvSRF2STL
% 
% Description:	convert the triangles and vertices of an SRF to an STL struct
% 
% Syntax:	stl = bvSRF2STL(srf,[strHeader]=[<input name> 'SRF2STL'])
% 
% In:
% 	srf	- an SRF loaded with BVQXfile
% 
% Out:
% 	stl	- SRF as an STL struct (see STLRead)
% 
% Updated:	2009-04-07
% Copyright 2009 Alex Schlegel (alex@roguecheddar.com).  All Rights Reserved.
[strHeader]	= ParseArgs(varargin,[]);

%get the header
	if isempty(strHeader);
		strHeader	= 'SRF2STL';
		
		strIn	= inputname(1);
		if ~isempty(strIn)
			strHeader	= [strIn ' ' strHeader];
		end
	end
	
%initialize the STL struct
	stl	= STLNew(strHeader);

%get the indices of the vertices for each triangle
	nTriangle	= srf.NrOfTriangles;
	nVertex		= srf.NrOfVertices;
	
	kVertex		= repmat(srf.TriangleVertex,[1 1 3]);
	kInVertex	= repmat(reshape(1:3,1,1,3),[nTriangle 3 1]);
	
	kVertex		= sub2ind([nVertex 3],kVertex,kInVertex);
	
	clear kInVertex;

%get each vertex coordinate
	stl.Vertex		= zeros(nTriangle,3,3);
	stl.Vertex(:)	= srf.VertexCoordinate(kVertex);
	
	%subtract by the mesh center
		stl.Vertex	= stl.Vertex - repmat(reshape(srf.MeshCenter,[1 1 3]),[nTriangle 3 1]);
		
	%switch y and z (BVQX's internal function does this
		stl.Vertex	= stl.Vertex(:,[1 3 2],:);
	%flip the third coordinate
		stl.Vertex(:,:,3)	= -stl.Vertex(:,:,3);
	
%get each facet normal as a vector perpendicular to the facet
	%cross product of two vectors in the facet plane
		stl.Normal	= cross(stl.Vertex(:,3,:)-stl.Vertex(:,1,:),stl.Vertex(:,2,:)-stl.Vertex(:,1,:),3);
		stl.Normal	= squeeze(permute(stl.Normal,[1 3 2]));
	%normalize
		stl.Normal	= stl.Normal./repmat(sqrt(sum(stl.Normal.^2,2)),[1 3]);
		