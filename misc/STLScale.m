function stl = STLScale(stl,f)
% STLScale
% 
% Description:	scale stl's size by factor f
% 
% Syntax:	stl = STLScale(stl,f)
% 
% In:
% 	stl	- an STL struct loaded with STLRead
%	f	- the scale factor
% 
% Out:
% 	stl	- stl with all vertices scaled by factor f
% 
% Updated:	2009-01-28
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
stl.Vertex	= stl.Vertex .* f;
