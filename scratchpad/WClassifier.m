% Copyright (c) 2014 Trustees of Dartmouth College. All rights reserved.

classdef WClassifier < handle
	% WClassifier:  Program to test classification of recovered W matrices
	%   TODO: Add detailed comments

	properties
		numTrialsPerW
		paramsA
		paramsB
		trialSetA
		trialSetB
	end

	methods
		function obj = WClassifier(numTrialsPerW,paramsA,paramsB)
			obj.numTrialsPerW = numTrialsPerW;
			obj.paramsA = paramsA;
			obj.paramsB = paramsB;
			obj.trialSetA = WTrialSet(paramsA,numTrialsPerW);
			obj.trialSetB = WTrialSet(paramsB,numTrialsPerW);
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
		function graphClassificationAgainstNoisiness
			%TODO
			display('Not yet implemented');
		end
		function testClassification(noisiness,numWs,numTrialsPerW)
			rng('default');
			for i = 1:numWs
				paramSets{i} = CausalBaseParams(noisiness);
			end
			for i = 1:(numWs-1)
				for j = (i+1):numWs
					classifier = WClassifier(numTrialsPerW,...
						paramSets{i},paramSets{j});
					netScores(i,j) = classifier.computeNetScore;
				end
			end
			display('Net scores:');
			disp(netScores);
			%TODO:
			%fprintf('Mean net score is %g\n', meanScore);
		end
	end

end
