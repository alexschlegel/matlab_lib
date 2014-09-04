function b = applypen(b,p)
% applypen
% 
% Description:	apply a pen to a contour image
% 
% Syntax:	im = applypen(b,p)
% 
% In:
% 	b	- a logical contour image
%	p	- a 2D binary pen mask
% 
% Out:
% 	im	- b with the contour transformed by the specified pen 
% 
% Updated: 2012-07-22
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
sB	= size(b);
sP	= size(p);

%pen centers
	[yB,xB]	= find(b);
	nB		= numel(yB);
	yB		= reshape(yB,1,nB);
	xB		= reshape(xB,1,nB);
	
	if nB==0
		return;
	end
%relative pen values
	[yP,xP]	= find(p);
	nP		= numel(yP);
	yP		= reshape(floor(yP - (sP(1)+1)/2),nP,1);
	xP		= reshape(floor(xP - (sP(2)+1)/2),nP,1);
	
	if nP==0
		return;
	end
%get the indices included in the transformed image
	yT	= repmat(yB,[nP 1]) + repmat(yP,[1 nB]);
	xT	= repmat(xB,[nP 1]) + repmat(xP,[1 nB]);
%eliminate points outside the image
	bBad		= yT<1 | yT>sB(1) | xT<1 | xT>sB(2);
	yT(bBad)	= [];
	xT(bBad)	= [];
%construct the transformed image
	kT	= sub2ind(sB,yT,xT);
	
	b		= false(sB);
	b(kT)	= true;
	