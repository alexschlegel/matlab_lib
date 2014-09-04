function im = imHyperbrot(s,c,z,varargin)
% IMHYPERBROT
%
% Description:	construct an image of the Mandelbrot set projected into 
%				hyperbolic space
%
% Syntax:	im = imHyperbrot(s,c,z,<opt>)
%
% In:
%	s		- a scalar specifying the size of the output image
%	c		- a complex number specifying the center point of the current view
%	z		- the zoom factor of the current view
%	<opt>
%		'iterator':		('z^2+c') optionally specify a different iterating
%						function.  use z for the current value and c for the
%						initial value.
%		'hspace':		('hyperbolic_axial') hyperbolic coordinate space to use.
%						can be 'hyperbolic_axial', 'hyperbolc_polar',
%						'hyperbolic_lobachevsky', 'hyperbolic_beltrami' or
%						'euclidean_cartesian'
%		'itMax':		(300) maximum number of iteration before deciding a
%						point is in the mandelbrot set
%		'rMax':			(3) if the radius of an iterative step exceeds rMax,
%						the algorithm decides the point is in the Mandelbrot set
%		'symbolic':		(false) use symbolic math to thwart round-off errors
%		'grid_approx':	(false) use the grid approximation method to speed up
%						the calculation
%		'hAx':			(none) display progress on the axis with handle hAx
%		'colBack':		([1 1 1]) the background color
%		'palette':		(<rainbow>) an Nx3 array specifying the palette to use.
%						The last color is used for points determined to be
%						inside the Mandelbrot set
%		'cycle':		(true) true if colors should wrap back to the beginning,
%						false if the last color should be repeated once the end
%						of the palette is reached
%		'nSeg':			(1) segment the image into nSeg x nSeg rectangles and
%						calculate the (segR,segC) rectangle only
%		'segR':			(1) see nSeg
%		'segC':			(1) see nSeg
%
%
% Out:
%	im	- the image
%
% Copyright 2006 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgsOpt(varargin,...
							'iterator','z^2+c',...
							'hspace','hyperbolic_axial',...
							'itmax',300,...
							'rmax',3,...
							'symbolic',false,...
							'grid_approx',false,...
							'hax',0,...
							'colback',[1 1 1],...
							'palette',GetDefaultPalette(),...
							'cycle',true,...
							'nseg',1,...
							'segr',1,...
							'segc',1);

%sym stuff
if opt.symbolic
	s			= sym(s);
	c			= sym(c);
	z			= sym(z);
	opt.itmax	= sym(opt.itmax);
	opt.rmax	= sym(opt.rmax);
	opt.nseg	= sym(opt.nseg);
	opt.segr	= sym(opt.segr);
	opt.segc	= sym(opt.segc);
else
	s			= double(s);
	c			= double(c);
	z			= double(z);
	opt.itmax	= double(opt.itmax);
	opt.rmax	= double(opt.rmax);
	opt.nseg	= double(opt.nseg);
	opt.segr	= double(opt.segr);
	opt.segc	= double(opt.segc);
end

