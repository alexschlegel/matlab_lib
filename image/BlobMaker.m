function [b,x,y] = BlobMaker(s,nCP,varargin)
% BlobMaker
% 
% Description:	create a blobbish figure
% 
% Syntax:	[b,x,y] = BlobMaker(s,nCP,<options>)
% 
% In:
% 	s	- the size of the blob, in pixels
%	nCP	- the number of control points to use in constructing the blob, or a
%		  four-element array to specify a different number of control points for
%		  each quadrant, starting with the upper-left and moving clockwise. more
%		  control points leads to a more complex figure.
%	<options>:
%		rmin:			(0.25) the minimum control point radius, as a fraction
%						of the blob size, or an array of four minimum radii (see
%						nCP)
%		rmax:			(1) the maximum control point radius, as a fraction of
%						the blob size, or an array of four maximum radii (see
%						nCP)
%		interp:			('phip') the interpolation method, or a cell array of
%						four methods (see nCP).  one of the following:
%							'pchip':	pchip interpolation
%							'linear':	linear interpolation
%							'spline':	spline interpolation (sucks)
%		interp_space:	('polar') the space in which interpolation takes place,
%						or a cell array of four spaces (see nCP). either 'polar'
%						or 'cartesian'.
% 
% Out:
% 	b	- a binary image of the figure
%	x	- the x coordinates of the figure outline
%	y	- the y coordinates of the figure outline
% 
% Example:	
%	b = BlobMaker(400,10);
%	b = BlobMaker(400,[3;4;1;2]);
%	b = BlobMaker(400,50,'rmin',0.5);
%	[b,x,y] = BlobMaker(400,5,'interp','linear','interp_space','cartesian');
% 
% Updated: 2012-09-12
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%parse the options
	opt	= ParseArgsOpt(varargin,...
			'rmin'			, 0.25		, ...
			'rmax'			, 1			, ...
			'interp'		, 'pchip'	, ...
			'interp_space'	, 'polar'	  ...
			);
	
	opt.interp			= cellfun(@(x) CheckInput(x,'interp',{'pchip','spline','linear'}),ForceCell(opt.interp),'UniformOutput',false);
	opt.interp_space	= cellfun(@(x) CheckInput(x,'interp_space',{'polar','cartesian'}),ForceCell(opt.interp_space),'UniformOutput',false);
