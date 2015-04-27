% For old plotting scripts, see scratchpad/archived/plotting-scripts/*

% Script to create figures from capsules in 20150424_constructTestPlotData.mat
% See also "work-dir (shadowed from fechner)/batchjob_20150424_hrf.m"
%
% TODO: Consider restoring automatic date labeling using this construct:
% ['.....' FormatTime(nowms,'yyyymmdd_HHMM') '.....'];

function [hF,hAlex] = plot_20150424_constructTestPlotData

hF				= zeros(1,0);
hAlex			= cell(1,0);
p				= Pipeline;
stem			= '20150424_constructTestPlotData';

load(['../data_store/' stem '.mat']);

cH_nohrf		= Pipeline.constructTestPlotsFromData(pd_nohrf);
cH_hrf			= Pipeline.constructTestPlotsFromData(pd_hrf);

hAlex			= [cH_nohrf cH_hrf];
hF				= cellfun(@(h)h.hF,hAlex);


figfilepath		= ['scratchpad/figfiles/' stem '.fig'];
savefig(hF(end:-1:1),figfilepath);
fprintf('Plots saved to %s\n',figfilepath);

end

