function [y,k] = squish(x,varargin)
% squish
% 
% Description:	squish the non-zero elements of a 3d array into a 2d array
% 
% Syntax:	[y,k] = squish(x,[dim]=1)
% 
% In:
% 	x		- a 3d array
%	[dim]	- the dimension along which to squish
% 
% Out:
% 	y	- the 2d squished array
%	k	- the indices in x that were assigned to each element in y 
% 
% Updated: 2015-04-08
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
dim	= ParseArgs(varargin,1);

s	= size(x);

%get the elements to squish
	bSquish		= x~=0;
	kSquish		= find(bSquish);
	nSquish		= numel(kSquish);
	[xS,yS,zS]	= ind2sub(s,kSquish);
%projected into the given plane
	switch dim
		case 1
			k1	= yS;
			k2	= zS;
			sS	= s([2 3]);
		case 2
			k1	= xS;
			k2	= zS;
			sS	= s([1 3]);
		case 3
			k1	= xS;
			k2	= yS;
			sS	= s([1 2]);
		otherwise
			error('Invalid dim.');
	end
%get the distance of each element to the center of mass
	xS	= xS - mean(xS);
	yS	= yS - mean(yS);
	zS	= zS - mean(zS);
	d2	= xS.^2 + yS.^2 + zS.^2;
%order the elements by distance
	[d2,kSort]		= sort(d2);
	[kSquish,k1,k2]	= varfun(@(x) x(kSort),kSquish,k1,k2);
%assign each element to the 2d element it is closest to
	[yk1,yk2]	= ndgrid(GetInterval(-(sS(1)-1)/2,(sS(1)-1)/2,sS(1)),GetInterval(-(sS(2)-1)/2,(sS(2)-1)/2,sS(2)));
	bAssigned	= false(sS);
	k			= zeros(sS);
	
	progress('action','init','total',nSquish,'squishin''');
	for kS=1:nSquish
		kUn		= find(~bAssigned);
		dCur2	= (k1(kS) - yk1(kUn)).^2 + (k2(kS) - yk2(kUn)).^2;
		kMin	= find(dCur2==min(dCur2),1);
		
		if kSquish(kS)==61218
			break;
		end
		
		bAssigned(kUn(kMin))	= true;
		k(kUn(kMin))			= kSquish(kS);
		
		%check to make sure we're not on the edge
			[y1,y2]	= ind2sub(sS,kUn(kMin));
			
			if y1==1 || y1==sS(1) || y2==1 || y2==sS(2)
				bAssigned	= [false(sS(1),3*sS(2)); false(sS) bAssigned false(sS); false(sS(1),3*sS(2))];
				k			= [zeros(sS(1),3*sS(2)); zeros(sS) k zeros(sS); zeros(sS(1),3*sS(2))];
				
				sS			= 3*sS;
				[yk1,yk2]	= ndgrid(GetInterval(-(sS(1)-1)/2,(sS(1)-1)/2,sS(1)),GetInterval(-(sS(2)-1)/2,(sS(2)-1)/2,sS(2)));
			end
		
		progress;
	end
%crop k
	k	= cropborder(k,0);
%assign values from x
	y		= zeros(size(k));
	y(k~=0)	= x(k(k~=0));

