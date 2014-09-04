function sm = set(sm,varargin)
% set
% 
% Description:	set properties of a StringMath object
% 
% Syntax:	sm = set(sm,prop1,val1,...,propN,valN)
% 
% In:
% 	sm		- a StringMath object
%	propK	- the name of the Kth property to set.  can be one of the following:
%		'precision':	number of decimal digits of precision for inexact
%						calculations
%	valK	- the new value of the Kth property
% 
% Out:
% 	sm	- sm updated
% 
% Updated:	2009-05-30
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

cPropValid	= {'precision'};

cProp	= varargin(1:2:end);
cVal	= varargin(2:2:end);
nSet	= numel(cProp);

if any(~ismember(cProp,cPropValid))
	error('Invalid properties specified.  See StringMath set documentation.');
end

for k=1:nSet
	sm.(cProp{k})	= cVal{k};
end
