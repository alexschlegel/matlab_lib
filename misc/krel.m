function k = krel(kb,s,varargin)
% krel
% 
% Description:	calculate linear indices relative to a base linear index 
% 
% Syntax:	k = krel(kb,s,kr1,...,krN,[strBoundary]=NaN)
% 
% In:
% 	kb				- the base linear indices
%	s				- the size of the array
%	krK				- an Nx1 array of the relative index distance from kb to the
%					  output indices in the Kth dimension
%	[strBoundary]	- how to deal with out-of-bound indices.  one of the
%					  following:
%						'replicate':	replicate the nearest boundary index
%						NaN:			use NaN 
% 
% Out:
% 	k	- the linear indices at the locations specified. k has the dimensions of
%		  kb, plus N-elements along an additional dimension.
% 
% Updated: 2012-06-05
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
nd	= numel(s);

strBoundary	= ParseArgs(varargin(nd+1:end),NaN);

cKR		= reshape(varargin(1:nd),[],1);
cKB		= cell(nd,1);
[cKB{:}]	= ind2sub(s,kb);

cKRRep	= cellfun(@(kb,kr) repmat(reshape(kr,[ones(1,numel(size(kb))) numel(kr)]),[size(kb) 1]),cKB,cKR,'UniformOutput',false);
cKBRep	= cellfun(@(kb,kr) repmat(kb,[ones(1,numel(size(kb))) numel(kr)]),cKB,cKR,'UniformOutput',false);
cK		= cellfun(@(kb,kr) kb+kr,cKBRep,cKRRep,'UniformOutput',false);

if ischar(strBoundary)
	strBoundary	= CheckInput(strBoundary,'boundary',{'replicate'});
	
	cK	= cellfun(@(k,s) min(s,max(1,k)),cK,num2cell(s)','UniformOutput',false);
	
	k	= sub2ind(s,cK{:});
elseif isnan(strBoundary)
	bOut	= cellfun(@(k,s) k<1 | k>s,cK,num2cell(s)','UniformOutput',false);
	bAnyOut	= any(cat(2,bOut{:}),2);
	
	for kK=1:nd
		cK{kK}(bOut{kK})	= 1;
	end
	
	k			= sub2ind(s,cK{:});
	k(bAnyOut)	= NaN;
else
	error('Invalid boundary specifier.');
end
