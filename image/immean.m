function col = immean(im,msk)
% immean
% 
% Description:	get the mean image color within a mask
% 
% Syntax:	col = immean(im,msk)
% 
% Updated: 2014-02-05
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
p	= size(im,3);

col	= NaN(1,p);
for k=1:p
	imPlane	= im(:,:,k);
	col(k)	= mean(imPlane(msk));
end
