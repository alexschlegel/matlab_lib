% Copyright (c) 2014 Trustees of Dartmouth College. All rights reserved.

classdef WClassifier < handle
	% WClassifier:  Program to test classification of recovered W matrices
	%   TODO: Add detailed comments

	properties (SetAccess = private)
		opt
		wPairedTrialConfig
		numTrialsPerW
		trialSetA
		trialSetB
	end

	methods
		function obj = WClassifier(wPairedTrialConfig,numTrialsPerW,...
				varargin)
			[opt,optcell] = Opts.getOpts(varargin);
			obj.opt = opt;
			obj.wPairedTrialConfig = wPairedTrialConfig;
			obj.numTrialsPerW = numTrialsPerW;
			obj.trialSetA = WTrialSet(wPairedTrialConfig.sigGenA,...
				numTrialsPerW,optcell{:});
			obj.trialSetB = WTrialSet(wPairedTrialConfig.sigGenB,...
				numTrialsPerW,optcell{:});
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
		%{
		function graphClassificationAgainstNoisiness
			%TODO
			display('Not yet implemented');
		end
		%}
		function runExample(varargin)
			[opt,optcell] = Opts.getOpts(varargin,...
				'noisinessForDest'		, 1000	, ...
				'noisinessForSource'	, 1000	, ...
				'voxelFreedom'			, 0.000	  ...
				);
			rng('default');
			scores = zeros(1,10);
			for i = 1:numel(scores)
				scores(i) = ...
					WClassifier.testClassification(0.1,20,true,optcell{:});
			end
			disp('Scores:');
			disp(scores);
			fprintf('Mean = %g\n', mean(scores));
		end
		function netScore = testClassification(...
				wDensity,numTrialsPerW,showWs,varargin)
			% TODO: wDensity, etc., should be made into Opt variables
			[opt,optcell] = Opts.getOpts(varargin);
			wPairConfig = WPairedTrialConfig(wDensity,optcell{:});
			if showWs
				disp('W1:');
				disp(SimStatic.clipmat(wPairConfig.sigGenA.W,10,10));
				disp('W2:');
				disp(SimStatic.clipmat(wPairConfig.sigGenB.W,10,10));
			end
			classifier = WClassifier(wPairConfig,numTrialsPerW,optcell{:});
			netScore = classifier.computeNetScore;
			fprintf('Net score = %g\n\n', netScore);
		end
	end

end
