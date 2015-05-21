restoredefaultpath;
g = genpath('/home/tselab/studies/iflow/simulation/matlab_lib');
gs = regexp(g,':','split');
starts = regexp(gs,'/(_old|\.git|matlab_lib/statistics/mvgc(/|$))','start');
ok_indices = find(cellfun(@(c) numel(c) == 0, starts));
gs2 = gs(ok_indices);
g2 = strjoin(gs2,':');
addpath(g2,'-begin');
clear g gs starts ok_indices gs2 g2

RESET_IFLOW_PATH_EXECUTED=true;
