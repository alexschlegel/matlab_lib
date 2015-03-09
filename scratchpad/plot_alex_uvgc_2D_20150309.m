
% Script to create figures from exploratory data capsules
%

load('scratchpad/capsules/20150308_230040_iflow_plot_data.mat');
pd(1)		= plot_data;
load('scratchpad/capsules/20150309_111726_iflow_plot_data.mat');
pd(2)		= plot_data;

pp			= Pipeline;

for kD=1:2

	cCapsule	= pd(kD).cCapsule';
	nPlot		= size(cCapsule,2);

	h0			= zeros(nPlot,1);
	for kP=1:nPlot
		p		= pp.renderMultiLinePlot(cCapsule(:,kP),pd(kD).var2Spec,[1 3 5]);
		h0(kP)	= p.hF;
	end
	cH{kD}		= h0;
end

h				= cat(1,cH{:});
%figfilename	= ['20150308_alex_gc_uni_plotted_' FormatTime(nowms,'yyyymmdd_HHMM') '.fig'];
figfilename	= ['20150309_alex_gc_uni.fig'];
savefig(h,figfilename);
fprintf('Plots saved to %s\n',figfilename);
clear plot_data pd pp kD cCapsule nPlot kP p h0 cH;

