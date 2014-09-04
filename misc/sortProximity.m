function [y,kSort] = sortProximity(x,d,k1,k2)
% sortProximity
% 
% Description:	sort an array by clustering elements that are near each other
% 
% Syntax:	[y,kSort] = sortProximity(x,d,k1,k2)
% 
% In:
% 	x	- a numeric array.  sort(x) should be close to the best sorting.
%	d	- an array specifying the distance between every pair of elements in x
%	k1	- the index of the first element in each entry of d
%	k2	- the index of the second element in each entry of d
% 
% Out:
% 	y		- the sorted array
%	kSort	- the sorting index (y = x(k))
% 
% Updated: 2011-03-12
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
n	= numel(x);

%construct an upper-triangular matrix of distances
	md	= inf(n);
	
	kd	= sub2ind([n n],k1,k2);
	dk	= sub2ind([n n],k2,k1);
	
	
	md(kd)	= d;
	md(dk)	= d;
%merge elements into clusters until we have a single cluster
	p	= reshape(1:n,[],1);
	k	= num2cell(p);
	
	%[x,kSort]	= sort(x);
	x			= reshape(num2cell(x),[],1);
	
	for kIt=n:-1:2
		%find the pair of elements with the minimum distance
			[k1Min,k2Min]	= find(md==nanmin(md(:)),1);
		%merge these two
			if p(k1Min)<p(k2Min)
				kMn	= k1Min;
				kMx	= k2Min;
			else
				kMn	= k2Min;
				kMx	= k1Min;
			end
			
			x{kMn}	= [x{kMn}; x{kMx}];
			x(kMx)	= [];
			
			k{kMn}	= [k{kMn}; k{kMx}];
			k(kMx)	= [];
			
			p			= cellfun(@mean,k);
			
			md(kMn,:)	= nanmin(md(kMn,:),md(kMx,:));
			md(:,kMn)	= nanmin(md(:,kMn),md(:,kMx));
			
			md(find(eye(kIt)))	= inf;
			
			md(kMx,:)	= [];
			md(:,kMx)	= [];
	end
%extract the sorted array
	y		= x{1};
	kSort	= k{1};
