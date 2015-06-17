classdef Base < MVPA.Object
% MVPA.Classifier.Base
% 
% Description:	base classifier class
% 
% Syntax:	cls = MVPA.Classifier.Base(<options>)
%
% 			methods:
% 				Train:		train the classifier
%				Predict:	predict labels after training
%
% Notes:
%	subclasses only need to implement the p_train and p_predict private
%	functions
% 
% Updated: 2015-06-03
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

	%PROTECTED PROPERTIES------------------------------------------------------%
	properties (SetAccess=protected)
		trained;
		
		model	= [];
	end
	properties (GetAccess=protected, SetAccess=protected)
		targets		= [];
		nFeature	= [];
	end
	%PROTECTED PROPERTIES------------------------------------------------------%
	
	%PUBLIC PROPERTIES---------------------------------------------------------%
	properties
		
	end
	%PUBLIC PROPERTIES---------------------------------------------------------%
	
	%DERIVED PROPERTIES--------------------------------------------------------%
	methods
		function b = get.trained(cls)
			b	= ~isempty(cls.model);
		end
	end
	%DERIVED PROPERTIES--------------------------------------------------------%
	
	%PUBLIC METHODS------------------------------------------------------------%
	methods
		function cls = Base(varargin)
			cls	= cls@MVPA.Object({'trained';'model'});
			
			%parse the input options
				for k=1:2:nargin
					opt	= varargin{k};
					val	= varargin{k+1};
					
					assert(ischar(opt),'options must be specified as string/value pairs');
					assert(isprop(cls,opt) && ~any(strcmp(opt,{'trained','model'})),'"%s" is not a valid option',opt);
					
					cls.(opt)	= val;
				end
			
			%reset the classifier
				cls.Untrain;
		end
		%----------------------------------------------------------------------%
	end
	%PUBLIC METHODS------------------------------------------------------------%
	
	%PRIVATE METHODS-----------------------------------------------------------%
	methods (Abstract, Access=public)
		model = p_train(cls,dTrain,kTarget)
		% p_train
		% 
		% Description:	actual training of the classifier happens here 
		% 
		% Syntax:	model = cls.p_train(dTrain,kTarget)
		% 
		% In:
		% 	dTrain	- an nSample x nFeature array of training data
		%	kTarget	- an nSample x 1 array of integer labels
		% 
		% Out:
		% 	model	- a struct defining the trained model
		
		kPredict = p_predict(cls,model,dTest)
		% p_predict
		% 
		% Description:	actual testing of the classifier happens here 
		% 
		% Syntax:	model = cls.p_test(model,dTest)
		% 
		% In:
		% 	model	- a struct returned by p_train
		%	dTest	- an nSample x nFeature array of testing data
		% 
		% Out:
		% 	kPredict	- an nSample x 1 array of predicted labels
	end
	%PRIVATE METHODS-----------------------------------------------------------%
end
