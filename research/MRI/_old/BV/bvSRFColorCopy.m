function bvSRFColorCopy(srfFrom,srfTo,varargin)
% bvSRFColorCopy
% 
% Description:	copy vertex colors from one surface mesh to another
% 
% Syntax:	bvSRFColorCopy(srfFrom,srfTo,[col]=<all>)
% 
% In:
% 	srfFrom	- the source SRF, loaded with BVQXfile
%	srfTo	- the destination SRF.  Must have the same number of vertices as
%			  srfFrom.
%	[col]	- either an Nx3 array of RGB colors or an Nx1 array of color indices
%			  to copy from srfFrom to srfTo
% 
% Side-effects:
% 	copies the specified colors from srfFrom to srfTo
% 
% Notes:	this function doesn't overwrite negative color values (i.e. black)
%			in srfTo
% 
% Updated:	2009-03-13
% Copyright 2009 Alex Schlegel (alex@roguecheddar.com).  All Rights Reserved.
col	= ParseArgs(varargin,[]);

%get negative colors
	bValid	= ~any(srfTo.VertexColor<0 | srfTo.VertexColor>=2^32-2^10,2);

%get the vertices to transfer
	if isempty(col)	%copy all colors
		bReplace	= bValid;
	else
		[nColor,cType]	= size(col);
		
		%get the vertex colors
			switch cType
				case 3	%RGB colors
					bReplace	= bValid & ismember(srfFrom.VertexColor(:,2:4),col,'rows');
				case 1	%indices
					col			= [col zeros(nColor,3)];
					bReplace	= bValid & ismember(srfFrom.VertexColor,col,'rows');
			end
	end

%copy the colors
	srfTo.VertexColor(bReplace,:)	= srfFrom.VertexColor(bReplace,:);
	