function Train(cls,dTrain,target)
% Train
% 
% Description:	train the classifier
% 
% Syntax:	cls.Train(dTrain,target)
% 
% In:
% 	dTrain	- an nSample x nFeature array of training data
%	target	- an nSample x 1 array of target labels
% 
% Updated: 2015-05-21
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%untrain the model
	cls.Untrain;

%error check
	assert(ndims(dTrain)==2,'training data must be an nSample x nFeature array');
	assert(isnumeric(dTrain) || islogical(dTrain),'training data must be numeric');
	
	[nSample,cls.nFeature]	= size(dTrain);
	
	assert(numel(target)==nSample,'target array must have one element for each sample of the training data');
	
	target	= reshape(target,nSample,1);
	
	assert(iscellstr(target) || islogical(target) || isnumeric(target),'unsupported target type');

%store the unique targets
	cls.targets	= unique(target);
	[b,target]	= ismember(target,cls.targets);

%train
	cls.model	= cls.p_train(dTrain,target);
