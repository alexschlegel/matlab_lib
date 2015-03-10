
% Script to create figures from exploratory data capsules
%

load('scratchpad/capsules/20150308_230040_iflow_plot_data.mat');
pd{1,2}		= plot_data;
load('scratchpad/capsules/20150309_111726_iflow_plot_data.mat');
pd{2,2}		= plot_data;
load('scratchpad/capsules/20150309_224409_iflow_plot_data.mat');
pd{1,1}		= plot_data;
load('scratchpad/capsules/20150310_004956_iflow_plot_data.mat');
pd{2,1}		= plot_data;

pp			= Pipeline;
cH			= cell(2,2);

for kD1=1:2
	for kD2=1:2
		pd0			= pd{kD1,kD2};
		cCap		= pd0.cCapsule;
		if kD2 == 2
			cCap	= cCap'; % prev-format capsule grid
		end
		nPlot		= size(cCap,2);
		h0			= cell(nPlot,1);
		for kP=1:nPlot
			h0{kP}	= pp.renderMultiLinePlot(cCap(:,kP),pd0.var2Spec,[1 3 5]);
		end
		cH{kD1,kD2}	= h0;
	end
end

nPlot			= cellfun(@(h) numel(h),cH);
if min(nPlot(:)) ~= max(nPlot(:))
	error('Variable numbers of plots.');
end
nPlot			= mean(nPlot(:));

mp				= cell(nPlot,1);
for kP=1:nPlot
	figGrid		= cellfun(@(h) h{kP},cH,'uni',false);
	hFGrid		= cellfun(@(h) h.hF,figGrid);
	set(hFGrid,'Position',[0 0 600 350]);
	mp{kP}		= multiplot(figGrid);
end

%figfilename	= ['20150310_alex_gc_uni_combo_plotted_' FormatTime(nowms,'yyyymmdd_HHMM') '.fig'];
figfilename	= ['20150310_alex_gc_uni_combo.fig'];
savefig(cellfun(@(h) h.hF,mp(nPlot:-1:1)),figfilename);
fprintf('Plots saved to %s\n',figfilename);
clear plot_data pd pp cH kD1 kD2 pd0 cCap nPlot h0 kP mp figGrid hFGrid;

