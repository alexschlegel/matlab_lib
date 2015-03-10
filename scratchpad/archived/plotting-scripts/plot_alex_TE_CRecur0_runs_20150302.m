
% Script to create figures from exploratory data capsules
%

load('scratchpad/capsules/20150303_051553_iflow_plot_data.mat');
pp			= Pipeline;
capsules	= plot_data.capsuleCell;

for kC=1:numel(capsules)
	p		= pp.makePlotFromCapsule(capsules{kC});
	h(kC)	= p.hF;
end

figfilename	= ['20150302_alex_TE_CRecur0_data_plotted_' FormatTime(nowms,'yyyymmdd_HHMM') '.fig'];
savefig(h,figfilename);
fprintf('Plots saved to %s\n',figfilename);

