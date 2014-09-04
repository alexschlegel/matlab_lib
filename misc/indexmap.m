function varargout = indexmap(sFrom,sTo)
% indexmap
% 
% Description:	map elements of one array to elements of another of the same
%				dimensions
% 
% Syntax:	k = indexmap(sFrom,sTo) OR
%			[k1,...,kn] = indexmap(sFrom,sTo)
% 
% In:
% 	sFrom	- the size of the source matrix
%	sTo		- the size of the destination matrix
% 
% Out:
% 	k	- a numel(xFrom)x1 array of the index in xTo to which each element of
%		  xFrom was mapped
%	kK	- the indices in the Kth dimensions
% 
% Updated: 2011-03-01
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
dFrom	= numel(sFrom);
nFrom	= prod(sFrom);
kFrom	= 1:nFrom;
csFrom	= reshape(num2cell(sFrom),[],1);

csTo	= reshape(num2cell(sTo),[],1);

ckFrom		= cell(dFrom,1);
[ckFrom{:}]	= ind2sub(sFrom,kFrom);

ckFrom	= cellfun(@(k,nf,nt) reshape(round(MapValue(k,1,nf,1,nt)),[],1),ckFrom,csFrom,csTo,'UniformOutput',false);

if nargout>1
	varargout	= ckFrom;
else
	varargout{1}	= sub2ind(sTo,ckFrom{:});
end
