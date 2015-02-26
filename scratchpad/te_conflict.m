
% Script to illustrate TransferEntropy conflict
%
% In this example, both TransferEntropy algorithms 1 and 2 disagree with
% infodynamics TransferEntropyCalculatorMultiVariateKraskov.
%
% My results, 2015-02-26, using infodynamics.jar v1.1 or v1.2.1:
%
% TEs are
%   0.047619
%   0.100000
%   0.007143

X	= [10.4209; -5.1824; 13.4157; -7.2264; 4.5514; -27.7576; 1.1943; -9.6390];
Y	= [-2.4891; 0.6102; 1.0905; 4.0360; -4.7826; -8.7520; 7.2028; 1.5713];

kraskov_k		= 4;
infodyn_teCalc	= javaObject('infodynamics.measures.continuous.kraskov.TransferEntropyCalculatorMultiVariateKraskov');

infodyn_teCalc.initialise(1,size(X,2),size(Y,2)); % Use history length 1 (Schreiber k=1)
infodyn_teCalc.setProperty('k',num2str(kraskov_k));
infodyn_teCalc.setObservations(X,Y);

TE(1)			= TransferEntropy(X,Y,'kraskov_k',kraskov_k,'ksg_algorithm',1);
TE(2)			= TransferEntropy(X,Y,'kraskov_k',kraskov_k,'ksg_algorithm',2);
TE(3)			= infodyn_teCalc.computeAverageLocalOfObservations();

fprintf('TEs are%s\n',sprintf('\n  %.6f',TE));