%get the space coordinates
	d		= (s-1)/2;
	
	if opt.nseg==1
		[r,a]	= Coordinates(s,'polar');
		r		= r./d;
	else
		segS	= ceil(s/opt.nseg);
		y		= 1 + (opt.segr-1)*segS:opt.segr*segS;
		x		= 1 + (opt.segc-1)*segS:opt.segc*segS;
		y	= y(lteSym(y,s));
		x	= x(lteSym(x,s));
		
		y	= (s+1)/2-y;
		x	= x-(s+1)/2;
		
		segH	= numel(y);
		segW	= numel(x);
		y		= repmat(y',[1 segW]);
		x		= repmat(x,[segH 1]);
		
		r	= sqrt(x.^2 + y.^2)/d;
		a	= atan2Sym(y,x);
	end
	
	[u,v]	= PointConvertHyperbolic(r,a,'euclidean_polar',opt.hspace);
	
	p		= PointConvertComplex(u,v,opt.hspace);
	p		= p./z + c;
	
	if ~isequal(opt.hspace,'euclidean_cartesian')
		if opt.symbolic
			p(gteSym(r,sym(1)))	= sym(inf);
		else
			p(r>=1)	= inf;
		end
	end

%get the counts
	if opt.grid_approx
		c	= GetMandelCountGA(p,opt.itmax,opt.rmax,opt.iterator,opt.hax,opt.palette,opt.colback,opt.cycle);
	else
		c	= GetMandelCount(p,opt.itmax,opt.rmax,opt.iterator);
	end

%construct the image
	im	= imFromCount(c,opt.palette,opt.colback,opt.cycle);



%-------------------------------------------------------------------------------
function im = imFromCount(c,pal,colBack,bCycle)
%construct the image from the result of a call to GetMandelCount
	nPal	= size(pal,1);
	
	kInCount	= c~=-1 & ~isinfSym(c);
	
	if bCycle
		c(kInCount)	= mod(c(kInCount),nPal-1)+1;
	else
		c(kInCount)	= min(c(kInCount),nPal-1);
	end
	
	pal	= [pal;colBack];
	c(c==-1)		= nPal;
	c(isinfSym(c))	= nPal+1;
	
	im	= ind2rgb(double(c),pal);
%-------------------------------------------------------------------------------
function c = GetMandelCountGA(p,itMax,rMax,varargin)
%c = GetMandelCountGA(p,itMax,rMax,[iterator]=[],[hAx]=0,[pal]=<default>],...
%					  [colBack]=[1 1 1],bCycle=true)
%same as GetMandelCount, but uses a grid approximation: calculates counts first
%on grid lines; if all grid points surrounding a square have the same count,
%fills all square points with that count value.  if hAx is specified, shows
%progress of the calculation during each iteration
%ASSUMES p is square
	[iterator,hAx,pal,colBack,bCycle]	= ParseArgs(varargin,[],0,GetDefaultPalette(),[1 1 1],true);
	
	bSymbolic	= isa(p,'sym');
	
	if hAx~=0
		axes(hAx);
	end
	
	rMax2	= rMax^2;
	s		= size(p,1);
	
	[c,bSudah]	= deal(zeros(s));
	bSudah		= logical(bSudah);
	
	kIt				= ~isinfSym(p(:));
	c(~kIt)			= Inf;
	bSudah(~kIt)	= true;
	
	%calculate along the edges
		c([1,end],:)		= GetMandelCount(p([1,end],:),itMax,rMax,iterator,bSymbolic);
		bSudah([1,end],:)	= true;
		c(:,[1,end])		= GetMandelCount(p(:,[1,end]),itMax,rMax,iterator,bSymbolic);
		bSudah(:,[1,end])	= true;
	
	gFact	= 1;	%grid size factor
	nGridIt	= floor(log2(min(size(p)))-1);	%number of grid iterations
	for kGridIt=1:nGridIt	%loop through each grid size
		gFact	= gFact*2;
		gSize	= s/gFact;	%size of the current grid
		
		%get the points to calculate
			kLinePos	= ceil(1+(1:gFact-1)*gSize);
			nLine		= numel(kLinePos);
			
			kHRow	= repmat(kLinePos,[s 1]);
			kHCol	= repmat((1:s)',[1 nLine]);
			kVRow	= repmat(1:s,[nLine 1]);
			kVCol	= repmat(kLinePos',[1 s]);
			
			indH	= sub2ind([s s],kHRow,kHCol);
			indV	= sub2ind([s s],kVRow,kVCol);
			ind		= [indH(:);indV(:)];
			ind		= ind(~bSudah(ind));
		
		%calculate for the selected grid points
			c(ind)		= GetMandelCount(p(ind),itMax,rMax,iterator,bSymbolic);
			bSudah(ind)	= true;
		
		%determine which squares are uniform
		for gRow=1:gFact-1
			for gCol=1:gFact-1
				%edges of the current grid
				gLeft	= ceil(1+gSize*(gCol-1));
				gRight	= ceil(1+gSize*gCol);
				gTop	= ceil(1+gSize*(gRow-1));
				gBottom	= ceil(1+gSize*gRow);
				
				if ~bSudah(gTop+1,gLeft+1)
					%get the counts of the grid points surrounding the square
					gCount1	= c(gTop:gBottom,[gLeft gRight]);
					gCount2	= c([gTop gBottom],gLeft:gRight);
					gCount	= [gCount1(:);gCount2(:)];
					
					%are any of the counts different?
					if ~range(gCount)
						c(gTop+1:gBottom-1,gLeft+1:gRight-1)		= gCount(1);
						bSudah(gTop+1:gBottom-1,gLeft+1:gRight-1)	= true;
					end
				end
			end
		end
		
		%draw the current state
		if hAx~=0
			im	= imFromCount(c,pal,colBack,bCycle);
			image(im);
			ResetTicks(hAx);
			pause(0.05);
		end
	end
	
	c(~bSudah)	= GetMandelCount(p(~bSudah),itMax,rMax,iterator,bSymbolic);
	
	if hAx~=0
		im	= imFromCount(c,pal,colBack,bCycle);
		image(im);
		ResetTicks(hAx);
	end
	
%-------------------------------------------------------------------------------
function c = GetMandelCount(p,itMax,rMax,varargin)
%c = GetMandelCount(p,itMax,rMax,[iterator]='z^2+c',[bWaitbar]=false)
%calculate the number of iterations before the specified complex points exceed
%the itMax/rMax specified.  returns -1 for points in the Mandelbrot set
	[iterator,bWaitbar]	= ParseArgs(varargin,'z^2+c',false);
	
	rMax2	= rMax^2;
	
	c	= zeros(size(p));
	
	kIt		= ~isinfSym(p(:));
	c(~kIt)	= Inf;
	
	pO	= p;
	k	= 0;
	if bWaitbar wb=waitbar(0,'Calculating...'); end
	
	if isequal(iterator,'z^2+c')
		while any(kIt) && ltSym(k,itMax)
			k	= k + 1;
			
			c(kIt)	= k;
			
			p(kIt)	= p(kIt).^2 + pO(kIt);
			
			kIt(kIt)	= lteSym(p(kIt).*conj(p(kIt)),rMax2);
			
			if bWaitbar waitbar(double(k/itMax),wb); end
		end
	else
		f	= vectorize(inline(iterator,'z','c'));
		
		while any(kIt) && ltSym(k,itMax)
			k	= k + 1;
			
			c(kIt)	= k;
			
			p(kIt)	= feval(f,p(kIt),pO(kIt));
			
			kIt(kIt)	= lteSym(p(kIt).*conj(p(kIt)),rMax2);
			
			if bWaitbar waitbar(double(k/itMax),wb); end
		end
	end
	if bWaitbar close(wb); end
	
	c(kIt)	= -1;
%-------------------------------------------------------------------------------
function pal = GetDefaultPalette()
	cCount = 48; % must be | 6
    cPart = cCount/6;
    
    %color component stages
	cMin	= zeros(cPart,1);
	cUp     = (0:cPart-1)'/cPart;
	cDown	= (cPart-1:-1:0)'/cPart;
	cMax	= ones(cPart,1);
	
	pal	= [	[cMax;cDown;cMin;cMin;cUp;cMax;0] ...
			[cUp;cMax;cMax;cDown;cMin;cMin;0] ...
			[cMin;cMin;cUp;cMax;cMax;cDown;0] ];
%-------------------------------------------------------------------------------
function ResetTicks(h)
	set(h,'YTick',[]);
	set(h,'XTick',[]);
	set(h,'YTickLabel',[]);
	set(h,'XTickLabel',[]);
%-------------------------------------------------------------------------------
