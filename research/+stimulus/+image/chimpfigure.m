function [im,b,ifo] = chimpfigure(varargin)
% stimulus.image.chimpfigure
% 
% Description:	render a figure used for the chimp mental rotation study
% 
% Syntax:	[im,b,ifo] = stimulus.image.chimpfigure(<options>)
% 
% In:
%	<options>: (see also stimulus.image.common_defaults)
%		figure:	(<random>) the figure number (1-80)
%		tx:		('') a string specifying the transformations to perform on the
%				figure. takes the form '<x1>[<n1>] <x2>[<n2>] ... <xN>[<nN>]',
%				where <xK> is the operation and possible <nK> is the parameter
%				for the operation. possible operations are:
%					R:	rotate nK degrees
%					FH:	flip horizontally (no parameter)
%					FV:	flip vertically (no parameter)
%				e.g. 'R-90 FH' rotate -90 degrees then flip horizontally
% 
% Out:
%	im	- the stimulus image
% 	b	- a binary mask of the stimulus image
%	ifo	- a struct of info about the stimulus
% 
% Updated: 2015-09-24
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%get the stimulus parameters
		param	= Chimp_Param;
		nFigure	= numel(param.stim);

%default option values
	persistent cDefault;
	
	if isempty(cDefault)
		cDefault	=	{
							'figure'	, []	, ...
							'tx'		, ''	  ...
							};
	end

%generate the stimulus
	[im,b,ifo]	= stimulus.image.common_pipeline(...
					'vargin'		, varargin			, ...
					'defaults'		, cDefault			, ...
					'f_validate'	, @Chimp_Validate	, ...
					'f_mask'		, @Chimp_Mask		  ...
					);

%------------------------------------------------------------------------------%
function [opt,ifo] = Chimp_Validate(opt,ifo)
	%get the figure number
		if isempty(opt.figure)
			opt.figure	= randFrom(1:nFigure,'seed',false);
		end
		
		assert(isscalar(opt.figure) && isint(opt.figure) && opt.figure>=1 && opt.figure<=nFigure,'figure must be an integer between 1 and %d',nFigure);
	
	%parse the transformations
		opt.tx	= split(opt.tx,' ');
		opt.tx	= cellfun(@(tx) regexp(tx,'(?<op>(R|F[HV]))(?<param>[-]?\d*\.?\d*)','names'),opt.tx,'uni',false);
		
		assert(~any(cellfun(@isempty,opt.tx)),'malformed transform string');
	
	%info for the struct
		ifo.figure	= opt.figure;
		ifo.class	= param.class{opt.figure};
end
%------------------------------------------------------------------------------%
function [b,ifo] = Chimp_Mask(opt,ifo)
	%generate the untransformed stimulus
		stim	= param.stim{opt.figure};
		
		%size of the stimulus, in pixels
			hStim	= opt.size;
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
			strPathTemp	= GetTempFile('ext','png');
			fig2png(hF,strPathTemp);
			
			b	= imread(strPathTemp);
			
			delete(strPathTemp);
		
		%resize the image and make sure it is monochrome
			b	= imresize(b,[hStim+2 wStim+2],'nearest');
			b	= round(b);
		
		%fill in the holes
			bOrig	= logical(b(:,:,1));
			%bBorder	= imPad(bOrig,true,hStim+2,wStim+2);
			%bFill	= ~imfill(~bBorder,'holes');
			bFill	= ~imfill(~bOrig,'holes');
			b		= ~bFill(2:end-1,2:end-1);
	
	%perform the indicated transformation
		nTX	= numel(opt.tx);
		
		for kTX=1:nTX
			op	= opt.tx{kTX}.op;
			p	= str2num(opt.tx{kTX}.param);
			
			switch op(1)
				case 'R' %rotate
					b	= imrotate(b,p,'nearest');
				case 'F' %flip
					switch op(2)
						case 'H'
							b	= b(:,end:-1:1);
						case 'V'
							b	= b(end:-1:1,:);
						otherwise
							error('malformed transform string.');
					end
				otherwise
					error('malformed transform string.');
			end
		end
