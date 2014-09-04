function [r,bKeep] = rDelete(r,varargin)
% REGIONDELETE
% 
% Description:	delete regions in a regionprops struct
% 
% Syntax:	[r,bKeep] = rDelete(r,method1,thresh11,...thresh1k,...,methodN,threshN1,...,threshNj)
%
% In:
%	r		- a regionprops struct
%	methodK	- 'area_min': 		deletes regions with small areas
%					thresh		- the minimum area
%				REQUIRES:
%					Area
%			  'frac_exist_x':	deletes regions that don't have pixels at
%								the specified fractional x value
%					xFrac		- the fractional x value
%					s			- the size of the binary image
%				REQUIRES:
%					Extrema
%			  'frac_exist_y':	delete regions that don't have pixels at
%								the specified fractional y value
%					yFrac		- the fractional y value
%					s			- the size of the binary image
%				REQUIRES:
%					Extrema
%			  'not_in_center':	delete regions whose bounding boxes aren't partially
%								inside the bounding boxes of regions that cross both
%								mid-lines
%					s			- the size of the binary image
%				REQUIRES:
%					BoundingBox, Extrema
% 
% Out:
%	r		- the culled regionprops struct
%	bKeep	- a binary array specifying the elements of r that were kept
%
% Notes: if you pass a set of deletion arguments in a cell, all conditions must
%		 call for deletion before a region will be deleted.
%
% Copyright 2006 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
if isequal(varargin{1},'DOKEEP')
	bDoKeep		= true;
	bKeep		= logical(zeros(size(r)));
	varargin	= varargin(2:end);
else
	bDoKeep		= false;
	bKeep		= logical(ones(size(r)));
end

nArg	= numel(varargin);

k	= 1;
while k~=-1
	[dMethod,k]	= getNextArgs(varargin,k);
	
	if iscell(dMethod)
		r	= rDelete(r,'DOKEEP',dMethod{:});
	else
		switch lower(dMethod)
			case 'area_min'
				[thresh,k]	= getNextArgs(varargin,k);
				
				toDelete	= [r.Area] < thresh;
			case 'frac_exist_x'
				[xFrac,s,k]	= getNextArgs(varargin,k);
				
				%find the x extrema
					ext		= [r.Extrema];
					xExt	= ext(:,1:2:end);
					
					xL	= xExt(7:8,:);
					xR	= xExt(3:4,:);
					
					xL	= min(xL) ./ s(2);
					xR	= max(xR) ./ s(2);
					
				toDelete	= xL>xFrac | xR<xFrac;
			case 'frac_exist_y'
				[yFrac,s,k]	= getNextArgs(varargin,k);
				
				%find the y extrema
					ext		= [r.Extrema];
					yExt	= ext(:,2:2:end);
					
					yT	= yExt(1:2,:);
					yB	= yExt(5:6,:);
					
					yT	= min(yT) ./ s(1);
					yB	= max(yB) ./ s(1);
					
				toDelete	= yT>yFrac | yB<yFrac;
			case 'not_in_center'
				[s,k]	= getNextArgs(varargin,k);
				
				r1		= rDelete(r,'frac_exist_x',0.5,s,'frac_exist_y',0.5,s);
				nBBC	= numel(r1);
				nBB		= numel(r);
				
				bbC				= [r1.BoundingBox];
				%reshape the bb array so each bbC is ordered along 1D and each
				%component of the bbC is ordered along 3D
				bbC				= reshape(bbC,4,[]);
				bbC				= permute(bbC,[2 3 1]);
				%elements 3 and 4 are width and height.  make them right and bottom
				bbC(:,:,3:4)	= bbC(:,:,1:2) + bbC(:,:,3:4) - 1;
				
				%order these bb's along 2D
				bb			= [r.BoundingBox];
				bb			= reshape(bb,4,[]);
				bb			= permute(bb,[3 2 1]);
				bb(:,:,3:4)	= bb(:,:,1:2) + bb(:,:,3:4) - 1;
				
				%repmat so we can compare
				bbC	= repmat(bbC,[1 nBB 1]);
				bb	= repmat(bb,[nBBC 1  1]);
				
				%make sure Lbb < Rbbc, Tbb < Bbbc, Lbbc < Rbb, Tbbc < Bbb
				comp			= logical(zeros(size(bb)));
				comp(:,:,1:2)	= bb(:,:,1:2) < bbC(:,:,3:4);
				comp(:,:,3:4)	= bb(:,:,3:4) > bbC(:,:,1:2);
				comp			= all(comp,3);
				
				%a region is counted as in the center if it is partially
				%inside any of the center regions
				toDelete	= ~any(comp,1);
			otherwise
				error('Invalid deletion method.');
		end
		
		if bDoKeep
			bKeep(~toDelete)	= 1;
		else
			bKeep(toDelete)		= 0;
			r(toDelete)	= [];
		end
	end
end

if bDoKeep
	r	= r(bKeep);
end
