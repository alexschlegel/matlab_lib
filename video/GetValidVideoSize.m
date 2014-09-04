function [h,w] = GetValidVideoSize(h,w,varargin)
% GetValidVideoSize
% 
% Description:	get a video size close to the input size that is valid for
%				creating videos
% 
% Syntax:	[h,w] = GetValidVideoSize(h,w,[strTypeValid]='any',[aValid]=[3 4; 9 16])
% 
% In:
% 	h				- the desired video height
%	w				- the desired video width
%	[strTypeValid]	- 'smaller' to return the closest video size that will fit
%					  inside the input size, 'larger' for the closest video size
%					  that contains the input video size, and 'any' for the
%					  video size with the closest area to the input video size
%	[aValid]		- an array specifying valid aspect ratios.  should be an
%					  N x 2 array of [height width] ratios
% 
% Out:
% 	h	- the valid height
%	w	- the valid width
% 
% Updated:	2009-03-20
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
[strTypeValid,aValid]	= ParseArgs(varargin,'any',[3 4; 9 16]);

%valid aspect ratios
	rValid	= aValid(:,1)./aValid(:,2);
%get a valid pair
	%input ratio
		rIn	= h/w;
	%is the pair valid already?
		%does it have a valid ratio?
			[bRatio,kRatio]	= ismember(rIn,rValid);
		%are the dimensions integer multiples of the ratio base?
			if bRatio
				hByN	= h/aValid(kRatio,1);
				wByD	= w/aValid(kRatio,2);
				if hByN==floor(hByN) && wByD==floor(wByD)
					return;
				end
			end
	
	%nope
		%get the ratio it's closest to
			rDiff	= abs(rValid-rIn);
			kRatio	= find(rDiff==min(rDiff),1,'first');
			rOut	= rValid(kRatio);
		%get the closest size given the constraints
			switch lower(strTypeValid)
				case 'smaller'
					%find the rectangle at the correct ratio with each dimension
					%closest to but at least as large as the input dimension
						aMult	= 2*floor(min([h w]./aValid(kRatio,:))/2);
				case 'larger'
					%find the rectangle at the correct ratio with each dimension
					%closest to but at least as large as the input dimension
						aMult	= 2*ceil(max([h w]./aValid(kRatio,:))/2);
				case 'any'
					%find the rectangle at the correct ratio with smallest area
					%difference and dimensions that are integer multiples of the
					%base ratio
						%base area
							aRatioBase	= prod(aValid(kRatio,:));
						%dimension multiplier for the input size
							aMult		= sqrt(h*w/aRatioBase);
						%get a valid multiplier.  must be a multiple of 2
							aMult	= 2*round(aMult/2);
				otherwise
					error(['"' strTypeValid '" is not a valid argument.']);
			end
			
			%valid dimensions
				h	= aValid(kRatio,1)*aMult;
				w	= aValid(kRatio,2)*aMult;
