% Copyright (c) 2014 Trustees of Dartmouth College. All rights reserved.

classdef SigGen < handle
	% SigGen:  Signal generator for set of like trials
	%   (Applies to functional signals only, not voxel signals.)
	%   TODO: Add detailed comments

	properties (SetAccess = private)
		opt
		recurrenceParams
	end
	methods
		function obj = SigGen(W,varargin)
			[opt,optcell] = Opts.getOpts(varargin);
			Opts.validateW(opt,W);
			obj.opt = opt;
			obj.recurrenceParams = RecurrenceParams(W,optcell{:});
		end
		function [src,dst] = genSigs(obj)
			opt = obj.opt;
			rp = obj.recurrenceParams;
			wTrans = rp.W.';
			nsWTrans = rp.nonsourceW.';
			nt = opt.numTimeSteps;
			nf = opt.numFuncSigs;
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

				currSrc = currSrc + opt.noisinessForSource * randn(nf,1);
				currDst = currDst + opt.noisinessForDest * randn(nf,1);
				currOth = currOth + opt.noisinessForSource * randn(nf,1);

				src(i,:) = currSrc';
				dst(i,:) = currDst';
				prevSrc = currSrc;
				prevDst = currDst;
				prevOth = currOth;
			end
			src = zscore(src);
			dst = zscore(dst);
		end
		function W = W(obj)
			W = obj.recurrenceParams.W;
		end
	end
end
