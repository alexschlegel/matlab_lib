function bvSRFTranslate(srf,p)
% bvSRFTranslate
% 
% Description:	translate the coordinates of an SRF
% 
% Syntax:	bvSRFTranslate(srf,p)
% 
% In:
% 	srf	- a BVQXfile SRF object
%	p	- a 1x3 translation vector
% 
% Updated:	2009-08-03
% Copyright 2009 Alex Schlegel (alex@roguecheddar.com).  All Rights Reserved.
srf.VertexCoordinate	= srf.VertexCoordinate + repmat(p,[srf.NrOfVertices 1]);
