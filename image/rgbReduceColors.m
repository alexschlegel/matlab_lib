function rgb = rgbReduceColors(rgb,n,varargin)
% rgbReduceColors
% 
% Description:	reduce the number of colors in an image to n colors or to the
%				colors specified in 3xN array map
% 
% Syntax:	rgb = rgbReduceColors(rgb,n,[blur_sigma]=0.5,[r_medfilt]=5,...
%					[n_medfilt]=1) OR
%			rgb = rgbReduceColors(rgb,map,...)
%
% Copyright 2008 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
[blur_sigma,r_medfilt,n_medfilt]	= ParseArgs(varargin,0.5,5,1);

bUINT	= isa(rgb,'uint8');

bMedFilt	= r_medfilt~=0;
if bMedFilt && isscalar(r_medfilt)
	r_medfilt	= [r_medfilt r_medfilt];
end

[rgbInd,map]	= rgb2ind(rgb,n,'nodither');
nCol			= size(map,1);

if bUINT
	map	= uint8(255*map);
end

bChannel			= {};
[bChannel{1:nCol}]	= deal(logical(zeros(size(rgbInd))));

kColor = reshape(unique(rgbInd),1,[]);

%assume light colors on dark background, avoid borders between colors
	[kColor,kSort]	= sort(kColor);
	map				= map(kSort,:);
	bChannel		= bChannel(kSort);
	bChannel{nCol}(rgbInd==kColor(nCol))	= 1;
	for k=nCol-1:-1:1
		bChannel{k}(rgbInd==kColor(k) | bChannel{k+1}==1)	= 1;
	end
	
%blur each color channel
	s	= round(max(3,3*blur_sigma));
	f	= fspecial('gaussian',[s s],blur_sigma);
	wb	= waitbar(0,'Blurring channels');
	for k=1:nCol
		bChannel{k}		= round(imfilter(double(bChannel{k}),f,'replicate'));
		if bMedFilt
			for km=1:n_medfilt
				bChannel{k}	= medfilt2(bChannel{k},r_medfilt,'symmetric');
			end
		end
		bChannel{k}		= logical(bChannel{k});
		waitbar(k/nCol,wb);
	end
	close(wb);

%convert back to an rgb image
%too memory intensive
% 	rgbInd(:)	= 0;
% 	for k=1:nCol
% 		rgbInd(bChannel{k})	= kColor(k);
% 	end
% 	rgb	= ind2rgb(rgbInd,map);
	s	= size(rgbInd);
	rgb	= {};
	if bUINT
		[rgb{1:3}]	= deal(uint8(zeros(s)));
	else
		[rgb{1:3}]	= deal(zeros(s));
	end
	wb	= waitbar(0,'Constructing image');
	for k=1:nCol
		for kChannel=1:3
			rgb{kChannel}(bChannel{k})	= map(k,kChannel);
		end
		
		waitbar(k/nCol,wb);
	end
	close(wb);
	rgb	= cat(3,rgb{1},rgb{2},rgb{3});
	