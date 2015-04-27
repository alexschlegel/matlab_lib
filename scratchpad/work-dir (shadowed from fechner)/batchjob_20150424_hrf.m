
%

pd_nohrf    = Pipeline.constructTestPlotData('max_cores',12,'hrf',false);
pd_hrf      = Pipeline.constructTestPlotData('max_cores',12,'hrf',true);

save('../data_store/20150424_constructTestPlotData.mat','pd_nohrf','pd_hrf');
clear pd_nohrf pd_hrf;

cc          = create_20150424_hrf_comparison('max_cores',12);

exit
