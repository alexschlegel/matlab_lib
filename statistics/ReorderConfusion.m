function cm = ReorderConfusion(cm,varargin)
% ReorderConfusion
% 
% Description:	reorder a confusion matrix
% 
% Syntax:	cm = ReorderConfusion(cm,kOrder) OR
%			cm = ReorderConfusion(cm,cLabelFrom,cLabelTo)
% 
% In:
% 	cm			- an NxN confusion matrix
%	kOrder		- an N-length array specifying the new order
%	cLabelFrom	- a cell of labels according to the current order
%	cLabelTo	- a cell of labels according to the new order
% 
% Out:
% 	cm	- the reordered confusion matrix
% 
% Updated: 2011-11-05
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
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
