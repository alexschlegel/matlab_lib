function srf = bvGIfTI2SRF(varargin)
% bvGIfTI2SRF
% 
% Description:	convert a GIfTI surface to an SRF
% 
% Syntax:	srf = bvGIfTI2SRF(strPathGIfTI,[bTranslate]=true,[bReorder]=true,[bInsideOut]=false) OR
%			srf = bvGIfTI2SRF(gii,...)
% 
% In:
% 	strPathGIfTI	- the path to the GIfTI .gii file containing the surface
%					  data
%	gii				- an SPM8 gifti object
%	[bTranslate]	- true to translate the surface by the mesh center
%	[bReorder]		- true to reorder the coordinates from the space used by
%					  FreeSurfer to that used by BVQX
%	[bInsideOut]	- true to reverse the order of triangle vertices so BVQX
%					  correctly identifies the exterior of the surface
% 
% Out:
% 	srf	- a BVQXtools SRF object of the surface
%
% Notes:	requires SPM8 and BVQXtools to be in the path
%			
%			This was tested with the bert data set in FreeSurfer ver. 4.3.0
%			converted to GIfTI using mris_convert.
% 
% Updated:	2009-05-14
% Copyright 2009 Alex Schlegel (alex@roguecheddar.com).  All Rights Reserved.
[gii,bTranslate,bReorder,bInsideOut]	= ParseArgs(varargin,[],true,true,false);


%get the faces/vertices
	if ischar(gii)
		strPathGIfTI	= gii;
		
		gii	= gifti(strPathGIfTI);
	end
	
%create the new SRF
	srf	= bless(emptysrf);
	
	%make faces opaque
		srf.ConvexRGBA(4)	= 1;
		srf.ConcaveRGBA(4)	= 1;
	
%transfer the surface
	%number of vertices and triangles
		nV	= size(gii.vertices,1);
		nF	= size(gii.faces,1);
		
		srf.NrOfVertices		= nV;
		srf.NrOfTriangles		= nF;
	
	%vertex info
		%vertex coordinates (shift by the mesh center)
			srf.VertexCoordinate	= double(gii.vertices);
		%optionally reorder the coordinates
			if bReorder
				%in original space:
				%	1: left-right (or vice-versa)
				%	2: posterior-anterior (or vice versa)
				%	3: inferior-superior (or vice versa)
				%in BV space:
				%	1: PA (opposite direction from orig)
				%	2: IS (opposite orig)
				%	3: LR (opposite orig)
				
				srf.VertexCoordinate	= -srf.VertexCoordinate(:,[2 3 1]);
				%srf.VertexCoordinate(:,2)	= -srf.VertexCoordinate(:,2);
				%srf.VertexCoordinate(:,3)	= -srf.VertexCoordinate(:,3);
			end
		%optionally translate by the mesh center
			if bTranslate
				srf.VertexCoordinate	= srf.VertexCoordinate + repmat(srf.MeshCenter,[nV 1]);
			end
		%default mesh coloring
			srf.VertexColor			= zeros(nV,4);
			
	%face info
		srf.TriangleVertex		= double(gii.faces);
	%optionally reverse the vertex list so BrainVoyager correctly computes the
	%"outside" of the faces
		if bInsideOut
			srf.TriangleVertex	= srf.TriangleVertex(:,end:-1:1);
		end
	
	%get the neighbor info
		try
			srf.Neighbors	= srf.TrianglesToNeighbors;
		catch
			srf.TriangleVertex	= srf.TriangleVertex(:,end:-1:1);
			srf.Neighbors		= srf.TrianglesToNeighbors;
			srf.TriangleVertex	= srf.TriangleVertex(:,end:-1:1);
		end
	
	%calculate vertex normals
		srf.RecalcNormals;
