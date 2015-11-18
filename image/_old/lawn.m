function [im,b] = lawn(s,n,varargin)
% lawn
% 
% Description:	make a lawn image (i.e. lots of blades of grass)
% 
% Syntax:	[im,b] = lawn(s,n,<options>)
% 
% In:
% 	s	- the size of the base out of which the blades are growing, in pixels
%	n	- the number of blades to draw
%	<options>:
%		see grass
% 
% Out:
% 	im	- the lawn image
%	b	- the lawn mask
% 
% Updated: 2013-04-17
% Copyright 2013 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'background'	, [0 0 0]	  ...
		);

xMin	= 1;
xMax	= s;

bg		= reshape(opt.background,1,1,3);

for k=1:n
	if k==1
		[im,b]	= grass(varargin{:});
		[h,w,c]	= size(im);
		
		continue;
	end
	
	%get the grass image
		[imG,bG,optG]	= grass(varargin{:});
		[hG,wG]			= size(bG);
	%insert it into the lawn
		sG	= round(randBetween(xMin,xMax));
		
		%grow the lawn image
			if hG>h
				im	= [repmat(bg,[hG-h w 1]); im];
				b	= [false(hG-h,w); b];
				h	= size(im,1);
			end
			
			if optG.direction=='r' && sG+wG>w
				im	= [im repmat(bg,[h sG+wG-w 1])];
				b	= [b false(h,sG+wG-w)];
				w	= size(im,2);
			end
			
			if optG.direction=='l' && wG>sG
				im		= [repmat(bg,[h wG-sG 1]) im];
				b		= [false(h,wG-sG) b];
				w		= size(im,2);
				xMin	= xMin + wG-sG;
				xMax	= xMax + wG-sG;
				sG		= wG;
			end
		%insert
			switch optG.direction
				case 'l'
					im	= InsertImage(im,imG,[h-hG+1 sG-wG+1],'alpha',bG);
				case 'r'
					im	= InsertImage(im,imG,[h-hG+1 sG],'alpha',bG);
			end
end
