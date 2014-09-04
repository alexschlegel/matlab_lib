function x = ffilt(x,f,d,varargin)
% ffilt
% 
% Description:	function filter.  filter an array by defining function (f) to
%				operate on a domain (d)
% 
% Syntax:	x = ffilt(x,f,d,[strBoundary]='replicate',[bDimFunc]=false)
% 
% In:
% 	x				- an array
%	f				- the handle to a function that takes an array as input and
%					  returns a single value
%	d				- a binary array specifying the filter domain, i.e. the
%					  neighborhood around each element to include as inputs to
%					  the filter operation for that element
%	[strBoundary]	- how to deal with out-of-bound domain elements.  one of the
%					  following:
%						'replicate':	replicate the nearest boundary element
%						n:				fill with the value n
%	[bDimFunc]		- true if f takes a dimension as its second argument and so
%					  can operate on the whole array at once
% 
% Out:
% 	x	- the filtered array
% 
% Updated: 2012-06-05
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
[strBoundary,bDimFunc]	= ParseArgs(varargin,'replicate',false);

s	= size(x);
n	= numel(x);
nd	= numel(s);

%get the relative indices in the domain
	sD			= size(d)';
	nD			= numel(d);
	ndD			= numel(sD);
	cD			= sD - floor(sD/2);
	cKRel		= cell(ndD,1);
	[cKRel{:}]	= ind2sub(sD,find(d));
	cKRel		= cellfun(@(k,c) k-c,cKRel,num2cell(cD),'UniformOutput',false);
	
	[cKRel{ndD+1:nd}]	= deal(zeros(nD,1));
%get the element to include in each operation
	strKRelBoundary	= switch2(strBoundary,...
						'replicate'	, 'replicate'	, ...
						NaN);
	
	k	= reshape(1:n,s);
	k	= krel(k,s,cKRel{:},strKRelBoundary);
%filter
	if bDimFunc
		bNaN		= isnan(k);
		k(bNaN)		= 1;
		xf			= x(k);
		xf(bNaN)	= strBoundary;
		x			= f(xf,nd+1);
	else
		k	= cell2mat(reshape(k,n,nD),ones(n,1),nD);
		x	= reshape(cellfun(@ffunc,k),s);
	end

%------------------------------------------------------------------------------%
function y = ffunc(k)
	bNaN		= isnan(k);
	k(bNaN)		= 1;
	xs			= x(k);
	xs(bNaN)	= strBoundary;
	y			= f(xs);
end
%------------------------------------------------------------------------------%

end
