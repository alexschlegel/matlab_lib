function varargout = structfun2(f,varargin)
% structfun2
% 
% Description:	an extension of structfun that handles multiple struct inputs
%				as long as they contain the same fields
% 
% Syntax:	[sO1,...,sON] = structfun(f,sI1,...,sIM)
% 
% In:
% 	f	- the handle to a function that takes M inputs and produces N outputs
%	sIK	- the Kth struct whose fields should be passed as the Kth argument to f
% 
% Out:
% 	sOK	- the Kth struct resulting from calling f
% 
% Updated: 2010-07-23
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

%input structs
	sI	= varargin;
%convert the input structs to cells
	cField	= fieldnames(sI{end});
	cSI		= cellfun(@(x) struct2cell(orderfields(x,cField)),sI,'UniformOutput',false);
	nSI		= numel(cSI);
%get the output cells
	cSO	= {};
	[cSO{1:nargout}]	= cellfun(f,cSI{:},'UniformOutput',false);
%convert the output cells to structs
	varargout	= cellfun(@(x) cell2struct(x,cField,1),cSO,'UniformOutput',false);
