function im = contour2im(y,x,varargin)
% contour2im
% 
% Description:	construct an image representing a contour
% 
% Syntax:	im = contour2im(y,x,<options>)
% 
% In:
%	y	- an N-length vector of y values, in pixels
% 	x	- an N-length vector of x values, in pixels
%	<options>:
%		size:	(<tightest>) the size of the output image
%		start:	(1) the index of the first point on the contour to represent in
%				the image
%		end:	(<end>) the index of the last point on the contour to represent
%				in the image
%		interp:	('pchip') the interpolation method to use (see interp1)
%		pen:	(<none>) the pen to apply to the image. one of the following:
%					b:	a binary pen image
%					c:	an N-length cell of binary pen images to apply a
%						different pen to each point
%					f:	a function that takes the distance along the contour and
%						the total contour length (in pixels) and returns a
%						binary pen image for that point
% 
% Out:
% 	im	- the binary contour image
% 
% Updated: 2015-11-16
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%parse the inputs
	n	= numel(x);
	
	opt	= ParseArgs(varargin,...
			'size'		, []		, ...
			'start'		, 1			, ...
			'end'		, n			, ...
			'interp'	, 'pchip'	, ...
			'pen'		, []		  ...
			);

%construct the interpolated contour points
	if n==1
		yI	= y;
		xI	= x;
		L	= 1;
	else
		%get the contour length
			[L,d]	= contourlength(x,y);
		
			if L>10*n
			%do an initial interpolation to get a better estimate of the length
				nIInit	= round(L/10);
				
				tInit	= (0:n-1)'./(n-1);
				tIInit	= (0:nIInit-1)'./(nIInit-1);
				
				yIInit	= round(interp1(tInit,y,tIInit,opt.interp));
				xIInit	= round(interp1(tInit,x,tIInit,opt.interp));
				
				[L,d]	= contourlength(xIInit,yIInit);
			end
		%construct the step parameter so we get constant spacing along the contour
			p		= [0; cumsum(d)];
			t		= GetInterval(0,1,numel(p))';
			
			[pU,kU]	= unique(p);
			tU		= t(kU);
			
			tI	= [0; interp1(pU,tU,GetInterval(1,L,round(2*L))','linear'); 1];
		
		tIStart	= round((opt.start-1)/(n-1));
		tIEnd	= round((opt.end-1)/(n-1));
		
		t		= (0:n-1)'./(n-1);
		tI		= tI(tI >= tIStart & tI <= tIEnd);
		
		yI	= round(interp1(t,y,tI,opt.interp));
		xI	= round(interp1(t,x,tI,opt.interp));
	end

%get the size of the output image
	if isempty(opt.size)
		opt.size	= [max(yI) max(xI)];
	elseif numel(opt.size)==1
		opt.size	= [opt.size opt.size];
	end

%eliminate points outside the image
	bBad		= yI<1 | yI>opt.size(1) | xI<1 | xI>opt.size(2);
	yI(bBad)	= [];
	xI(bBad)	= [];
	tI(bBad)	= [];
	
	nI	= numel(xI);

%fill the image
	im		= false(opt.size);
	
	if ~isempty(opt.pen)
		if isa(opt.pen,'logical')
			kI		= sub2ind(opt.size,yI,xI);
			im(kI)	= true;
			im		= applypen(im,opt.pen);
		else
			%get the pens
				switch class(opt.pen)
					case 'cell'
						assert(numel(opt.pen)==n,'one pen must be specified for each contour point');
						
						if n==1
							cPen	= opt.pen;
						else
							k		= (1:n)';
							kI		= min(n,max(1,round(interp1(t,k,tI,opt.interp))));
							cPen	= opt.pen(kI);
						end
					case 'function_handle'
						cPen	= arrayfun(@(t) opt.pen(L*t,L),tI,'uni',false);
					otherwise
						error('unknown pen type');
				end
			%apply the pens
				bAlready	= false(opt.size);
				
				for k=1:nI
					if ~bAlready(yI(k),xI(k))
						im	= applypenToPoint(im,yI(k),xI(k),cPen{k});
						
						bAlready(yI(k),xI(k))	= true;
					end
				end
		end
	else
		kI		= sub2ind(opt.size,yI,xI);
		im(kI)	= true;
	end

%-------------------------------------------------------------------------------
function im = applypenToPoint(im,y,x,pen)
	sP	= size(pen);
	
	yStart	= floor(y - sP(1)/2);
	xStart	= floor(x - sP(2)/2);
	yEnd	= yStart + sP(1)-1;
	xEnd	= xStart + sP(2)-1;
	
	ySA	= max(1,yStart);
	xSA	= max(1,xStart);
	yEA	= min(opt.size(1),yEnd);
	xEA	= min(opt.size(2),xEnd);
	
	ySPen	= ySA - yStart + 1;
	xSPen	= xSA - xStart + 1;
	yEPen	= ySPen + (yEA-ySA);
	xEPen	= xSPen + (xEA-xSA);
	
	im(ySA:yEA,xSA:xEA)	= im(ySA:yEA,xSA:xEA) | pen(ySPen:yEPen,xSPen:xEPen);
end
%-------------------------------------------------------------------------------

end
