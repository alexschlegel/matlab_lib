function bReplaced = bvSRFColorReplace(srf,colFrom,colTo)
% bvSRFColorReplace
% 
% Description:	replace colors in an SRF with other colors
% 
% Syntax:	bReplaced = bvSRFColorReplace(srf,colFrom,colTo)
% 
% In:
% 	srf		- an SRF object loaded with BVQXfile
%	colFrom	- an Nx1, Nx3, or Nx4 array of colors to replace.  Nx1 colors are
%			  interpred as color indices, Nx3 as RGB, and Nx4 as the full four-
%			  element value stored for each vertex color
%	colTo	- an array of colors to replace with
% 
% Out:
%	bReplaced	- an nVertex x 1 array indicating which vertices were recolored
% 
% Updated:	2009-06-15
% Copyright 2009 Alex Schlegel (alex@roguecheddar.com).  All Rights Reserved.

%make the colors Nx4
	colFrom	= FixColor(colFrom);
	colTo	= FixColor(colTo);

%keep track of which vertices have been affected
	bReplaced	= false(srf.NrOfVertices,1);

nCol	= size(colFrom,1);
for k=1:nCol
	%find matching vertices
		colCur		= repmat(colFrom(k,:),[srf.NrOfVertices 1]);
		bMatch		= all(eqnan(srf.VertexColor,colCur),2);
	%replace ones that haven't already been replaced
		bReplace	= bMatch & ~bReplaced;
		
		nReplace					= sum(bReplace);
		colCur						= repmat(colTo(k,:),[nReplace 1]);
		srf.VertexColor(bReplace,:)	= colCur;
		
		bReplaced(bReplace)	= true;
end

%------------------------------------------------------------------------------%
function col = FixColor(col)
	[nCol,nColumn]	= size(col);
	
	switch nColumn
		case 1
			col	= [col zeros(nCol,3)];
		case 3
			col	= [nan(nCol,1) col];
		case 4
		otherwise
			error(['Color array has incorrect number of columns (' num2str(nColumn) ').']);
	end
%------------------------------------------------------------------------------%
