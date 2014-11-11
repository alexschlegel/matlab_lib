function [stl,isoval] = STLIsoSurface(varargin)
% STLIsoSurface
% 
% Description:	create an STL struct from an isosurface
% 
% Syntax:	stl = STLIsoSurface([x,y,z,]v,[isoval],<options>)
% 
% In:
% 	[x/y/z/]v/[isoval]	- arguments to the isosurface function
%	<options>:
%		prefix:	('STLIsoSurface') the prefix for the STL name
% 
% Out:
% 	stl		- an STL struct
%	isoval	- the isovalue used to calculate the isosurface
% 
% Updated: 2013-07-09
% Copyright 2013 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%parse the inputs
	kChar	= unless(find(cellfun(@ischar,varargin),1,'first'),nargin+1);
	opt		= ParseArgs(varargin(kChar:end),...
				'prefix'	, 'STLIsoSurface'	  ...
				);
	
	%separate isoval from the rest
		vIS	= varargin(1:kChar-1);
		nIS	= numel(vIS);
		
		switch nIS
			case {2,5}
				isoval	= vIS{end};
				vIS		= vIS(1:end-1);
			case {1,4}
				isoval	= isovalue(vIS{end});
			otherwise
				error('Unrecognized isosurface input.');
		end

%get the isosurface
	fv	= isosurface(vIS{:},isoval);
	
	nFace	= size(fv.faces,1);
	nVertex	= size(fv.vertices,1);
%and the surface normals
	n	= isonormals(vIS{:},fv.vertices);
%isosurface switches x and y coordinates
	if nVertex>0
		[fv.vertices,n]	= varfun(@(x) x(:,[2 1 3]),fv.vertices,n);
	end
%construct the STL
	strName	= left([opt.prefix ' (isovalue=' num2str(isoval) ')'],80);
	stl		= STLNew(strName);
	
	%get the vertices associated with each face
		if nVertex>0 && nFace>0
			kVertex	= repmat(fv.faces,[1 1 3]);
			kXYZ	= repmat(reshape(1:3,1,1,3),[nFace 3 1]);
			k		= sub2ind([nVertex 3],kVertex,kXYZ);
		else
			k		= [];
		end
		
		stl.Vertex	= fv.vertices(k);
	%face normals are the means of the vertex normals
		stl.Normal	= squeeze(mean(n(k),2));
