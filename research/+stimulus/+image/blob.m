function [im,b,ifo] = blob(varargin)
% stimulus.image.blob
% 
% Description:	create a blobbish figure
% 
% Syntax:	[im,b,ifo] = stimulus.image.blob(<options>)
% 
% In:
%	<options>: (see also stimulus.image.common_defaults)
%		cp:				(5) the number of control points to use in constructing
%						the blob, or a four-element array to specify a different
%						number of control points for each quadrant, starting
%						with the upper-left and moving clockwise. more control
%						points lead to a more complex figure.
%		rmin:			(0.25) the minimum control point radius, as a fraction
%						of the blob size, or an array of four minimum radii (see
%						nCP)
%		rmax:			(1) the maximum control point radius, as a fraction of
%						the blob size, or an array of four maximum radii (see
%						nCP)
%		interp:			('pchip') the interpolation method, or a 4-element cell
%						array of methods, one for each quadrant. from the
%						following:
%							'pchip':	pchip interpolation
%							'linear':	linear interpolation
%							'spline':	spline interpolation (sucks)
%		interp_space:	('polar') the space in which interpolation takes place,
%						or a 4-element cell array of spaces, one for each
%						quadrant. from the following:
%							'polar'
%							'cartesian'
% 
% Out:
%	im	- the stimulus image
% 	b	- a binary mask of the stimulus image
%	ifo	- a struct of info about the stimulus:
%			x:	the x coordinates of the figure outline
%			y:	the y coordinates of the figure outline
% 
% Updated: 2015-09-24
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%default option values
	persistent cDefault;
	
	if isempty(cDefault)
		cDefault	=	{
							'cp'			, 5			, ...
							'rmin'			, 0.25		, ...
							'rmax'			, 1			, ...
							'interp'		, 'pchip'	, ...
							'interp_space'	, 'polar'	  ...
							};
	end

%generate the stimulus
	[im,b,ifo]	= stimulus.image.common_pipeline(...
					'vargin'		, varargin			, ...
					'defaults'		, cDefault			, ...
					'f_validate'	, @Blob_Validate	, ...
					'f_mask'		, @Blob_Mask		  ...
					);

%------------------------------------------------------------------------------%
function [opt,ifo] = Blob_Validate(opt,ifo)
	opt.interp			= cellfun(@(x) CheckInput(x,'interp',{'pchip','spline','linear'}),ForceCell(opt.interp),'uni',false);
	opt.interp_space	= cellfun(@(x) CheckInput(x,'interp_space',{'polar','cartesian'}),ForceCell(opt.interp_space),'uni',false);
%------------------------------------------------------------------------------%
function [b,ifo] = Blob_Mask(opt,ifo)
	%get the parameters for each quadrant
		%number of control points
			if numel(opt.cp)==1
				kCP	= randBetween(0,4,[opt.cp 1],'seed',false);
				nCP	= arrayfun(@(k) sum(kCP>=k-1 & kCP<k),(1:4)');
			else
				nCP	= reshape(opt.cp,[],1);
			end
		
		opt.rmin			= repto(reshape(opt.rmin,[],1),[4 1]);
		opt.rmax			= repto(reshape(opt.rmax,[],1),[4 1]);
		opt.interp			= repto(reshape(opt.interp,[],1),[4 1]);
		opt.interp_space	= repto(reshape(opt.interp_space,[],1),[4 1]);
	
	%generate the control points
		aQ	= [pi; 3*pi/2; 0; pi/2];
		aCP	= arrayfun(@(a,n) [a; randBetween(a,a+pi/2,[n 1],'seed',false); a+pi/2],aQ,nCP,'uni',false);
		rCP	= arrayfun(@(rmn,rmx,n) [1; randBetween(rmn,rmx,[n 1],'seed',false); 1],opt.rmin,opt.rmax,nCP,'uni',false);
		
		%sort by ascending angle
			[aCP,kSort]	= cellfun(@sort,aCP,'uni',false);
			rCP			= cellfun(@(r,k) r(k),rCP,kSort,'uni',false);
	%generate the parameter for interpolation
		%estimate the path length
			%get enough points along the path
				aInterp	= arrayfun(@(a) GetInterval(a,a+pi/2,opt.size)',aQ,'UniformOutput',false);
				[x,y]	= cellfun(@Blob_Interpolate,aCP,rCP,aInterp,opt.interp,opt.interp_space,'uni',false);
			%distance between each point
				d	= cellfun(@(x,y) sqrt( diff(x).^2 + diff(y).^2 ),x,y,'uni',false);
				dPx	= cellfun(@(d) d*opt.size,d,'uni',false);
			%path position of each point
				pPx	= cellfun(@(d) [0; cumsum(d)],dPx,'uni',false);
			%length of the path
				L	= cellfun(@(p) p(end),pPx,'uni',false);
		%map between aInterp and p to get an even step along the path for each point
			[pPx,kU]	= cellfun(@unique,pPx,'uni',false);
			aInterp		= cellfun(@(a,u) a(u),aInterp,kU,'uni',false);
			aInterp		= cellfun(@(p,a,L) interp1(p,a,(1:L)','linear'),pPx,aInterp,L,'uni',false);
	%generate the full path
		[x,y]	= cellfun(@Blob_Interpolate,aCP,rCP,aInterp,opt.interp,opt.interp_space,'uni',false);
		
		x	= cat(1,x{:});
		y	= cat(1,y{:});
		
		xPx		= round(MapValue(x,-1,1,1,opt.size));
		yPx		= round(MapValue(y,-1,1,1,opt.size));
	%fill the holes
		%get the distance between each successive point
			diffxPx	= diff(xPx);
			diffyPx	= diff(yPx);
			dPx		= sqrt( diffxPx.^2 + diffyPx.^2 );
			pPx		= [0; cumsum(dPx)];
		%find points that jump more than one x and y unit
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
		b		= false(opt.size);
		xPx		= min(opt.size,max(1,xPx));
		yPx		= min(opt.size,max(1,yPx));
		k		= sub2ind([opt.size opt.size],yPx,xPx);
		b(k)	= true;
	%get the filled image
		bFill	= imfill(b,round([opt.size/2 opt.size/2]),4);
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
function t = fT(t,n,k)
	t	= reshape(GetInterval(0,1,fN(t,n,k)),[],1);
%------------------------------------------------------------------------------%
function c = fC(t,n,k)
	c	= ones(fN(t,n,k),1);
%------------------------------------------------------------------------------%
function n = fN(t,n,k)
	if k>0
		n	= floor(k.*numel(t)./n) - sum(arrayfun(@(k) fN(t,n,k),1:k-1));
	else
		n	= 0;
	end
%------------------------------------------------------------------------------%
