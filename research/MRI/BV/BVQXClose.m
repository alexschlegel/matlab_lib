function BVQXClose(bvqx)
% BVQXClose
% 
% Description:	close and delete a BVQX COM object
% 
% Syntax:	BVQXClose(bvqx)
% 
% In:
% 	bvqx	- a BVQX COM object created with BVQXObject
% 
% Updated:	2009-07-10
% Copyright 2009 Alex Schlegel (alex@roguecheddar.com).  All Rights Reserved.

try
	%exit BVQX
		bvqx.Exit;
	
	%delete the server
		bvqx.delete;
catch
	status('Failed to close BVQX');
end