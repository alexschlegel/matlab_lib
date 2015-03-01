
% The data in gc_example_0.mat consists of the arguments passed to
% GrangerCausality the first time it is called in the course of running
% Pipeline.speedupDebugSimulation('analysis','seth','nVoxel',30,'nRepBlock',10,'nTBlock',1)
%
% (Refers to Pipeline.m as of 2015-02-27)

load gc_example_0
gc	= GrangerCausality(X,Y,'samples',samples)
clear X Y samples


% The data in gc_example_warn.mat consists of the arguments passed to
% GrangerCausality the first time it is called in the course of running
% Pipeline.speedupDebugSimulation('analysis','seth','nRepBlock',4)
%
% (Refers to Pipeline.m as of 2015-02-27)

load gc_example_warn
gc	= GrangerCausality(X,Y,'samples',samples)
clear X Y samples
