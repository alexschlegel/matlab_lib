% Copyright (c) 2014 Trustees of Dartmouth College. All rights reserved.

classdef WClassifier < handle
	% WClassifier:  Program to test classification of recovered W matrices
	%   TODO: Add detailed comments

	properties
		numTrialsPerW
		trialSetA
		trialSetB
	end

	methods
		function obj = WClassifier(numTrialsPerW)
			obj.numTrialsPerW = numTrialsPerW;
			obj.trialSetA = WTrialSet(CausalBaseParams,numTrialsPerW);
			obj.trialSetB = WTrialSet(CausalBaseParams,numTrialsPerW);
		end
		function netScore = computeNetScore(obj)
			totScore = 0;
			for i = 1:obj.numTrialsPerW
				totScore = totScore + obj.computeScoreAtIndex(i);
			end
			netScore = totScore / obj.numTrialsPerW;
		end
		function score = computeScoreAtIndex(obj,testIndex)
			wStarSetA = obj.trialSetA.wStarSet;
			wStarSetB = obj.trialSetB.wStarSet;
			groupsA = 1 * ones(obj.numTrialsPerW,1);
			groupsB = 2 * ones(obj.numTrialsPerW,1);
			groupsA(testIndex) = NaN;
			groupsB(testIndex) = NaN;
			SVMStruct = svmtrain([wStarSetA;wStarSetB],[groupsA;groupsB]);
			testGroupA = svmclassify(SVMStruct,wStarSetA(testIndex,:));
			testGroupB = svmclassify(SVMStruct,wStarSetB(testIndex,:));
			score = 0.5 * ...
				(obj.getEqualityIndicator(testGroupA,1) + ...
				obj.getEqualityIndicator(testGroupB,2));
		end
		function indicator = getEqualityIndicator(~,x,y)
			indicator = (x == y);
		end
	end

	methods (Static)
		function testClassification(numTrialsPerW)
			rng('default');
			classifier = WClassifier(numTrialsPerW);
			netScore = classifier.computeNetScore;
			fprintf('Net score is %g\n', netScore);
		end
	end

end
