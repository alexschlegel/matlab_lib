% Copyright (c) 2014 Trustees of Dartmouth College. All rights reserved.

classdef WTrialSet < handle
	% WTrialSet:  Data pertaining to a set of trials for a given W
	%   TODO: Add detailed comments

	properties
		params
		sims
		dataSet
		wStarSet
	end

	methods
		function obj = WTrialSet(params,numTrials)
			numFeatures = params.numTopComponents ^ 2;
			obj.params = params;
			obj.sims = cell(1,numTrials);
			obj.dataSet = cell(1,numTrials);
			obj.wStarSet = zeros(numTrials,numFeatures);
			for i = 1:numTrials
				obj.sims{i} = CausalSimulator(params);
				obj.dataSet{i} = obj.sims{i}.performAll;
				wStar = obj.dataSet{i}.wStar;
				obj.wStarSet(i,:) = reshape(wStar,1,numFeatures);
			end
		end
	end
end
