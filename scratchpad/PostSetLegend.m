function PostSetLegend(h)
% Copied from alexplot.m
%
% Updated: 2015-04-07
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

	if ~isempty(h.opt.legend)
		axes(h.hA);
		
		nLegend	= min(numel(h.opt.legend),numel(h.hForLegend));
		
		if nLegend>0
			h.hLegend	= legend(h.hForLegend(1:nLegend),h.opt.legend(1:nLegend),'Location',h.opt.legendlocation,'Orientation',h.opt.legendorientation);
			
			if isequal(h.opt.legendbox,'off')
				if h.opt.showgrid
					set(h.hLegend,'XColor',h.opt.background,'YColor',h.opt.background);
				else
					set(h.hLegend,'box',h.opt.legendbox);
				end
			end
			
			hChildren	= get(h.hLegend,'Children');
			nChildren	= numel(hChildren);
			for kC=1:nChildren
				if isequal(get(hChildren(kC),'type'),'text')
					set(hChildren(kC),'FontName',h.opt.font,'FontWeight',h.opt.fontweight,'FontSize',10*h.opt.fontsize,'Color',h.opt.textcolor);
				end
			end
			
			
		else
			h.hLegend	= [];
		end
	end
end
