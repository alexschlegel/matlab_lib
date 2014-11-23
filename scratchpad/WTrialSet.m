% Copyright (c) 2014 Trustees of Dartmouth College. All rights reserved.

classdef WTrialSet < handle
	% WTrialSet:  Data pertaining to a set of trials for a given W
	%   TODO: Add detailed comments

	properties (SetAccess = private)
		sigGen
		voxelFreedom
		sims
		dataSet
		wStarSet
	end

	methods
		function obj = WTrialSet(sigGen,voxelFreedom,numTrials)
			baseParams = sigGen.baseParams;
			numFeatures = baseParams.numTopComponents ^ 2;
			obj.sigGen = sigGen;
			obj.voxelFreedom = voxelFreedom;
			obj.sims = cell(1,numTrials);
			obj.dataSet = cell(1,numTrials);
			obj.wStarSet = zeros(numTrials,numFeatures);
			for i = 1:numTrials
				voxPol = VoxelPolicy(baseParams,voxelFreedom);
				obj.sims{i} = CausalSimulator(sigGen,voxPol,'default');
				obj.dataSet{i} = obj.sims{i}.performAll;
				wStar = obj.dataSet{i}.wStar;
				obj.wStarSet(i,:) = reshape(wStar,1,numFeatures);
			end
		end
	end
end
