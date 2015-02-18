function im = ind2im(idx,map)
% ind2im
% 
% Description:	a generalization of ind2rgb to handle grayscale and rgba maps
% 
% Syntax:	im = ind2im(idx,map)
% 
% In:
% 	idx	- the 2D index image
%	map	- an NxM map of N M-dimensional colors 
% 
% Out:
% 	im	- the M-plane mapped image
% 
% Updated: 2015-01-12
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
sz		= size(idx);
[N,M]	= size(map);

%not really sure what this is for, but it's in ind2rgb
%switch to one based indexing
	if ~isfloat(idx)
		idx = double(idx)+1;
	end

%make sure idx is in the range from 1 to size(map,1)
	idx = max(1,min(idx,N));

%initialize the image
	im	= zeros([sz M]);

%extract the color components
	for kM=1:M
		im(:,:,kM)	= reshape(map(idx,kM),sz);
	end
