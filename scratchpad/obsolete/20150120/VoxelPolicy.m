% Copyright (c) 2014 Trustees of Dartmouth College. All rights reserved.

classdef VoxelPolicy < handle
	% VoxelPolicy:  Mechanism for converting functional signals to voxels
	%   TODO: Add detailed comments

	properties (SetAccess = private)
		opt
	end
	properties (Access = private)
		regionMixers
	end
	methods
		function obj = VoxelPolicy(varargin)
			[opt,optcell] = Opts.getOpts(varargin);
			Opts.validate(opt);
			obj.opt = opt;
			obj.regionMixers = cell(1,2);
		end
		function voxels = mixFuncSigs(obj,funcSigs,regionIndex)
			voxels = funcSigs * obj.getMixer(regionIndex);
		end
	end
	methods (Access = private)
		function mixer = createMixer(obj)
			nf = obj.opt.numFuncSigs;
			nv = obj.opt.numVoxelSigs;
			beta = obj.opt.voxelFreedom;
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
