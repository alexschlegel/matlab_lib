function x = cropborder(x,varargin)
% cropborder
% 
% Description:	crop the border off an array
% 
% Syntax:	x = cropborder(x,[vBorder]=<auto>)
% 
% In:
% 	x			- an array
%	[vBorder]	- the border value
% 
% Out:
% 	x	- x with the border cropped
% 
% Updated: 2012-07-07
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
vBorder	= ParseArgs(varargin,[]);

if isempty(vBorder)
	vBorder	= mode(perimeter(x));
end

s	= size(x);
nd	= numel(s);

for kD=1:nd
	x	= permute(x,[kD 1:kD-1 kD+1:nd]);
	x	= reshape(x,s(kD),[]);
	
	bBorder	= all(x==vBorder,2);
	kFirst	= unless(find(~bBorder,1,'first'),s(kD));
	kLast	= unless(min(s(kD),find(~bBorder,1,'last')),1);
	
	x	= reshape(x(kFirst:kLast,:),[kLast-kFirst+1 s(1:kD-1) s(kD+1:end)]);
	x	= permute(x,[2:kD 1 kD+1:nd]);
	s	= size(x);
end
