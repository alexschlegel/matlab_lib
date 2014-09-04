function srf = bvSPM2SRF(varargin)
% bvSPM2SRF
% 
% Description:	convert a surface created in SPM to an SRF
% 
% Syntax:	srf = bvSPM2SRF(strPathSPMSurf) OR
%			srf = bvSPM2SRF(vertices,faces)
% 
% In:
% 	strPathSPMSurf	- the path to the SPM .mat file containing the surface data
%	vertices/faces	- the two variables stored in the SPM .mat file
% 
% Out:
% 	srf	- a BVQXtools SRF object of the surface
% 
% Updated:	2009-04-10
% Copyright 2009 Alex Schlegel (alex@roguecheddar.com).  All Rights Reserved.

%get the faces/vertices
	if ischar(varargin{1})
		strPathSPMSurf	= varargin{1};
		
		s	= load(strPathSPMSurf);
	else
		s.vertices	= varargin{1};
		s.faces		= varargin{2};
	end
	
%create the new SRF
	srf	= bless(BVQXfile('new:srf'));
	
%transfer the surface
	srf.NrOfVertices		= size(s.vertices,1);
	srf.NrOfTriangles		= size(s.faces,1);	
	srf.VertexCoordinate	= s.vertices;
	srf.VertexColor			= zeros(srf.NrOfVertices,4);
	srf.TriangleVertex		= s.faces;
	
	SetNeighbors(srf);
	
	srf.RecalcNormals;

%------------------------------------------------------------------------------%
function SetNeighbors(srf)
%set the Neighbors field of the given SRF.  srf.TrianglesToNeighbors can't
%handle the fact that vertices from SPM surfaces can connect to more than six
%other vertices, so we have to do it ourselves
	
	%get the triangles on which each vertex appears
		%sort the vertices in the triangle array
			[vSort,k]			= sort(srf.TriangleVertex(:));
			nBelong				= numel(k);
			[kTriangle,kVertex]	= ind2sub([srf.NrOfTriangles 3],k);
		%get the start and stop index at which each vertex appears
			vStart		= find(vSort(1:end) - [0;vSort(1:end-1)] ~= 0);
			vEnd		= [vStart(2:end)-1; numel(vSort)];
		%number of triangles in which each vertex appears
			nTriangle	= vEnd - vStart + 1;
			
	%get the neighbor indices for each vertex
		vTriangle	= srf.TriangleVertex(kTriangle,:);
	%delete the vertex in question from each triangle
		vTriangle			= vTriangle';
		kDelete				= sub2ind([3 nBelong],kVertex,(1:nBelong)');
		vTriangle(kDelete)	= [];
		vTriangle			= reshape(vTriangle,2,[])';
	
	%pair each vertex with its neighbors
		kPair	= [vSort vTriangle(:,1); vSort vTriangle(:,2)];
	%get the unique pairings
		kPair	= unique(kPair,'rows');
	
	%get the start and stop index at which each vertex appears
		vStart		= find(kPair(:,1) - [0;kPair(1:end-1,1)] ~= 0);
		vEnd		= [vStart(2:end)-1; size(kPair,1)];
		nPerVertex	= vEnd - vStart + 1;
	%sort neighbors into cells
		kPair	= kPair(:,2)';
		
		cKPair	= mat2cell(kPair,1,nPerVertex);
		
	%construct the Neighbors cell
		srf.Neighbors	= [num2cell(nPerVertex) cKPair'];
%------------------------------------------------------------------------------%
