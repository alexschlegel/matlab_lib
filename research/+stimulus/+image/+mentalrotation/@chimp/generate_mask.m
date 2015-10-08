function [mask,ifo] = generate_mask(obj,ifo)
% stimulus.image.mentalrotation.chimp.generate_mask
% 
% Description:	generate the mr chimp mask
% 
% Syntax: [mask,ifo] = obj.generate_mask(ifo)
% 
% In:
%	ifo	- the info struct
% 
% Out:
%	mask	- the binary mr chimp image
%	ifo		- the updated info struct
% 
% Updated:	2015-10-06
% Copyright 2015 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%generate the untransformed stimulus
	stim	= obj.stim_param.stim{ifo.param.figure};
	
	%size of the stimulus, in pixels
		hStim	= ifo.param.size(1);
		wStim	= round(hStim/2);
	%thickness of lines, in points
		tLine	= 12;
	
	%conversion from pixels to axis units
		px2axX	= 2/wStim;
		px2axY	= 4/hStim;
	%conversion from points to pixels
		hF	= figure('visible','off');
		set(hF,'Position',[50 50 wStim hStim]);
		hA	= axes('Units','pixels');
		set(hA,'Position',[0 0 1 1]);
		set(hA,'Units','points')
		pos	= get(hA,'Position');
		delete(hF);
		pt2px	= 1/pos(3);
	%conversion from points to axis units
		pt2axX	= pt2px*px2axX;
		pt2axY	= pt2px*px2axY;
	%axis limits, to make sure we don't cut off widths
		xAdd	= tLine*pt2axX/2;
		yAdd	= tLine*pt2axY/2;
		
		xLim	= [-xAdd 2+xAdd];
		yLim	= [-yAdd 4+yAdd];
	
	x		= stim{1};
	y		= stim{2};
	y		= 4 - y;
	nLine	= size(y,1);
	
	%fix the line ends
		for kL=1:nLine
			%vertical lines
				if x(kL,1)==x(kL,2)
					bMin		= y(kL,:)==min(y(kL,:));
					y(kL,bMin)	= y(kL,bMin) - yAdd;
					y(kL,~bMin)	= y(kL,~bMin) + yAdd;
				end
			%horizontal lines
				if y(kL,1)==y(kL,2)
					bMin		= x(kL,:)==min(x(kL,:));
					x(kL,bMin)	= x(kL,bMin) - xAdd;
					x(kL,~bMin)	= x(kL,~bMin) + xAdd;
				end
		end
	
	%draw the figure
		hF	= figure('visible','off');
		set(hF,'Position',[50 50 wStim hStim]);
		
		hA	= axes;
		set(hA,'Position',[0 0 1 1],'XTick',[],'YTick',[],'XColor',[1 1 1],'YColor',[1 1 1],'xLim',xLim,'yLim',yLim);
		
		hL	= line(x',y','Color',[0 0 0],'LineWidth',tLine);
	
	%save and load the image
		mask	= fig2png(hF);
	
	%resize the image and make sure it is monochrome
		mask	= imresize(mask,[hStim+2 wStim+2],'nearest');
		mask	= round(mask);
	
	%fill in the holes
		maskOrig	= logical(mask(:,:,1));
		%bBorder	= imPad(bOrig,true,hStim+2,wStim+2);
		%bFill	= ~imfill(~bBorder,'holes');
		maskFill	= ~imfill(~maskOrig,'holes');
		mask		= ~maskFill(2:end-1,2:end-1);

%perform the indicated transformation
	nTX	= numel(ifo.param.txParsed);
	
	for kTX=1:nTX
		op	= ifo.param.txParsed{kTX}.op;
		p	= str2num(ifo.param.txParsed{kTX}.param);
		
		switch op(1)
			case 'R' %rotate
				mask	= imrotate(mask,p,'nearest');
			case 'F' %flip
				switch op(2)
					case 'H'
						mask	= mask(:,end:-1:1);
					case 'V'
						mask	= mask(end:-1:1,:);
					otherwise
						error('malformed transform string.');
				end
			otherwise
				error('malformed transform string.');
		end
	end
