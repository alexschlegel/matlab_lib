function stl = STLNew(strName)
% STLNew
% 
% Description:	create an empty STL struct
% 
% Syntax:	stl = STLNew(strName)
% 
% In:
% 	strName	- the name of the STL (80 or fewer characters)
% 
% Out:
% 	stl	- the empty STL struct (see STLRead)
% 
% Updated:	2009-04-07
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

stl.Header	= StringFill(strName,80,' ','right');
stl.Header	= stl.Header(1:80);

stl.Vertex	= zeros(0,3,3);
stl.Normal	= zeros(0,3);
