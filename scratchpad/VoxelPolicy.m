% Copyright (c) 2014 Trustees of Dartmouth College. All rights reserved.

classdef VoxelPolicy < handle
	% VoxelPolicy:  Mechanism for converting functional signals to voxels
	%   TODO: Add detailed comments

	properties (SetAccess = private)
		baseParams
		freedom
	end
	properties (Access = private)
		regionMixers
	end
	methods
		function obj = VoxelPolicy(baseParams,freedom)
			baseParams.validate;
			obj.baseParams = baseParams;
			obj.freedom = freedom;
			obj.regionMixers = cell(1,2);
		end
		function voxels = mixFuncSigs(obj,funcSigs,regionIndex)
			voxels = funcSigs * obj.getMixer(regionIndex);
		end
	end
	methods (Access = private)
		function mixer = createMixer(obj)
			nf = obj.baseParams.numFuncSigs;
			nv = obj.baseParams.numVoxelSigs;
			beta = obj.freedom;
			alpha = 1 - beta;
			shortDim = min(nf,nv);
			fixed = zeros(nf,nv);
			fixed(1:shortDim,1:shortDim) = diag(ones(shortDim,1));
			mixer = alpha * fixed + beta * randn(nf,nv);
			%For debugging:
			%disp('Mixer:');
			%disp(SimStatic.clipmat(mixer,7,7));
		end
		function mixer = getMixer(obj,regionIndex)
			if isempty(obj.regionMixers{regionIndex})
				obj.regionMixers{regionIndex} = obj.createMixer;
			end
			mixer = obj.regionMixers{regionIndex};
		end
	end
end