%get the parameter for each quadrant
	if numel(nCP)==1
		kCP	= randBetween(0,4-eps,[nCP 1]);
		nCP	= arrayfun(@(k) sum(kCP>=k-1 & kCP<k),(1:4)');
	else
		nCP	= reshape(nCP,[],1);
	end
	
	opt.rmin			= repto(reshape(opt.rmin,[],1),[4 1]);
	opt.rmax			= repto(reshape(opt.rmax,[],1),[4 1]);
	opt.interp			= repto(reshape(opt.interp,[],1),[4 1]);
	opt.interp_space	= repto(reshape(opt.interp_space,[],1),[4 1]);

%generate the control points
	aQ	= [pi; 3*pi/2; 0; pi/2];
	aCP	= arrayfun(@(a,n) [a; randBetween(a,a+pi/2,[n 1]); a+pi/2],aQ,nCP,'UniformOutput',false);
	rCP	= arrayfun(@(rmn,rmx,n) [1; randBetween(rmn,rmx,[n 1]); 1],opt.rmin,opt.rmax,nCP,'UniformOutput',false);
	
	%sort by ascending angle
		[aCP,kSort]	= cellfun(@sort,aCP,'UniformOutput',false);
		rCP			= cellfun(@(r,k) r(k),rCP,kSort,'UniformOutput',false);
%generate the parameter for interpolation
	%estimate the path length
		%get enough points along the path
			aInterp	= arrayfun(@(a) GetInterval(a,a+pi/2,s)',aQ,'UniformOutput',false);
			[x,y]	= cellfun(@BM_Interpolate,aCP,rCP,aInterp,opt.interp,opt.interp_space,'UniformOutput',false);
		%distance between each point
			d	= cellfun(@(x,y) sqrt( diff(x).^2 + diff(y).^2 ),x,y,'UniformOutput',false);
			dPx	= cellfun(@(d) d*s,d,'UniformOutput',false);
		%path position of each point
			pPx	= cellfun(@(d) [0; cumsum(d)],dPx,'UniformOutput',false);
		%length of the path
			L	= cellfun(@(p) p(end),pPx,'UniformOutput',false);
	%map between aInterp and p to get an even step along the path for each point
		[pPx,kU]	= cellfun(@unique,pPx,'UniformOutput',false);
		aInterp		= cellfun(@(a,u) a(u),aInterp,kU,'UniformOutput',false);
		aInterp		= cellfun(@(p,a,L) interp1(p,a,(1:L)','linear'),pPx,aInterp,L,'UniformOutput',false);
		%aInterp		= [0; interp1(pPx,aInterp,(1:L)','linear'); 2*pi];
%generate the full path
	[x,y]	= cellfun(@BM_Interpolate,aCP,rCP,aInterp,opt.interp,opt.interp_space,'UniformOutput',false);
	
	x	= cat(1,x{:});
	y	= cat(1,y{:});
	
	xPx		= round(MapValue(x,-1,1,1,s));
	yPx		= round(MapValue(y,-1,1,1,s));
%fill the holes
	%get the distance between each successive point
		diffxPx	= diff(xPx);
		diffyPx	= diff(yPx);
		dPx		= sqrt( diffxPx.^2 + diffyPx.^2 );
		pPx		= [0; cumsum(dPx)];
	%find points that jump more than one x and y unit)
		kHole	= find(dPx>=2);
		nHole	= numel(kHole);
	
	if nHole>0
	%generate points to fill the holes
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
	b		= false(s);
	xPx		= min(s,max(1,xPx));
	yPx		= min(s,max(1,yPx));
	k		= sub2ind([s s],yPx,xPx);
	b(k)	= true;
%get the filled image
	bFill	= imfill(b,round([s/2 s/2]),4);
%get rid of the original outline because it might have spikes
	bFInterior	= bFill & ~b;
%expand to recover the non-spike outline
	b	= ordfilt2(bFInterior,5,[0 1 0; 1 1 1; 0 1 0],'zeros');
%get the outline
	p		= [xPx yPx];
	[pU,kU]	= unique(p,'rows');
	kU		= sort(kU);
	x		= p(kU,1);
	y		= p(kU,2);

%------------------------------------------------------------------------------%
function [x,y] = BM_Interpolate(aCP,rCP,aInterp,strMethod,strSpace)
	%add a bit extra to make sure the output is smooth
		nPoint	= numel(aInterp);
		
		aExtra1	= 2*pi+aCP(1);
		aExtra2	= 2*pi+aCP(2);
		
		nIExtra	= round(nPoint*aExtra2/(2*pi));
		aIExtra	= [aInterp; GetInterval(0,aExtra2,nIExtra-nPoint)'];
		
		aCPExtra	= [aCP; aExtra1; aExtra2];
		rCPExtra	= [rCP; rCP(1); rCP(2)];
	
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
end
%------------------------------------------------------------------------------%
function t = fT(t,n,k)
	t	= reshape(GetInterval(0,1,fN(t,n,k)),[],1);
end
%------------------------------------------------------------------------------%
function c = fC(t,n,k)
	c	= ones(fN(t,n,k),1);
end
%------------------------------------------------------------------------------%
function n = fN(t,n,k)
	if k>0
		n	= floor(k.*numel(t)./n) - sum(arrayfun(@(k) fN(t,n,k),1:k-1));
	else
		n	= 0;
	end
end
%------------------------------------------------------------------------------%

end
