function srfM = bvSRFMerge(srf1,srf2,varargin)
% bvSRFMerge
% 
% Description:	merge to surface meshes
% 
% Syntax:	srfM = bvSRFMerge(srf1,srf2,<options>)
% 
% In:
% 	srf1	- the first surface mesh, loaded with BVQXfile
%	srf2	- the second surface mesh
%	<options>:
%		'fixoverlap':	(false)	true to check for overlap between the two meshes
%						along the left-right axis.  if overlap exists and this
%						option is select, meshes are translated along that axis
%						to eliminate overlap.
%		'space':		(CoordinateSpace.BVQX_Internal) a CoordinateSpace
%						object specifying the SRF's coordinate space
%		'padding':		(0) amount of padding, in coordinate units, along the
%						left-right axis, by which to separate the lh and rh in
%						merged meshes
%		'spread':		(0) angle, in degrees, by which to spread the occipital
%						lobes of merged meshes outward from the medial plane
% 
% Out:
% 	srfM	- the merged surface mesh
% 
% Notes:	srfM is based on srf1, with vertices, faces, etc. from srf2 appended
% 
% Updated:	2009-08-03
% Copyright 2009 Alex Schlegel (alex@roguecheddar.com).  All Rights Reserved.
opt	= ParseArgsOpt(varargin,...
		'fixoverlap'	, false								, ...
		'space'			, CoordinateSpace.BVQX_Internal		, ...
		'padding'		, 0									, ...
		'spread'		, false								  ...
		);

%left/right functions
	switch opt.space.dirLR
		case -1
			LeftMost	= @max;
			RightMost	= @min;
			ShiftLeft	= @plus;
			ShiftRight	= @minus;
		case 1
			LeftMost	= @min;
			RightMost	= @max;
			ShiftLeft	= @minus;
			ShiftRight	= @plus;
	end

%get some info
	nVertex1	= srf1.NrOfVertices;
	nVertex2	= srf2.NrOfVertices;
	nVertexM	= nVertex1+nVertex2;
	
	nTriangle1	= srf1.NrOfTriangles;
	
%initialize the new SRF
	srfM	= bless(BVQXfile('new:srf'));
	
%copy properties from srf1
	cToCopy		= {	'ExtendedNeighbors',
					'MeshCenter',
					'ConvexRGBA',
					'ConcaveRGBA',
					'AutoLinkedMTC'
					'TriangleStripSequence'};
	cToAdd		= {	'NrOfVertices',
					'NrOfTriangles',
					'NrOfTriangleStrips'};
	cToAppend	= {	'VertexCoordinate',
					'VertexNormal',
					'VertexColor',
					'Neighbors',
					'TriangleVertex'
					};
	for k=[cToCopy;cToAdd;cToAppend]'
		srfM.(k{1})	= srf1.(k{1});
	end
	
%add
	for k=cToAdd'
		srfM.(k{1})	= srfM.(k{1}) + srf2.(k{1});
	end
	
%append
	for k=cToAppend'
		srfM.(k{1})	= [srfM.(k{1}); srf2.(k{1})];
	end

%special cases
	%neighbors
		%get the number of neighbors for each vertex
			nNeighbor	= cell2mat(srfM.Neighbors(nVertex1+1:nVertexM,1)');
		%convert the neighbor lists to one long list of indices
			kNeighbor	= cell2mat(srfM.Neighbors(nVertex1+1:nVertexM,2)');
		%add the offset
			kNeighbor	= kNeighbor + nVertex1;
		%reinsert
			kNeighbor	= mat2cell(kNeighbor,1,nNeighbor)';
			
			srfM.Neighbors(nVertex1+1:nVertexM,2)	= kNeighbor;
	%triangle vertices
		srfM.TriangleVertex(nTriangle1+1:end,:)	= srfM.TriangleVertex(nTriangle1+1:end,:) + nVertex1;

%mesh indices in the new merged mesh
	kVertex1	= 1:nVertex1;
	kVertex2	= nVertex1+1:nVertexM;

%shift the meshes along the left-right axis
	dShift	= 0;
	%get overlap shift
		if opt.fixoverlap
			%get the rightmost point of the first SRF
				pSRF1	= RightMost(srf1.VertexCoordinate(:,opt.space.axisLR));
			%get the leftmost point of the second SRF
				pSRF2	= LeftMost(srf2.VertexCoordinate(:,opt.space.axisLR));
			%get the shift amount
				if pSRF1==RightMost(pSRF1,pSRF2)
					dShift	= dShift + abs(pSRF1 - pSRF2)/2;
				end
		end
	%get padding shift
		dShift	= dShift + opt.padding/2;
	%shift
		srfM.VertexCoordinate(kVertex1,opt.space.axisLR)	= ShiftLeft(srfM.VertexCoordinate(kVertex1,opt.space.axisLR),dShift);
		srfM.VertexCoordinate(kVertex2,opt.space.axisLR)	= ShiftRight(srfM.VertexCoordinate(kVertex2,opt.space.axisLR),dShift);

%spread the meshes
	if opt.spread~=0
		%shift vertices by the mesh center
			bvSRFTranslate(srfM,-srfM.MeshCenter);
		%we're rotating along the IS-axis.  get the angles of rotation along the
		%x,y,z axes
			theta					= zeros(1,3);
			theta(opt.space.axisIS)	= opt.spread*pi/180;
		%negate depending on direction of axis
			theta	= theta*opt.space.dirIS;
			t1		= num2cell(-theta([3 1 2]));
			t2		= num2cell(theta([3 1 2]));
		%rotate vertex coordinates
			srfM.VertexCoordinate(kVertex1,:)	= RotatePoints(srfM.VertexCoordinate(kVertex1,:),t1{:});
			srfM.VertexCoordinate(kVertex2,:)	= RotatePoints(srfM.VertexCoordinate(kVertex2,:),t2{:});
		%rotate normals
			srfM.VertexNormal(kVertex1,:)	= RotatePoints(srfM.VertexNormal(kVertex1,:),t1{:});
			srfM.VertexNormal(kVertex2,:)	= RotatePoints(srfM.VertexNormal(kVertex2,:),t2{:});
		%unshift vertices by the mesh center
			bvSRFTranslate(srfM,srfM.MeshCenter);
	end
	