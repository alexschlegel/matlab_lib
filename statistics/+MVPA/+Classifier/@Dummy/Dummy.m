classdef Dummy < MVPA.Classifier.Base
% MVPA.Classifier.Dummy
% 
% Description:	dummy classifier
% 
% Syntax:	cls = MVPA.Classifier.Dummy()
%
% 			methods:
% 				Train:		train the classifier
%				Predict:	predict labels after training
%
% Updated: 2015-05-21
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

	%PRIVATE METHODS-----------------------------------------------------------%
	methods (Static, Access=public)
		function model = p_train(dTrain,kTarget,options)
			model.target	= unique(kTarget);
		end
		
		function kPredict = p_predict(model,dTest)
			kPredict	= repto(model.target,[size(dTest,1) 1]);
		end
	end
	%PRIVATE METHODS-----------------------------------------------------------%
end
