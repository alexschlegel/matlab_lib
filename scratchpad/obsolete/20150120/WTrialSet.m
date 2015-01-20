% Copyright (c) 2014 Trustees of Dartmouth College. All rights reserved.

classdef WTrialSet < handle
	% WTrialSet:  Data pertaining to a set of trials for a given W
	%   TODO: Add detailed comments

	properties (SetAccess = private)
		opt
		sigGen
		sims
		dataSet
		wStarSet
	end

	methods
		function obj = WTrialSet(sigGen,numTrials,varargin)
			[opt,optcell] = Opts.getOpts(varargin,...
				'pcaPolicy'			,'runPCA'	  ...
				);
			obj.opt = opt;
			numFeatures = opt.numTopComponents ^ 2;
			obj.sigGen = sigGen;
			obj.sims = cell(1,numTrials);
			obj.dataSet = cell(1,numTrials);
			obj.wStarSet = zeros(numTrials,numFeatures);
			for i = 1:numTrials
				voxPol = VoxelPolicy(optcell{:});
				obj.sims{i} = CausalSimulator(sigGen,voxPol);
				obj.dataSet{i} = obj.sims{i}.performAll;
				wStar = obj.dataSet{i}.wStar;
				obj.wStarSet(i,:) = reshape(wStar,1,numFeatures);
			end
		end
	end
end
