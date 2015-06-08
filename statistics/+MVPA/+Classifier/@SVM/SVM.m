classdef SVM < MVPA.Classifier.Base
% MVPA.Classifier.SVM
% 
% Description:	SVM classifier (uses libsvm)
% 
% Syntax:	cls = MVPA.Classifier.SVM(<options>)
%
% 			methods:
% 				Train:		train the classifier
%				Predict:	predict labels after training
%
% In:
%	<options> (from svmtrain):
%		type:			(0) the SVM type:
%							0:	C-SVC (multi-class classification)
%							1:	nu-SVC (multi-class classification)
%		kernel_type:	(0) the kernel function type:
%							0:	linear - u'*v
%							1:	polynomial - (gamma*u'*v + coef0)^degree
%							2:	radial basis function - exp(-gamma*|u-v|^2)
%							3:	sigmoid - tanh(gamma*u'*v + coef0)
%		degree:			(3) kernel function degree
%		gamma:			(1/nFeature) kernel function gamma
%		coef0:			(0) kernel function coef0
%		cost:			(1) C parameter in C-SVC, epsilon-SVR, and nu-SVR
%		nu:				(0.5) nu parameter in nu-SVC
%		cachesize:		(100) cache memory size, in MB
%		epsilon:		(0.001) tolerance of termination criterion
%		shrinking:		(true) true to use shrinking heuristics
%
% Updated: 2015-06-08
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
	
	%PROTECTED PROPERTIES------------------------------------------------------%
	properties (GetAccess=protected, SetAccess=protected)
		default_gamma	= true;
	end
	%PROTECTED PROPERTIES------------------------------------------------------%
	
	%PUBLIC PROPERTIES---------------------------------------------------------%
	properties
		type		= 0;
		kernel_type	= 0;
		degree		= 3;
		gamma		= [];
		coef0		= 0;
		cost		= 1;
		nu			= 0.5;
		cachesize	= 100;
		epsilon		= 0.001;
		shrinking	= true;
	end
	%PUBLIC PROPERTIES---------------------------------------------------------%
	
	%DERIVED PROPERTIES--------------------------------------------------------%
	methods
		function cls = set.gamma(cls,g)
			cls.gamma			= g;
			cls.default_gamma	= false;
		end
	end
	%DERIVED PROPERTIES--------------------------------------------------------%
	
	%PUBLIC METHODS------------------------------------------------------------%
	methods
		function cls = SVM(varargin)
			cls	= cls@MVPA.Classifier.Base(varargin{:});
		end
	end
	%PUBLIC METHODS------------------------------------------------------------%
	
	%PRIVATE METHODS-----------------------------------------------------------%
	methods (Access=public)
		function model = p_train(cls,dTrain,kTarget)
			%set the default gamma
				if cls.default_gamma
					cls.gamma			= 1/size(dTrain,2);
					cls.default_gamma	= true;
				end
			%parse the options
				strOptions	= sprintf('-s %d -t %d -d %d -g %f -r %f -c %f -n %f -m %f -e %f -h %d -q',...
								cls.type		, ...
								cls.kernel_type	, ...
								cls.degree		, ...
								cls.gamma		, ...
								cls.coef0		, ...
								cls.cost		, ...
								cls.nu			, ...
								cls.cachesize	, ...
								cls.epsilon		, ...
								cls.shrinking	  ...
								);
			%train the classifier
				model	= libsvmtrain(kTarget,dTrain,strOptions);
		end
		
		function kPredict = p_predict(cls,model,dTest)
			kPredict	= libsvmpredict(rand(size(dTest,1),1),dTest,model,'-q');
		end
	end
	%PRIVATE METHODS-----------------------------------------------------------%
end
