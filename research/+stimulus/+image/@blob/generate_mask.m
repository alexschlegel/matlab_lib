function [mask,ifo] = generate_mask(obj,ifo)
% stimulus.image.blob.generate_mask
% 
% Description:	generate the blob mask
% 
% Syntax: [mask,ifo] = obj.generate_mask(ifo)
% 
% In:
%	ifo	- the info struct
% 
% Out:
%	mask	- the binary blob image
%	ifo		- the updated info struct
% 
% Updated:	2015-09-29
% Copyright 2015 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%add the quadrant points
	a	= [ifo.param.a; 0; pi/2; pi; 3*pi/2];
	r	= [ifo.param.r; 1; 1;    1;  1];

%sort the control points
	[a,kSort]	= sort(a);
	r			= r(kSort);

%make sure the end points meet
	a	= [a; a(1)+2*pi];
	r	= [r; r(1)];

%generate the parameter for interpolation
	%estimate the path length
		%get enough points along the path
			aInterp	= GetInterval(a(1),a(end),4*ifo.param.size)';
			[x,y]	= Blob_Interpolate(a,r,aInterp,ifo.param.interp,ifo.param.interp_space);
		%distance between each point
			d	= sqrt( diff(x).^2 + diff(y).^2 );
			dPx	= d*ifo.param.size;
		%path position of each point
			pPx	= [0; cumsum(dPx)];
		%length of path
			L	= pPx(end);
	%map between aInterp and p to get an even step along the path for each point
		[pPx,kU]	= unique(pPx);
		aInterp		= aInterp(kU);
		pInterp		= linspace(0,L,ceil(L))';
		aInterp		= interp1(pPx,aInterp,pInterp);

%generate the full path
	[x,y]	= Blob_Interpolate(a,r,aInterp,ifo.param.interp,ifo.param.interp_space);
	
	xPx	= round(MapValue(x,-1,1,1,ifo.param.size));
	yPx	= round(MapValue(y,-1,1,1,ifo.param.size));

%fill the holes
	%get the distance between each successive point
		diffxPx	= diff(xPx);
		diffyPx	= diff(yPx);
		dPx		= sqrt( diffxPx.^2 + diffyPx.^2 );
		pPx		= [0; cumsum(dPx)];
	%find points that jump more than one x and y unit
		kHole	= find(dPx>=2);
		nHole	= numel(kHole);
	
	if nHole>0 %generate points to fill the holes
		dMax	= 2*ceil(max(dPx(kHole)));
		dStep	= repmat((0:dMax-1)/(dMax-1),[nHole 1]);
		
		xHoleFrom	= repmat(xPx(kHole),[1 dMax]);
		xHoleDiff	= repmat(diffxPx(kHole),[1 dMax]);
		yHoleFrom	= repmat(yPx(kHole),[1 dMax]);
		yHoleDiff	= repmat(diffyPx(kHole),[1 dMax]);
		
		xHole	= round(xHoleFrom + dStep.*xHoleDiff);
		yHole	= round(yHoleFrom + dStep.*yHoleDiff);
		
		xPx	= [xPx; reshape(xHole,[],1)];
		yPx	= [yPx; reshape(yHole,[],1)];
	end

%map onto an image
	mask	= false(ifo.param.size);
	xPx		= min(ifo.param.size,max(1,xPx));
	yPx		= min(ifo.param.size,max(1,yPx));
	k		= sub2ind([ifo.param.size ifo.param.size],yPx,xPx);
	mask(k)	= true;
%get the filled image
	maskFill	= imfill(mask,round([ifo.param.size/2 ifo.param.size/2]),4);
%get rid of the original outline because it might have spikes
	maskFInterior	= maskFill & ~mask;
%expand to recover the non-spike outline
	mask	= ordfilt2(maskFInterior,5,[0 1 0; 1 1 1; 0 1 0],'zeros');
%get the outline
	p		= [xPx yPx];
	[pU,kU]	= unique(p,'rows');
	kU		= sort(kU);
	x		= p(kU,1);
	y		= p(kU,2);

%info struct
	ifo.x	= x;
	ifo.y	= y;

%------------------------------------------------------------------------------%
function [x,y] = Blob_Interpolate(aCP,rCP,aInterp,strMethod,strSpace)
	%add a bit extra to make sure the output is smooth
		nPoint	= numel(aInterp);
		
		aExtra1	= 2*pi+aCP(1);
		aExtra2	= 2*pi+aCP(2);
		
		nIExtra	= round(nPoint*aExtra2/(2*pi));
		aIExtra	= [aInterp; GetInterval(0,aExtra2,nIExtra-nPoint)'];
		
		aCPExtra	= [aCP; aExtra1; aExtra2];
		rCPExtra	= [rCP; rCP(1); rCP(2)];
		
		[aCPExtra,kU]	= unique(aCPExtra);
		rCPExtra		= rCPExtra(kU);
	
	switch strSpace
		case 'polar'
			%interpolate
				rIExtra	= min(1,max(0,interp1(aCPExtra,rCPExtra,aIExtra,strMethod)));
			%get rid of the extra
				a	= aIExtra(1:nPoint);
				r	= rIExtra(1:nPoint);
			%convert to cartesian
				x	= r.*cos(a);
				y	= r.*sin(a);
		case 'cartesian'
			%convert to cartesian
				xCPExtra	= rCPExtra.*cos(aCPExtra);
				yCPExtra	= rCPExtra.*sin(aCPExtra);
			%interpolate
				xIExtra	= min(1,max(-1,interp1(aCPExtra,xCPExtra,aIExtra,strMethod)));
				yIExtra	= min(1,max(-1,interp1(aCPExtra,yCPExtra,aIExtra,strMethod)));
			%get rid of the extra
				x	= xIExtra(1:nPoint);
				y	= yIExtra(1:nPoint);
	end
%------------------------------------------------------------------------------%
