function im = Text2Image(str,h,varargin)
% Text2Image
% 
% Description:	convert text to an image
% 
% Syntax:	im = Text2Image(str,h,[w]=<auto>,<options>)
% 
% In:
% 	str	- the string to convert
%	h	- the height of the image, in pixels
%	[w]	- the width of the image, in pixels
%	<options>:
%		force_h:		(false) true to force the height of the string to be
%						exactly the specified height
%		font_name:		('Helvetica') the font name
%		font_weight:	('normal') the font weight (see text properties)
%		color:			([0 0 0]) the text color
%		background:		([1 1 1]) the background color
% 
% Out:
% 	im	- the text as an image
% 
% Side-effects:	briefly opens a figure window
% 
% Assumptions:	assumes one line of text that will fit on the screen at the
%				200% of the specified size
% 
% Updated: 2010-10-16
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
[w,opt]	= ParseArgs(varargin,[],...
			'force_h'		, false			, ...
			'font_name'		, 'Helvetica'	, ...
			'font_weight'	, 'normal'		, ...
			'color'			, [0 0 0]		, ...
			'background'	, [1 1 1]		  ...
			);

bGrayscale	= numel(opt.color==1);
if bGrayscale
	opt.color		= repmat(opt.color,[1 3]);
	opt.background	= repmat(opt.background,[1 3]);
end

%create the figure, axes, and text
	fScale	= 2;
	sScreen	= get(0,'ScreenSize');
	hF		= figure('Position',sScreen,'Visible','off');
	hA		= axes('Units','normalized','Position',[0 0 1 1],'color',[0 0 0],'XTick',[],'YTick',[],'XColor',[0 0 0],'YColor',[0 0 0]);
	im		= text(sScreen(3)/2,sScreen(4)/2,str,'HorizontalAlignment','center','Units','pixels','color',[1 1 1],'FontSize',fScale*h,'FontName',opt.font_name,'FontWeight',opt.font_weight,'FontUnits','pixels');
%convert the figure to an image
	im	= Figure2Image(hF);
%close the figure
	close(hF);
%extract the text
	im	= round(im2double(im(:,:,1)));

	kY	= find(any(im,2));
	kX	= find(any(im,1));
	
	im	= im(min(kY):max(kY),min(kX):max(kX));
%resize
	if isempty(w)
		if opt.force_h
			hCur	= size(im,1);
			im		= imresize(im,h/hCur,'nearest');
		else
			im	= imresize(im,1/fScale,'nearest');
		end
	else
		if opt.force_h
			im	= imresize(im,[h w],'nearest');
		else
			im	= imresize(im,1/fScale,'nearest');
			im	= imresize(im,[size(im,1) w],'nearest');
		end
	end
%convert to the desired colors
	im	= ind2rgb(im+1,[opt.background;opt.color]);
	if bGrayscale
		im	= im(:,:,1);
	end
	