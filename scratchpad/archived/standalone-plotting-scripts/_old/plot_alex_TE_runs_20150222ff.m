
% Script to create figures from exploratory data capsules
%
% Variable order:    'nSubject'    'nRun'    'WFullness'    'WSum'    'nTBlock'
%
% Capsule files to be plotted:
%
% 20150222_211044_iflow_plot_capsule.mat	nSubject
% 20150223_205515_iflow_plot_capsule.mat	nRun
% 20150224_005617_iflow_plot_capsule.mat	WFullness	0.0500    0.1000    0.1500    0.2000
% 20150223_022252_iflow_plot_capsule.mat	WFullness	0.0500    0.1000    0.2000    0.4000
% 20150222_225140_iflow_plot_capsule.mat	WSum
% 20150223_055408_iflow_plot_capsule.mat	nTBlock

pp			= Pipeline;
capsules	= {...
	'20150222_211044_iflow_plot_capsule.mat', ...
	'20150223_205515_iflow_plot_capsule.mat', ...
	'20150224_005617_iflow_plot_capsule.mat', ...
	'20150223_022252_iflow_plot_capsule.mat', ...
	'20150222_225140_iflow_plot_capsule.mat', ...
	'20150223_055408_iflow_plot_capsule.mat'  ...
	};

for kC=1:numel(capsules)
	load(['scratchpad/capsules/' capsules{kC}]);
	p		= pp.makePlotFromCapsule(iflow_plot_capsule);
	h(kC)	= p.hF;
end

figfilename	= ['20150222ff_data_plotted_' FormatTime(nowms,'yyyymmdd_HHMM') '.fig'];
savefig(h,figfilename);
fprintf('Plots saved to %s\n',figfilename);

