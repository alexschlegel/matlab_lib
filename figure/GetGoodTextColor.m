function colText = GetGoodTextColor(col)
% GetGoodTextColor
% 
% Description:	get a good text color to go on top of color col (1x3 double)
% 
% Syntax:	colText = GetGoodTextColor(col)
% 
% Updated:	2014-02-02
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

col	= str2rgb(col);
hsl	= rgb2hsl(col);

%colText	= [1 1 1] * (hsl(3)<0.5);
colText	= double([1 1 1] .* sqrt(sum([0.241 0.691 0.068].*col.^2))<0.5);
