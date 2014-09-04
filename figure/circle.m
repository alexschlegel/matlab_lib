function hC = circle(varargin)
% circle
% 
% Description:	add a line to a plot
% 
% Syntax:	hC = circle(x,y,r,[ax]=gca,...)
% 
% In:
% 	x	- the x-value of the circle center
%	y	- the y-value of the circle center
%	r	- the circle radius
%	ax	- the handle of the axes on which to plot the circle
%	...	- additional arguments to the plot function
% 
% Out:
% 	hC	- a handle to the circle plot object
% 
% Updated: 2012-01-01
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
if nargin>3 && ishandle(varargin{4})
	[xC,yC,r,ax]	= deal(varargin{1:4});
	varargin		= varargin(5:end);
else
	ax			= gca;
	[xC,yC,r]	= deal(varargin{1:3});
	varargin	= varargin(4:end);
end

a	= GetInterval(0,2*pi+pi/10,1000)';
r	= repmat(r,size(a));

x	= xC + r.*cos(a);
y	= yC + r.*sin(a);

bHold	= ishold;
if ~bHold
	hold on;
end

plot(ax,x,y,varargin{:});

if ~bHold
	hold off;
end
