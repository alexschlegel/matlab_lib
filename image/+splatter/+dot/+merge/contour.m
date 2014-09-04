function b = contour(b1,b2,varargin)
% splatter.dot.merge.contour
% 
% Description:	merge two contours, with a surface tensiony thing around areas
%				where the contours overlap
% 
% Syntax:	b = splatter.merge.contour(b1,b2,<options>)
% 
% In:
% 	b1	- the first binary contour image
%	b2	- the second binary contour image
%	<options>:
%		tension_radius:	(20) the tension radius, in pixels
% 
% Out:
% 	b	- the merged binary contour image
%
% Notes: don't try this with crazy spiky stuff with lots of intersections
% 
% Updated: 2013-05-16
% Copyright 2013 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgsOpt(varargin,...
		'tension_radius'	, 20	  ...
		);

sz	= size(b1);

%remove the parts of each contour that are interior to the other
	b1Fill	= holefill(b1,4);
	b2Fill	= holefill(b2,4);
	
	bI		= b1 & b2;
	b1Out	= (b1 & ~b2Fill) | bI;
	b2Out	= (b2 & ~b1Fill) | bI;
	
	%ShowDebug(b1Out,b2Out);
%merge the two contours
	b		= b1Out | b2Out;
%make sure we don't have any islands in the interior by getting rid of pixels
%that don't touch non-filled pixels
	bNonFill	= ~holefill(b,4);
	b			= b & ordfilt2(bNonFill,9,ones(3));
	b1Out		= b1Out & b;
	b2Out		= b2Out & b;
	
	%ShowDebug(b1Out,b2Out);
%get the intersection points between the two contours
	bI	= b1Out & b2Out;
	
	%ShowDebug(bI,b1Out&~bI,b2Out&~bI);
%use the intersection points closest to the centroid of each intersection region
	L		= bwlabeln(bI);
	stats	= regionprops(L,'Centroid','PixelList');
	
	nInt	= numel(stats);
	[yI,xI]	= deal(zeros(nInt,1));
	for kI=1:nInt
		d		= dist(stats(kI).PixelList,stats(kI).Centroid);
		kMin	= find(d==min(d),1);
		
		yI(kI)	= stats(kI).PixelList(kMin,2);
		xI(kI)	= stats(kI).PixelList(kMin,1);
	end
