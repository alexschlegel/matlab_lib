function val = get(sm,prop)
% get
% 
% Description:	get properties of a StringMath object
% 
% Syntax:	val = get(sm,prop)
% 
% In:
% 	sm		- a StringMath object
%	prop	- the name of the property to get.  See documentation for set for
%			  valid properties
% 
% Out:
% 	val	- the value of the property
% 
% Updated:	2009-05-30
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

val	= sm.(prop);
