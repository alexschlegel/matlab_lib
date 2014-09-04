function varargout = p_TransferProperties(sm,varargin)
% p_TransferProperties
% 
% Description:	transfer properties from one StringMath object to others
% 
% Syntax:	[sm1,...,smN] = p_TransferProperties(sm,sm1,...,smN)
% 
% In:
% 	sm	- the source StringMath object
%	smK	- the destination StringMath object
% 
% Updated:	2009-05-30
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

cTransfer	= {'precision'};
nTransfer	= numel(cTransfer);

varargout	= varargin;
for kT=1:nTransfer;
	sT	= cTransfer{kT};
	vT	= sm.(cTransfer{kT});
	
	for kI=1:nargin
		varargout{kI}.(sT)	= vT;
	end
end
