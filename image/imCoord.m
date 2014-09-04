function im = imCoord(im,coords,varargin)
% imCoord
%
% Description:	mark coordinates on an image
%
% Syntax:	im = imCoord(im,coords,[tl]=[1 1],[hw]=<size of image>,[imIcon]=[0])
%
% In:
%	im			- an image array
%	coords		- an Nx2 array of coordinates to mark on the image
%	[tl]		- a two element array specifying the top-left coordinates of the
%				  image
%	[hw]		- a two element array specifying the height and width of the image
%				  in coordinate units
%	[imIcon]	- the image to place at each coordinate
%
% Example:	imCoord(ones(100),[0.25 0.25;0.75 0.75],[0 0],[1 1])
% 
% Assumptions: assumes images are either double or uint8
%
% Updated:	2008-06-18
% Copyright 2008 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
sIm		= size(im);

[tl,hw,imIcon]	= ParseArgs(varargin,[1 1],sIm(1:2),uint8(0));

%convert the images to uint8; we'll convert back at the end of necessary
	[im,bDouble]	= im2uint8(im);
	imIcon			= im2uint8(imIcon);

%get image dimensions
	ndIm	= numel(sIm);
	
	sIcon	= size(imIcon);
	ndIcon	= numel(sIcon);

	hIm		= sIm(1);
	wIm		= sIm(2);
	
	hIcon	= sIcon(1);
	wIcon	= sIcon(2);
	hIcon2	= hIcon/2;
	wIcon2	= wIcon/2;

%make the image and the icon compatible
	switch ndIm
		case 2
			switch ndIcon
				case 3
					imIcon	= im2uint8(rgb2g(im2double(imIcon)));
			end
		case 3
			switch ndIcon
				case 2
					imIcon	= repmat(imIcon,[1 1 3]);
			end
	end

%convert the coordinates to array indices
	nCoords	= size(coords,1);
	tl		= reshape(tl,[1 2]);
	hw		= reshape(hw,[1 2]);
	
	%set zero point as the upper left
		coords	= coords - repmat(tl, [nCoords 1]);
	%scale to the size of the image
		coords	= coords .* repmat([hIm wIm] ./ hw, [nCoords 1]);
	%set the upper left to [1 1]
		coords	= coords + 1;
		
%add the icon at each coordinate point
	for kCoord=1:nCoords
		imIconCur	= imIcon;
		
		tMin		= round(coords(kCoord,1)-hIcon2);
		tMax		= tMin + hIcon - 1;
		if tMin<1
			imIconCur	= imIconCur(1+(1-tMin):end,:,:);
			tMin		= 1;
		end
		if tMax>hIm
			imIconCur	= imIconCur(1:end-(tMax-hIm),:,:);
			tMax		= hIm;
		end
		
		lMin		= round(coords(kCoord,2)-wIcon2);
		lMax		= lMin + wIcon - 1;
		if lMin<1
			imIconCur	= imIconCur(:,1+(1-lMin):end,:);
			lMin		= 1;
		end
		if lMax>wIm
			imIconCur	= imIconCur(:,1:end-(lMax-wIm),:);
			lMax		= wIm;
		end
		
		im(tMin:tMax,lMin:lMax,:)	= imIconCur;
	end

%convert back if necessary
	if bDouble
		im	= im2double(im);
	end
