% Copyright (c) 2014 Trustees of Dartmouth College. All rights reserved.

classdef CausalSimulator < handle
	% CausalSimulator:  Parent class for study of causal flows
	%   TODO: Add detailed comments

	properties (SetAccess = private)
		baseParams
		sigGen
		voxelPolicy
		pcaPolicy
	end
	properties
		autoShowResults = true
	end

	methods
		function obj = CausalSimulator(sigGen,voxelPolicy,pcaPolicy)
			if sigGen.baseParams ~= voxelPolicy.baseParams
				error('Arguments have incompatible baseParams.');
			end
			switch pcaPolicy
				case 'runPCA'
				case 'skipPCA'
				otherwise
					error('Invalid pcaPolicy %s',pcaPolicy);
			end
			obj.baseParams = sigGen.baseParams;
			obj.sigGen = sigGen;
			obj.voxelPolicy = voxelPolicy;
			obj.pcaPolicy = pcaPolicy;
		end
		function M = makeColumnMeansZero(~,M)
			M = M - repmat(mean(M),size(M,1),1);
		end
		function F = massageFunctionalSigs(obj,F) %#ok
			% (Action specialized in subclasses)
			%
			%F = obj.makeColumnMeansZero(F);
		end
		function data = performAll(obj)
			data = SimulationData(obj);
			obj.performFunctionalSynthesis(data);
			obj.performVoxelSynthesis(data);
			obj.performPCA(data);
			obj.performCausalityComputation(data);
		end
		function performCausalityComputation(obj,data)
			nc = obj.baseParams.numTopComponents;
			data.wStar = zeros(nc,nc);
			for i = 1:nc
				for j = 1:nc
					%fprintf('Granger for (%d,%d)\n',i,j);
					srcP = data.source.pcaSigs(:,i);
					dstP = data.dest.pcaSigs(:,j);
					data.wStar(i,j) = GrangerCausality(srcP,dstP);
				end
			end
		end
		function performFunctionalSynthesis(obj,data)
			[data.source.funcSigs, data.dest.funcSigs] = ...
				obj.sigGen.genSigs;
		end
		function performPCA(obj,data)
			obj.performRegionPCA(data.source);
			obj.performRegionPCA(data.dest);
		end
		function performRegionPCA(obj,region)
			switch obj.pcaPolicy
				case 'runPCA'
					[region.pcaCoeff, region.pcaSigs] = ...
						pca(region.voxelSigs);
				case 'skipPCA'
					region.pcaSigs = region.funcSigs;
				otherwise
					error('Unknown pcaPolicy');
			end
		end
		function performVoxelSynthesis(obj,data)
			data.source.voxelSigs = obj.voxelPolicy.mixFuncSigs(...
				data.source.funcSigs,1);
			data.dest.voxelSigs = obj.voxelPolicy.mixFuncSigs(...
				data.dest.funcSigs,2);
		end
		function data = runTest(obj)
			data = obj.performAll;
			if obj.autoShowResults
				obj.showResults(data);
			end
		end
		function showParams(obj)
			fprintf('Num time steps = %d\nNum functional sigs = %d\n',...
				obj.baseParams.numTimeSteps, obj.baseParams.numFuncSigs);
			fprintf('Num voxel sigs = %d\nNum top components = %d\n',...
				obj.baseParams.numVoxelSigs,...
				obj.baseParams.numTopComponents);
			fprintf('Source noisiness = %d\n',...
				obj.baseParams.sourceNoisiness);
			fprintf('Destination noisiness = %d\n',...
				obj.baseParams.destNoisiness);
			fprintf('Voxel-mixing freedom = %d\n', obj.voxelPolicy.freedom);
			falseTrue = {'false','true'};
			fprintf('Is destination balanced = %s\n',...
				falseTrue{obj.sigGen.isDestBalancing+1});
		end
		function showRatios(obj,data)
			ratios = data.source.pcaSigs(:,1:obj.baseParams.numFuncSigs) ...
				./ data.source.funcSigs;
			CausalSimulator.showUpperLeftAndMeanAndVariance(ratios,...
				{'Ratios of pcaSigs to funcSigs:',...
				'Means of ratios:',...
				'Variances of ratios:'});
		end
		function showResults(obj,data)
			disp(repmat('=',1,70));
			disp(class(obj));
			obj.showParams;
			disp(repmat('-',1,70));
			fprintf(...
				'Matrices below are clipped for readability.\n\n');
			%{
			maxDisplayRows = 10;
			maxDisplayCols = 3;
			disp(['Source funcSigs vs. source pcaSigs ' ...
				'(with zero column as separator):']);
			Sf = SimStatic.clipmat(data.source.funcSigs,...
				maxDisplayRows,maxDisplayCols);
			Sp = SimStatic.clipmat(data.source.pcaSigs,...
				maxDisplayRows,maxDisplayCols);
			disp([Sf zeros(size(Sf,1),1) Sp]);
			obj.showRatios(data);
			%}
			maxDispDim = 7;
			disp('W:');
			disp(SimStatic.clipmat(obj.sigGen.W,maxDispDim,maxDispDim));
			disp('Granger Causality scores among top components:');
			disp(SimStatic.clipmat(data.wStar,maxDispDim,maxDispDim));
			colsums = sum(data.wStar,1);
			rowsums = sum(data.wStar,2);
			disp('Granger Causality column and (transposed) row sums:');
			disp(SimStatic.clipmat([colsums;rowsums'],2,maxDispDim));
		end
	end

	methods (Static)
		function runDensityExample(varargin)
			[opt,optcell] = Opts.getOpts(varargin);
			nf = opt.numFuncSigs;
			dimsList = {1, 2, [1 2]};
			wStar5D = zeros(nf,nf,numel(dimsList),opt.maxWOnes,...
				opt.iterations);
			for i = 1:numel(dimsList)
				for count = 1:opt.iterations
					rng(opt.rngSeedBase+count-1,'twister');
					data = CausalSimulator.runDensityTest(...
						dimsList{i},optcell{:});
					for j = 1:numel(data)
						wStar5D(:,:,i,j,count) = data(j).wStar;
					end
				end
			end
			wStar4D = mean(wStar5D,5);
			sizeW4 = size(wStar4D);
			figGrid = zeros(sizeW4(3:4));
			clims = IntensityPlot.getGlobalClims(wStar4D,...
				opt.outlierPercentage);
			for i = 1:size(wStar4D,3)
				for j = 1:size(wStar4D,4)
					figGrid(i,j) = IntensityPlot.showGrayscale(...
						wStar4D(:,:,i,j),clims);
				end
			end
			% (Can also use subplot to make a grid of plots in one figure)
			set(figGrid, 'Position', [0 0 150 100]);
			multiplot(figGrid);  %was: multiplot(reshape(1:15,5,3)');
			colormap('gray');
		end
		function data = runDensityTest(whichDims,varargin)
			[opt,optcell] = Opts.getOpts(varargin);
			if numel(whichDims) > 2
				error('Too many dims in whichDims.');
			end
			dimsMask = 0.5*bitor(2^whichDims(1),2^whichDims(end));
			bp = CausalBaseParams(optcell{:});
			nf = bp.numFuncSigs;
			data = repmat(SimulationData([]),1,opt.maxWOnes);
			for i = 1:opt.maxWOnes
				W = zeros(nf);
				if dimsMask == 1
					W(1:i,1) = ones(i,1);
				elseif dimsMask == 2
					W(1,1:i) = ones(1,i);
				elseif dimsMask == 3
					W(1:i,1:i) = diag(ones(i,1));
				else
					error('Invalid dimensions.');
				end
				data(i) = CausalSimulator.runW(bp,W,optcell{:});
			end
		end
		function data = runW(baseParams,W,varargin)
			[opt,optcell] = Opts.getOpts(varargin);
			baseParams.validateW(W);  % (redundant, but not harmful)
			gen = SigGen(baseParams,W,optcell{:});
			voxPol = VoxelPolicy(baseParams,opt.voxelFreedom);
			data = CausalSimulator(gen,voxPol,opt.pcaPolicy).runTest;
		end
		function showUpperLeftAndMeanAndVariance(M,headings)
			disp(headings{1});
			maxDisplayRows = 12;
			maxDisplayCols = 5;
			disp(SimStatic.clipmat(M,maxDisplayRows,maxDisplayCols));
			disp(headings{2});
			disp(SimStatic.clipmat(mean(M),1,maxDisplayCols));
			disp(headings{3});
			disp(SimStatic.clipmat(var(M),1,maxDisplayCols));
		end
	end
end

