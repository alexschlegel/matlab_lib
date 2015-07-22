function [cm,kOrder] = ReorderConfusion(cm,varargin)
% ReorderConfusion
% 
% Description:	reorder a confusion matrix
% 
% Syntax:	[cm,kOrder] = ReorderConfusion(cm,kOrder) OR
%			[cm,kOrder] = ReorderConfusion(cm,cLabelFrom,cLabelTo)
% 
% In:
% 	cm			- an NxN confusion matrix
%	kOrder		- an N-length array specifying the new order
%	cLabelFrom	- a cell of labels according to the current order
%	cLabelTo	- a cell of labels according to the new order
% 
% Out:
% 	cm		- the reordered confusion matrix
%	kOrder	- the new order indices
% 
% Updated: 2015-06-16
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
switch numel(varargin)
	case 1
		kOrder	= varargin{1};
	case 2
		[cLabelFrom,cLabelTo]	= deal(varargin{:});
		
		[b,kOrder]	= ismember(cLabelTo,cLabelFrom);
	otherwise
		error('Incorrect number of input arguments.');
end

cm	= cm(kOrder,kOrder);
