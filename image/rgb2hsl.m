function hsl = rgb2hsl(rgb)
% rgb2hsl
% 
% Description:	convert rgb values to hue, saturation, and luminance values
% 
% Syntax:	hsl = rgb2hsl(rgb)
% 
% In:
% 	rgb	- an M1 x ... x Mn x 3 array of rgb values
% 
% Out:
% 	hsl	- an M1 x ... x Mn x 3 array of hsl values
% 
% Updated:	2009-02-12
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
sz	= size(rgb);

[rgb,bConverted]	= im2double(rgb);

bColumn	= isequal(sz,[3 1]);
if bColumn
	rgb	= reshape(rgb,1,3);
end

%get the dimension along which r, g, and b are separated
	dLast	= ndims(rgb);
	if size(rgb,dLast)~=3
		error('rgb2hsl:BadArraySize','%s','rgb must be an M1 x ... x Mn x 3 array');
	end

%get the r, g, and b planes
	cRGB	= num2cell(rgb,1:dLast-1);
	[r,g,b]	= deal(cRGB{:});
	
%get the max and min for each rgb triplet
	mn		= min(rgb,[],dLast);
	mx		= max(rgb,[],dLast);
	mxmmn	= mx - mn;
	mxpmn	= mx + mn;
	
	bDiff	= mx~=mn;
	
%get the hue
	if dLast==2
		[h,s]	= deal(zeros(sz(1),1));
	else
		[h,s]	= deal(zeros(sz(1:dLast-1)));
	end
	
	bR			= bDiff & mx==r;
	bG			= bDiff & mx==g;
	bB			= bDiff & mx==b;
	
	h(bR)	= mod((g(bR)-b(bR))./(6*mxmmn(bR)),1);
	h(bG)	= ((b(bG)-r(bG))./mxmmn(bG)+2)/6;
	h(bB)	= ((r(bB)-g(bB))./mxmmn(bB)+4)/6;
	
%get the luminance
	l	= mxpmn/2;
	
%get the saturation
	bLL	= bDiff & l <= 1/2;
	bLG	= bDiff & l > 1/2;
	
	s(bLL)	= mxmmn(bLL)./mxpmn(bLL);
	s(bLG)	= mxmmn(bLG)./(2-mxpmn(bLG));

%construct the return array
	hsl	= cat(dLast,h,s,l);
	if bColumn
		hsl	= reshape(hsl,[3 1]);
	end

%make sure we're within the 0->1 bounds
	hsl	= max(0,min(1,hsl));

%optionally convert back to uint8
	if bConverted
		hsl	= im2uint8(hsl);
	end
	