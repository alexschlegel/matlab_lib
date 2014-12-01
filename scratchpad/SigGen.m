% Copyright (c) 2014 Trustees of Dartmouth College. All rights reserved.

classdef SigGen < handle
	% SigGen:  Signal generator for set of like trials
	%   (Applies to functional signals only, not voxel signals.)
	%   TODO: Add detailed comments

	properties (SetAccess = private)
		baseParams
		W                % probably will be going away
		isDestBalancing  % probably will be going away
		recurrenceParams
	end
	methods
		function obj = SigGen(baseParams,W,varargin)
			[opt,optcell] = Opts.getOpts(varargin);
			baseParams.validateW(W);
			obj.baseParams = baseParams;
			obj.isDestBalancing = opt.isDestBalancing;
			obj.recurrenceParams = RecurrenceParams(baseParams,W,...
				optcell{:});
			obj.W = obj.recurrenceParams.W;
		end
		function [src,dst] = genSigs(obj)
			bp = obj.baseParams;
			rp = obj.recurrenceParams;
			wTrans = rp.W.';
			nsWTrans = rp.nonsourceW.';
			nt = obj.baseParams.numTimeSteps;
			nf = obj.baseParams.numFuncSigs;
			src = zeros(nt,nf);
			dst = zeros(nt,nf);
			%oth = zeros(nt,nf);
			prevSrc = zeros(nf,1);
			prevDst = zeros(nf,1);
			prevOth = zeros(nf,1);
			for i = 1:nt
				currSrc = diag(rp.recurDiagonals{1}) * prevSrc;
				currDst = diag(rp.recurDiagonals{2}) * prevDst;
				currOth = diag(rp.recurDiagonals{3}) * prevOth;

				currDst = currDst + wTrans * prevSrc + nsWTrans * prevOth;

				currSrc = currSrc + bp.sourceNoisiness * randn(nf,1);
				currDst = currDst + bp.destNoisiness * randn(nf,1);
				currOth = currOth + bp.sourceNoisiness * randn(nf,1);

				src(i,:) = currSrc';
				dst(i,:) = currDst';
				prevSrc = currSrc;
				prevDst = currDst;
				prevOth = currOth;
			end
			src = zscore(src);
			dst = zscore(dst);
		end
	end
end
