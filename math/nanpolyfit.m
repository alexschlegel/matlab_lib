function varargout = nanpolyfit(x,y,n)
% nanpolyfit
% 
% Description:	a version of polyfit that doesn't break with NaNs
% 
% Syntax:	(see polyfit documentation)
% 
% Updated: 2010-07-28
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
bNaN	= isnan(x) | isnan(y);

[varargout{1:nargout}]	= polyfit(x(~bNaN),y(~bNaN),n);
