
% Script to create figures from exploratory data capsules
%

load('scratchpad/capsules/20150305_052504_iflow_plot_data.mat');
pp			= Pipeline;
cCapsule	= plot_data.capsuleCell;

for kC=1:numel(cCapsule)
	p		= pp.makePlotFromCapsule(cCapsule{kC});
	h(kC)	= p.hF;
end

figfilename	= ['20150304_alex_TE_WSum0_4_plotted_' FormatTime(nowms,'yyyymmdd_HHMM') '.fig'];
savefig(h,figfilename);
fprintf('Plots saved to %s\n',figfilename);

