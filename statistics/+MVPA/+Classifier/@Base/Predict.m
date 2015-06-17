function prediction = Predict(cls,dTest)
% Predict
% 
% Description:	predict targets using a trained classifier
% 
% Syntax:	prediction = cls.Predict(dTest)
% 
% In:
% 	dTest	- an nSample x nFeature array of testing data
%
% Out:
% 	prediction	- an nSample x 1 array of predicted target labels
% 
% Updated: 2015-05-21
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%error check
	assert(cls.trained,'classifier has not yet been trained');
	assert(ismatrix(dTest),'testing data must be an nSample x nFeature array');
	assert(isnumeric(dTest) || islogical(dTest),'testing data must be numeric');
	assert(size(dTest,2)==cls.nFeature,'testing data does not have the same number of features as the training data');

%predict
	kPredict	= cls.p_predict(cls.model,dTest);

%convert to user's targets
	prediction	= cls.targets(kPredict);
