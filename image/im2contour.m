function [y,x] = im2contour(b,varargin)
% im2contour
% 
% Description:	reconstruct a contour from a binary contour image
% 
% Syntax:	[y,x] = im2contour(b,<options>)
% 
% In:
% 	b	- a binary contour image, such as that returned by contour2im
%	<options>:
%		seed:	(<auto>) a point on the contour (as [y x])
%		gap:	(0) the maximum gap size to allow
% 
% Out:
% 	y	- the y values of the contour
%	x	- the x values of the contour
% 
% Updated: 2015-11-16
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%parse the inputs
	opt	= ParseArgs(varargin,[],[],...
			'seed'	, []	, ...
			'gap'	, 0		, ...
			'debug'	, false	  ...
			);
	
	[sY,sX]	= size(b);

[y,x]	= deal([]);

%get the seed point
	if isempty(opt.seed)
		[ySeed,xSeed]	= find(b,1);
		
		if isempty(ySeed)
			return;
		end
	else
		ySeed	= opt.seed(1);
		xSeed	= opt.seed(2);
	end
%follow the seed point until we run out of contour
	if opt.debug
		bDebug	= false(size(b));
	end
	
	bFound	= true;
	
	[yCur,xCur]		= deal(ySeed,xSeed);
	[yLast,xLast]	= deal([]);
	while bFound
		y	= [y; yCur];
		x	= [x; xCur];
		
		b(yCur,xCur)	= false;
		
		if opt.debug
			bDebug(yCur,xCur)	= true;
			
			imshow(double(cat(3,b,bDebug,false(size(b)))));
			
			drawnow
			WaitSecs(0.001);
		end
		
		bFound	= false;
		for g=1:opt.gap+1
			%get the neighborhood to look in
				dGap	= 2*g+1;
				bN		= MaskCircle(dGap);
				[yR,xR]	= find(bN);
				[yR,xR]	= varfun(@(x) x-g-1,yR,xR);
			%get the neighborhood
				yN	= yCur + yR;
				xN	= xCur + xR;
				bIn	= yN>0 & yN<=sY & xN>0 & xN<=sX;
				
				[yN,xN]	= varfun(@(x) x(bIn),yN,xN);
				kN		= sub2ind([sY sX],yN,xN);
			%find a neighborhood point on the contour
				kNew	= find(b(kN));
				
				if ~isempty(kNew)
					%keep the point that makes the shallowest angle with the
					%last two points
						if ~isempty(yLast) && numel(kNew)>1
							a		= angle3point([xCur yCur],[xLast yLast],[xN(kNew) yN(kNew)]);
							kBest	= find(a==max(a),1);
						else
							kBest	= 1;
						end
					
					[yLast,xLast]	= deal(yCur,xCur);
					[yCur,xCur]		= deal(yN(kNew(kBest)),xN(kNew(kBest)));
					bFound			= true;
					
					break;
				end
		end
		
		if ~bFound
			if opt.debug
				disp('done');
				WaitSecs(0.1);
			end
			
			break;
		end
	end
