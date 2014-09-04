function c = mat2cellByElement(x)
% mat2cellByElement
% 
% Description:	create a cell c the same size as x by placing each element of x
%				into the corresponding element of c
% 
% Syntax:	c = mat2cellByElement(x)
% 
% Updated:	2009-05-29
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

%construct the size arrays for mat2cell
	sz		= size(x);
	cSize	= cellfun(@(n) ones(1,n),num2cell(sz),'UniformOutput',false);
%convert to a cell
	c	= mat2cell(x,cSize{:});
