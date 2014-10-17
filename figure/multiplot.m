function h = multiplot(hSub,varargin)
% multiplot
% 
% Description:	combine multiple figures into a single figure
% 
% Syntax:	h = multiplot(hSub,<options>)
% 
% In:
% 	hSub	- an M x N array of the figures to combine.  Must be a numerical
%			  array of figure handles, a struct array of alexplot return
%			  structs, or a cell of these.
%	<options>:
%		background:		([1 1 1]) the background color
%		label:			(<A, B, ...>) the subplot labels, or false for no labels
%		labelcol:		([0.6 0.6 0.6]) the label color
%		spacer:			(true) true to place spacer bars in between plots
%		spacercol:		([0.9 0.9 0.9]) the spacer color
%		spacersize:		(3) the spacer thickness
%		spacerpad:		(10) the padding in between the figure bounds and the
%						spacers, in pixels 
%		fontfamily:		('Arial') the font for the labels
%		fontsize:		(20) the label font size
% 
% Out:
% 	h	- a struct of handles
% 
% Updated: 2012-12-14
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
pad	= 3;

%parse the input
	nSub	= numel(hSub);
	sSub	= size(hSub);
	
	opt	= ParseArgs(varargin,...
			'background'	, [1 1 1]		, ...
			'label'			, []			, ...
			'labelcol'		, [0.6 0.6 0.6]	, ...
			'spacer'		, true			, ...
			'spacercol'		, [0.9 0.9 0.9]	, ...
			'spacersize'	, 3				, ...
			'spacerpad'		, 10			, ...
			'fontfamily'	, 'Arial'		, ...
			'fontsize'		, 20			  ...
			);
	
	if isempty(opt.label);
		opt.label	= reshape(num2cell(char('A' + (0:nSub-1))),sSub(end:-1:1))';
	end
	
	bLabel	= notfalse(opt.label);
	
	if ~iscell(hSub)
		hSub	= num2cell(hSub);
	end
	
	h.hSub	= hSub;
%get the input figure handles
	hSubFigure	= zeros(sSub);
	
	for kS=1:nSub
		if isstruct(hSub{kS})
			hSubFigure(kS)	= hSub{kS}.hF;
		else
			hSubFigure(kS)	= hSub{kS};
		end
	end
%get the input figure sizes
	pSub	= arrayfun(@(h) get(h,'position'),hSubFigure,'UniformOutput',false);
	WSub	= cellfun(@(p) p(3),pSub);
	HSub	= cellfun(@(p) p(4),pSub);
	
	WSubMax	= max(WSub(:));
	HSubMax	= max(HSub(:));
	
	WFigure	= sSub(2)*WSubMax;
	HFigure	= sSub(1)*HSubMax;
%open the multi-figure
	h.hF	= figure;
	set(h.hF,'Color',opt.background,'Position',[0 0 WFigure HFigure]);
%transfer each figure
	for kR=1:sSub(1)
		for kC=1:sSub(2)
			lSubCur	= WSubMax*(kC-1)+pad;
			tSubCur	= HFigure-HSubMax*kR+pad;
			
			hChild	= get(hSubFigure(kR,kC),'Children');
			while ~isempty(hChild)
				if ismember(get(hChild(1),'type'),{'uimenu','uitoolbar'})
					delete(hChild(1));
				else
					set(hChild(1),'Units','pixels');
					pChild		= get(hChild(1),'Position');
					pChildNew	= [lSubCur tSubCur 0 0] + pChild;
					
					set(hChild(1),'Parent',h.hF,'Position',pChildNew);
				end
				
				hChild	= get(hSubFigure(kR,kC),'Children');
			end
			
			close(hSubFigure(kR,kC));
			
			%add a label
				if bLabel
					
				end
		end
	end
%create spacers and labels
	if opt.spacer || bLabel
		h.Layout.hA	= axes;
		set(h.Layout.hA,...
				'Xtick'		, []					, ...
				'YTick'		, []					, ...
				'XColor'	, opt.background		, ...
				'YColor'	, opt.background		, ...
				'Units'		, 'pixels'				, ...
				'Position'	, [0 0 WFigure HFigure]	, ...
				'XLim'		, [0 WFigure]			, ...
				'YLim'		, [0 HFigure]			, ...
				'YDir'		, 'reverse'				  ...
				);
		MoveToBack(h.hF,h.Layout.hA);
		
		%labels
		if bLabel
			h.Layout.hLabel	= zeros(sSub);
			
			for kR=1:sSub(1)
				for kC=1:sSub(2)
					lLabel	= WSubMax*(kC-1)+2*pad;
					tLabel	= HSubMax*(kR-1)+2*pad;
					
					kLabel	= sub2ind(sSub,kR,kC);
					
					h.Layout.hLabel(kR,kC)	= text(lLabel,tLabel,opt.label{kLabel},...
												'HorizontalAlignment'	, 'left'			, ...
												'VerticalAlignment'		, 'top'				, ...
												'FontName'				, opt.fontfamily	, ...
												'FontSize'				, opt.fontsize		, ...
												'FontWeight'			, 'bold'			, ...
												'Color'					, opt.labelcol		  ...
												);
				end
			end
		end
		
		%spacers
		if opt.spacer
			h.Layout.hHSpacer	= zeros(sSub(1)-1,1);
			
			for kR=2:sSub(1)
				lSpacer	= opt.spacerpad;
				rSpacer	= WFigure-opt.spacerpad;
				tSpacer	= HSubMax*(kR-1);
				
				h.Layout.hHSpacer(kR-1)	= line([lSpacer rSpacer],[tSpacer tSpacer],...
											'Color'		,opt.spacercol	, ...
											'LineWidth'	,opt.spacersize	  ...
											);
			end
			
			h.Layout.hVSpacer	= zeros(sSub(2)-1,1);
			
			for kC=2:sSub(2)
				tSpacer	= opt.spacerpad;
				bSpacer	= HFigure-opt.spacerpad;
				lSpacer	= WSubMax*(kC-1);
				
				h.Layout.hVSpacer(kC-1)	= line([lSpacer lSpacer],[tSpacer bSpacer],...
											'Color'		,opt.spacercol	, ...
											'LineWidth'	,opt.spacersize	  ...
											);
			end
		end
	end
	