end
%------------------------------------------------------------------------------%
function param = Chimp_Param()
	persistent p;
	
	if isempty(p)
		%these coordinates encode lines on a 2x4 grid (1st array: x start->stop; 2nd
		%array: y start->stop)
			%y-balanced
				yBal	=	{
								{[0 2; 2 2; 0 2; 1 1; 0 2; 0 0; 0 1; 1 2]
								 [0 0; 0 2; 2 2; 1 4; 4 4; 2 3; 3 3; 1 1]}
								{[0 1; 1 1; 0 1; 0 0; 0 2; 2 2; 1 2; 0 1]
								 [0 0; 0 4; 1 1; 1 2; 2 2; 2 3; 3 3; 4 4]}
								{[2 2; 1 2; 1 1; 1 2; 0 1; 0 0; 1 2; 0 1]
								 [0 1; 1 1; 0 4; 2 2; 3 3; 3 4; 0 0; 4 4]}
								{[0 0; 0 1; 0 1; 1 1; 1 2; 1 2]
								 [0 4; 0 4; 4 4; 0 4; 0 0; 4 0]}
								{[0 1; 0 0; 0 1; 1 1; 0 1; 1 2]
								 [0 0; 0 3; 1 1; 1 4; 3 3; 4 4]}
								{[0 0; 0 1; 0 1; 1 1; 1 2; 2 2]
								 [1 4; 1 1; 3 3; 1 3; 2 2; 0 3]}
								{[1 2; 1 1; 1 2; 0 1; 0 1; 0 0; 2 2]
								 [0 0; 0 4; 1 1; 3 3; 4 4; 3 4; 0 3]}
								{[0 0; 0 2; 1 1; 0 1; 1 2; 2 2]
								 [0 2; 2 2; 1 4; 1 1; 3 3; 2 3]}
								{[0 2; 0 0; 0 1; 1 1; 0 1; 1 2; 2 2; 0 2]
								 [0 0; 0 1; 1 1; 0 4; 2 2; 3 3; 3 4; 4 4]}
								{[0 1; 0 0; 0 1; 0 2; 1 1; 1 2; 0 1; 2 2]
								 [0 0; 0 2; 1 1; 2 2; 1 4; 3 3; 4 4; 2 3]}
								{[0 0; 0 2; 1 1; 2 2; 0 2]
								 [0 4; 1 1; 3 4; 0 3; 3 3]}
								{[0 0; 0 2; 1 1; 2 2; 0 2; 2 2; 1 2; 1 2]
								 [1 2; 1 1; 0 4; 0 1; 2 2; 2 4; 4 4; 0 0]}
								{[1 2; 0 2; 2 2; 1 1; 0 1]
								 [0 0; 4 0; 0 4; 0 4; 4 4]}
								{[0 0; 0 1; 1 1; 0 2; 2 2]
								 [0 4; 4 4; 0 4; 0 0; 0 4]}
								{[0 0; 0 1; 0 1; 1 2; 1 2; 1 2; 1 2; 2 2]
								 [2 4; 2 0; 2 4; 0 0; 2 0; 2 4; 4 4; 0 2]}
								{[0 0; 0 1; 1 2; 0 1; 1 1]
								 [0 3; 1 1; 2 2; 3 3; 1 4]}
								{[1 1; 0 2; 0 2; 0 2; 2 2; 1 2; 2 2; 1 1; 1 2]
								 [0 1; 1 1; 3 1; 3 3; 3 4; 0 0; 0 1; 3 4; 4 4]}
								{[0 2; 0 0; 2 2; 0 2; 2 2; 1 1; 0 2; 1 2; 1 1; 1 2; 0 0]
								 [0 0; 0 2; 0 1; 2 2; 2 4; 3 4; 4 4; 3 3; 0 1; 1 1; 3 4]}
								{[0 0; 0 2; 1 1; 0 2; 0 2; 2 2]
								 [0 2; 1 1; 1 4; 2 2; 3 3; 2 3]}
								{[0 0; 0 2; 0 1; 1 1; 1 2; 2 2]
								 [0 4; 2 2; 3 3; 0 4; 1 1; 1 3]}
								...%{[0 0; 0 1; 1 2; 1 2; 2 2]
								...% [0 2; 2 2; 2 0; 2 4; 3 4]}
							};
			%x-balanced
				xBal	=	{
								{[0 1; 1 1; 0 2; 0 2; 0 0; 2 2; 1 2]
								 [0 0; 0 4; 2 2; 4 4; 0 2; 2 4; 1 1]}
								{[0 2; 0 0; 0 2; 2 2; 0 2; 0 2; 0 0]
								 [0 0; 0 2; 2 2; 1 4; 3 3; 4 4; 3 4]}
								{[0 2; 1 1; 2 2; 1 2; 0 0; 0 1; 0 2; 2 2]
								 [0 0; 0 4; 0 1; 1 1; 2 4; 3 3; 4 4; 3 4]}
								{[1 1; 0 1; 0 0; 0 1; 1 2; 2 2; 1 2]
								 [0 4; 1 1; 1 2; 2 2; 3 3; 3 4; 4 4]}
								{[0 2; 0 0; 0 1; 1 1; 0 2; 2 2; 1 2]
								 [0 0; 0 1; 1 1; 0 4; 3 3; 3 4; 4 4]}
								{[0 2; 1 1; 0 1; 0 0; 0 2; 2 2; 1 2]
								 [0 0; 0 4; 2 2; 2 3; 3 3; 3 4; 4 4]}
								{[2 2; 0 2; 0 0; 0 2; 0 2]
								 [0 3; 1 1; 1 4; 3 3; 4 4]}
								{[0 1; 0 0; 0 2; 2 2; 0 2; 1 2]
								 [0 1; 0 2; 2 2; 0 4; 4 4; 1 0]}
								{[0 1; 0 0; 1 1; 0 2; 2 2; 1 2; 0 1; 0 0; 0 1]
								 [0 0; 0 1; 0 4; 2 2; 2 4; 4 4; 1 1; 2 3; 3 3]}
								{[0 0; 0 1; 0 2; 2 2; 1 2; 1 1; 1 1; 1 2; 0 1]
								 [0 2; 1 1; 2 2; 2 4; 4 4; 1 2; 3 4; 3 3; 0 0]}
								{[0 2; 0 2; 0 2; 0 0; 2 2; 0 2]
								 [0 0; 2 0; 2 2; 2 4; 2 4; 4 4]}
								{[0 1; 0 2; 1 1; 0 2; 1 2]
								 [1 0; 1 1; 0 4; 2 2; 3 2]}
								{[0 2; 0 0; 0 2; 2 2; 0 2; 0 0]
								 [0 0; 0 1; 1 1; 0 3; 3 3; 2 4]}
								{[0 2; 0 0; 0 2; 2 2; 0 2]
								 [2 0; 2 4; 4 2; 0 2; 4 4]}
								{[0 2; 0 2; 0 2; 0 2; 0 0; 2 2]
								 [1 0; 1 2; 3 4; 4 4; 1 3; 2 4]}
								{[1 1; 0 2; 2 2; 0 2; 0 0]
								 [0 2; 2 2; 0 2; 4 0; 2 4]}
								{[0 1; 0 1; 1 1; 1 2; 1 2]
								 [0 0; 0 2; 0 4; 2 2; 4 2]}
								{[0 1; 0 1; 1 1; 0 0; 0 2; 2 2; 1 2; 1 2]
								 [0 0; 0 1; 0 4; 1 2; 2 2; 1 2; 3 3; 4 3]}
								{[0 0; 0 1; 1 1; 0 2; 2 2; 1 1; 1 2; 1 2; 0 1]
								 [0 4; 1 1; 1 2; 2 2; 0 4; 3 4; 4 4; 3 3; 0 0]}
								{[0 2; 0 0; 1 1; 2 2; 0 2; 1 2; 0 1]
								 [0 0; 0 1; 1 4; 0 1; 1 1; 2 2; 4 4]}
								...%{[0 1; 1 1; 1 2; 0 1; 1 2]
								...% [0 0; 0 2; 2 2; 4 2; 2 4]}
							};
			%y-symmetric
				ySym	=	{
								{[0 0; 0 2; 0 2; 2 2]
								 [0 4; 1 1; 3 3; 1 3]}
								{[0 2; 0 0; 2 2; 1 2; 1 2; 2 2; 0 2; 1 1; 1 1]
								 [0 0; 0 4; 0 1; 1 1; 3 3; 3 4; 4 4; 0 1; 3 4]}
								{[0 2; 0 0; 0 2; 0 2; 0 2; 2 2; 2 2]
								 [0 0; 0 4; 4 4; 1 1; 3 3; 0 1; 3 4]}
								{[0 2; 0 0; 0 2; 0 2; 0 2; 2 2]
								 [0 0; 0 4; 1 1; 4 4; 3 3; 1 3]}
								{[0 0; 0 2; 0 2; 0 2; 0 2]
								 [0 4; 2 0; 2 4; 0 0; 4 4]}
								{[0 2; 0 0; 1 1; 0 2]
								 [0 0; 0 4; 0 4; 4 4]}
								{[0 2; 0 0; 0 2; 2 2; 0 2; 0 0; 0 2; 1 1; 1 1]
								 [0 0; 0 1; 1 1; 1 3; 3 3; 3 4; 4 4; 0 1; 3 4]}
								{[0 1; 1 1; 0 1; 0 1; 1 2; 1 2; 2 2]
								 [0 0; 0 4; 2 2; 4 4; 1 1; 3 3; 1 3]}
								{[0 0; 0 2; 0 2; 0 2; 0 2]
								 [0 4; 0 2; 0 0; 4 2; 4 4]}
								{[1 1; 1 2; 2 2; 1 2; 0 1; 1 2; 2 2; 1 2]
								 [0 4; 0 0; 0 1; 1 1; 2 2; 3 3; 3 4; 4 4]}
								{[0 2; 0 0; 0 2; 1 1; 0 2; 0 0; 0 2]
								 [0 0; 0 1; 1 1; 0 4; 3 3; 3 4; 4 4]}
								{[0 1; 0 2; 1 1; 2 2; 0 2; 0 1]
								 [1 0; 1 1; 0 4; 1 3; 3 3; 3 4]}
								{[0 2; 0 0; 2 2; 1 2; 0 2; 2 2; 1 1]
								 [0 0; 0 4; 0 1; 2 2; 4 4; 3 4; 0 4]}
								{[0 0; 0 2; 2 2; 0 2; 2 2; 1 1; 1 1; 1 2; 1 2]
								 [0 4; 1 1; 0 1; 3 3; 3 4; 0 1; 3 4; 0 0; 4 4]}
								{[0 2; 0 0; 0 2; 0 2; 0 2; 0 2]
								 [0 0; 0 4; 2 0; 2 2; 2 4; 4 4]}
								{[0 2; 0 2; 2 2]
								 [0 4; 4 0; 0 4]}
								{[0 1; 1 2; 2 2; 0 1; 1 1]
								 [2 0; 2 2; 0 4; 2 4; 0 4]}
								{[0 0; 1 1; 0 1; 2 2; 1 2; 1 2]
								 [0 4; 0 4; 2 2; 1 3; 1 1; 3 3]}
								{[1 2; 1 1; 2 2; 0 2; 0 1; 0 1; 0 2; 1 1; 2 2; 1 2]
								 [0 0; 0 1; 0 1; 1 1; 1 2; 3 2; 3 3; 3 4; 3 4; 4 4]}
								{[0 1; 0 0; 1 1; 1 2; 2 2; 1 2; 0 0; 0 1]
								 [0 0; 0 1; 0 4; 1 1; 1 3; 3 3; 3 4; 4 4]}
								...%{[0 2; 1 1; 2 2; 0 2; 0 2; 2 2]
								...% [0 0; 0 4; 0 1; 2 2; 4 4; 3 4]}
							};
			%unbalanced
				uBal	=	{
								{[0 2; 0 0; 0 2; 1 1]
								 [0 0; 0 4; 2 2; 0 2]}
								{[0 2; 0 0; 0 2; 2 2; 0 2]
								 [0 0; 0 4; 2 2; 2 4; 4 4]}
								{[0 2; 1 1; 0 1; 0 0; 0 1]
								 [0 0; 0 4; 4 4; 2 4; 2 2]}
								{[0 2; 1 1; 0 2; 1 2; 0 0; 2 2]
								 [0 0; 0 4; 2 2; 4 4; 0 2; 2 4]}
								{[0 0; 0 2; 0 1; 1 1]
								 [0 4; 4 4; 0 0; 0 4]}
								{[0 0; 0 2; 2 2; 0 2]
								 [0 2; 2 2; 0 4; 1 1]}
								{[0 2; 0 0; 0 2; 0 2]
								 [0 0; 0 4; 4 0; 4 4]}
								{[0 2; 0 0; 0 2; 0 2; 2 2]
								 [0 0; 0 2; 2 0; 2 2; 2 4]}
								{[0 2; 0 0; 0 1; 1 1; 0 1; 0 0; 0 1]
								 [0 0; 0 1; 1 1; 0 4; 3 3; 3 4; 4 4]}
								{[0 2; 0 0; 2 2; 0 2; 0 2]
								 [0 0; 0 4; 0 2; 2 2; 2 4]}
								{[0 2; 0 0; 0 2; 2 2; 1 1; 1 2; 2 2; 1 2]
								 [0 0; 0 1; 1 1; 0 1; 1 4; 2 2; 2 4; 4 4]}
								{[0 1; 0 1; 1 1; 0 2; 0 1]
								 [1 0; 1 1; 0 4; 2 2; 2 3]}
								{[0 0; 0 2; 0 2; 0 2; 2 2]
								 [0 2; 2 0; 2 4; 4 4; 0 4]}
								{[0 2; 0 0; 2 2; 0 1; 1 1; 0 2]
								 [0 0; 0 4; 0 2; 3 3; 3 4; 4 4]}
								{[0 1; 1 1; 0 2; 0 1; 2 2; 0 0; 1 2]
								 [0 0; 0 4; 2 2; 4 4; 2 3; 0 2; 3 3]}
								{[1 2; 1 1; 0 2; 0 1; 1 2]
								 [0 0; 0 4; 4 0; 4 4; 2 2]}
								{[1 1; 1 2; 1 2; 0 1]
								 [0 4; 0 2; 4 2; 4 4]}
								{[0 1; 0 1; 1 1; 1 2]
								 [2 0; 2 2; 0 4; 4 4]}
								{[0 2; 0 0; 0 2; 0 2; 2 2]
								 [0 0; 0 4; 3 1; 4 2; 1 2]}
								{[0 1; 1 1; 1 2; 0 2; 2 2; 0 1]
								 [0 0; 0 4; 0 2; 2 2; 2 3; 2 4]}
								...%{[0 2; 0 2; 0 2; 0 0; 0 2]
								...% [1 0; 1 2; 2 2; 2 4; 4 4]}
							};
			
		cStim	= {yBal; xBal; ySym; uBal};
		cClass	= {'ybal'; 'xbal'; 'ysym'; 'ubal'};
		
		[p.stim,p.class]	= cellfun(@(s,c) deal(s,repmat({c},size(s))),cStim,cClass,'uni',false);
		[p.stim,p.class]	= varfun(@(x) cat(1,x{:}),p.stim,p.class);
		
		nFigure	= numel(p.stim);
		p.k		= reshape(1:nFigure,nFigure,1);
		
		strPathMe				= mfilename('fullpath');
		[strDirMe,strFileMe]	= PathSplit(strPathMe);
		
		p.dir	= DirAppend(strDirMe,strFileMe);
	end
	
	param	= p;
end
%------------------------------------------------------------------------------%

end
