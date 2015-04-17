function stl = STLHollow(stl,t,varargin)
% STLHollow
% 
% Description:	make a hollow shell from an STL object
% 
% Syntax:	stl = STLHollow(stl,t,<options>)
% 
% In:
% 	stl	- an STL object representing a surface
%	t	- the shell thickness
%	<options>:
%		'freduce':		(1) the inner surface is reduced to freduce fraction
%						of the number of faces of the original surface
%		'nreducemin':	(1000) minumum number of vertices in the reduced inner
%						surface
% 
% Out:
% 	stl	- the original STL object with an inner surface appended.  The inner
%		  surface is calculated by translating each vertex inward along the mean
%		  of the normals of the faces to which the vertex belongs
% 
% Assumptions:	assumes normals of original surface point outward.
% 
% Updated: 2015-04-08
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin, ...
					'freduce'		, 1		, ...
					'nreducemin'	, 1000	  ...
					);

%normalize the normals
	m			= sqrt(sum(stl.Normal.^2,2));
	stl.Normal	= stl.Normal ./ repmat(m,[1 3]);

nFace	= size(stl.Vertex,1);

%get a list of vertices in the model
	v	= reshape(permute(stl.Vertex,[2 1 3]),[],3);
%get the unique ones
	[vU,kToU,kFromU]	= unique(v,'rows');
	nVertex				= size(vU,1);
%map from unique vertices to faces
	kFace			= reshape(repmat(1:nFace,[3 1]),[],1);
	[kV2F,kSort]	= sort(kFromU);
	kFace			= kFace(kSort);
	
%get the effective normal of each vertex
	status('Calculating Vertex Normals');
	
	%find the start and end of each vertex block
		kChange		= find(kV2F(1:end-1)~=kV2F(2:end));
		kBlockStart	= [1; kChange+1];
		kBlockEnd	= [kChange; nFace*3];
	
	vNormal	= zeros(nVertex,3);
	
	progress('action','init','total',nVertex,'label','Vertex');
	
	for kV=1:nVertex
		kBlock	= kFace(kBlockStart(kV):kBlockEnd(kV));
		
		vNormal(kV,:)	= mean(stl.Normal(kBlock,:),1);
		
		progress;
	end
	
	%normalize the normals
		m		= sqrt(sum(vNormal.^2,2));
		vNormal	= vNormal ./ repmat(m,[1 3]);
	
%translate each vertex
	status('Translating vertices');
	
	vU	= vU - t*vNormal;
	
%ununiquinize vertices
	v	= vU(kFromU,:);
	v	= reshape(v,3,[],3);
	v	= permute(v,[2 1 3]);

%make a reduced copy of stl
	stlInner		= stl;
	stlInner.Vertex	= v;
	
	nFaceReduce	= min(nFace,max(opt.nreducemin,round(nFace*opt.freduce)));
	if nFaceReduce~=nFace
		stlInner		= STLReduce(stlInner,nFaceReduce);
	end
%invert normals
	stlInner.Normal	= -stlInner.Normal;
%combine!
	stl.Normal	= [stl.Normal; stlInner.Normal];
	stl.Vertex	= [stl.Vertex; stlInner.Vertex];
	