%replace each intersection region with a tensiony thing
	for kI=1:nInt
		if ~b(yI(kI),xI(kI))
		%make sure the intersection point is still there
			continue;
		end
		
		%get the contour points around the intersection
			bMask	= false(sz);
			bMask	= InsertImage(bMask,MaskCircle(2*opt.tension_radius),[yI(kI) xI(kI)],[],'center');
			
			bAround	= bMask & b;
		%keep only the contour points that connect to the intersection
			L		= bwlabeln(bAround);
			bAround	= L==L(yI(kI),xI(kI));
			
			%ShowDebug(bI&bAround,bAround&~bI,b&~bAround);
		%find the two points with maximal distance from the intersection
			%positions & distances
				[y,x]	= find(bAround);
				
				if numel(y)<2
					continue;
				end
				
				d		= sqrt((y-yI(kI)).^2 + (x-xI(kI)).^2);
			%only consider points on the exterior border
				bExt	= d>=opt.tension_radius-2;
				
				if ~any(bExt(:))
					continue;
				end
			%first one is just farthest away from the intersection point
				k1	= find(bExt & d==max(d(bExt)),1);
			%second one has maximum minimum distance to other two
				d2		= sqrt((y-y(k1)).^2 + (x-x(k1)).^2);
				dMin	= min(d,d2);
				k2		= find(bExt & dMin==max(dMin(bExt)),1);
				
				%opt.bt = false(sz); opt.bt(y(k1),x(k1))=true; opt.bt(y(k2),x(k2))=true; opt.bt(yI(kI),xI(kI))=true; imshow(double(cat(3,opt.bt,opt.bt,bAround)))
		%construct an arc that passes through the two points along with another
		%point between the intersection point and the midpoint of the line
		%connecting the two points
			%mid-point
				yMid	= (y(k1)+y(k2))/2;
				xMid	= (x(k1)+x(k2))/2;
			%third circle point
				W	= 1/3;
					
				y3	= yMid*(1-W) + yI(kI)*W;
				x3	= xMid*(1-W) + xI(kI)*W;
			%make sure we got something reasonable
				d12	= sqrt((y(k1)-y(k2))^2 + (x(k1)-x(k2))^2);
				dM3	= sqrt((yMid-y3)^2 + (xMid-x3)^2);
				
				if dM3>d12/2
					dMI	= sqrt((yMid-yI(kI))^2 + (xMid-xI(kI))^2);
					
					W	= (d12/3)/dMI;
					
					y3	= yMid*(1-W) + yI(kI)*W;
					x3	= xMid*(1-W) + xI(kI)*W;
				end
				
				%bt = false(sz); bt(y(k1),x(k1))=true; bt(y(k2),x(k2))=true; bt(yI(kI),xI(kI))=true; bt(round(y3),round(x3))=true;
				%imshow(double(cat(3,bt,bt,bAround)))
			%center of the circle (taken from http://paulbourke.net/geometry/circlesphere/)
				if x3==x(k1)
					ma	= (y3-y(k1))./eps;
				else
					ma	= (y3-y(k1))./(x3-x(k1));
				end
				
				if x3==x(k2)
					mb	= (y(k2)-y3)./eps;
				else
					mb	= (y(k2)-y3)./(x(k2)-x3);
				end
				
				%make sure something weird isn't going on
					if isnan(ma) || isnan(mb) || isinf(ma) || isinf(mb) || ma==mb || ma==0
						%warning(['weird slopes! (kI=' num2str(kI) ')']);
						continue;
					end
				
				xc	= (ma*mb*(y(k1)-y(k2)) + mb*(x(k1)+x3) - ma*(x3+x(k2)))./(2*(mb-ma));
				yc	= -(xc-(x(k1)+x3)/2)/ma + (y(k1)+y3)/2;
				
				%bt = false(sz); bt(y(k1),x(k1))=true; bt(y(k2),x(k2))=true; bt(yI(kI),xI(kI))=true; bt(round(y3),round(x3))=true; bt(round(yc),round(xc))=true;
				%imshow(double(cat(3,bt,bt,bAround)))
				
				r	= sqrt((y3-yc).^2 + (x3-xc).^2);
			%calculate the other points along the arc
				y1Off	= y(k1)-yc;
				x1Off	= x(k1)-xc;
				y2Off	= y(k2)-yc;
				x2Off	= x(k2)-xc;
				
				a1	= atan2(y1Off,x1Off);
				a2	= atan2(y2Off,x2Off);
				
				aMin	= min(a1,a2);
				aMax	= max(a1,a2);
				da		= distAngle(a1,a2);
				
				if (aMax-aMin) - da > eps
					a1	= aMin;
					a2	= aMin - da;
				else
					a1	= aMin;
					a2	= aMax;
				end
				
				a	= GetInterval(a1,a2,round(abs(10*r*da)))';
				
				yArc	= r.*sin(a) + yc;
				xArc	= r.*cos(a) + xc;
				pArc	= unique([round(yArc) round(xArc)],'rows');
				yArc	= pArc(:,1);
				xArc	= pArc(:,2);
				
				bArc		= false(sz);
				kArc		= sub2ind(sz,yArc,xArc);
				bArc(kArc)	= true;
		%replace the intersection with the arc
			bOld		= b;
			
			b(bAround)	= false;
			b(bArc)		= true;
			
			%ShowDebug(bOld,b);
		%if we've made a hole, just revert
			[yNew,xNew]	= find(bArc,1);
			
			if ~any(bArc(:)) || MadeAHole(b,bOld,yNew,xNew,yI(kI),xI(kI))
				b	= bOld;
			end
			
			%ShowDebug([bOld&b b],[b&~bOld b],[bOld&~b b])
	end

%------------------------------------------------------------------------------%
function b = MadeAHole(bNew,bOld,yNew,xNew,yOld,xOld)
%bNew:	the altered image
%bOld:	the original image
%x/y:	points on the new and the old object that is being altered
%there should be substantial overlap between the new and old filled images
	%new
		L				= bwlabeln(bNew);
		r				= regionprops(L==L(yNew,xNew),'FilledImage','BoundingBox');
		r.BoundingBox	= r.BoundingBox + [0.5 0.5 0 0];
		
		if r.BoundingBox(1)==1
			r.FilledImage(:,1)	= true;
		end
		if r.BoundingBox(2)==1
			r.FilledImage(1,:)	= true;
		end
		if r.BoundingBox(1)+r.BoundingBox(3)-1==size(bNew,2)
			r.FilledImage(:,end)	= true;
		end
		if r.BoundingBox(2)+r.BoundingBox(4)-1==size(bNew,1)
			r.FilledImage(end,:)	= true;
		end
		
		obj		= getfield(regionProps(r.FilledImage,'FilledImage'),'FilledImage');
		nNew	= sum(obj(:));
	%old
		L				= bwlabeln(bOld);
		r				= regionprops(L==L(yOld,xOld),'FilledImage','BoundingBox');
		r.BoundingBox	= r.BoundingBox + [0.5 0.5 0 0];
		
		if r.BoundingBox(1)==1
			r.FilledImage(:,1)	= true;
		end
		if r.BoundingBox(2)==1
			r.FilledImage(1,:)	= true;
		end
		if r.BoundingBox(1)+r.BoundingBox(3)-1==size(bNew,2)
			r.FilledImage(:,end)	= true;
		end
		if r.BoundingBox(2)+r.BoundingBox(4)-1==size(bNew,1)
			r.FilledImage(end,:)	= true;
		end
		
		obj		= getfield(regionProps(r.FilledImage,'FilledImage'),'FilledImage');
		nOld	= sum(obj(:));
	
	b	= nNew<0.8*nOld;
end
%------------------------------------------------------------------------------%
function ShowDebug(varargin)
	imshow(double(cat(3,varargin{:},repmat(zeros(size(varargin{1})),[1 1 3-nargin]))));
end
%------------------------------------------------------------------------------%


end
