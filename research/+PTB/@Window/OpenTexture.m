function hTexture = OpenTexture(win,strName,varargin)
% PTB.Window.OpenTexture
% 
% Description:	open a named texture
% 
% Syntax:	hTexture = win.OpenTexture(strName,[s]=<size of main window>) OR
%			hTexture = win.OpenTexture(strName,im)
%
% In:
%	strName	- the name of the texture
%	s		- the [w h] size of the texture, in pixels
%	im		- an image to use as the texture contents
% 
% Updated: 2012-07-04
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global PTBIFO;

h	= PTBIFO.window.h.main;

x	= ParseArgs(varargin,[]);
if isempty(x)
%use the full screen
	rect	= Screen('Rect',h);
	x		= rect(3:4) - rect(1:2);
end
if isequal(size(x),[1 2])
%size specified, make a blank image
	col	= win.parent.Color.Get('none');
	x	= repmat(reshape(col,1,1,[]),round([x(2) x(1) 1]));
else
	x		= im2uint8(x);
	nPlane	= size(x,3);
	
	switch nPlane
		case 1
			x	= cat(3,x,x,x,255*ones(size(x),'uint8'));
		case 3
			x	= cat(3,x,255*ones([size(x,1) size(x,2)],'uint8'));
		case 4
	end
end

if PTBIFO.window.closetextures
	hTexture	= Screen('MakeTexture',h,x);
			
	Screen('BlendFunction',hTexture,GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
else
	%check to see if we have any idle textures that match the image size
		s		= size(x);
		kMatch	= find(PTBIFO.window.texture.active==false & PTBIFO.window.texture.height==s(1) & PTBIFO.window.texture.width==s(2),1);
	%reassign or open a new texture
		if ~isempty(kMatch)
		%reassign an existing texture
			hTexture	= PTBIFO.window.texture.h(kMatch);
			
			Screen('BlendFunction',hTexture,GL_ONE,GL_ZERO);
			Screen('PutImage',hTexture,x);
			Screen('BlendFunction',hTexture,GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
			
			PTBIFO.window.texture.active(kMatch)	= true;
		else
		%make a new texture
			hTexture	= Screen('MakeTexture',h,x);
			
			Screen('BlendFunction',hTexture,GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
			
			PTBIFO.window.texture.active(end+1)	= true;
			PTBIFO.window.texture.height(end+1)	= s(1);
			PTBIFO.window.texture.width(end+1)		= s(2);
			PTBIFO.window.texture.h(end+1)			= hTexture;
		end
end

win.Set(strName,hTexture);
