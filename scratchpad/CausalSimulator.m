% Copyright (c) 2014 Trustees of Dartmouth College. All rights reserved.

classdef CausalSimulator < handle
	% CausalSimulator:  Parent class for study of causal flows
	%   TODO: Add detailed comments

	properties (SetAccess = private)
		opt
		sigGen
		voxelPolicy
		pcaPolicy
	end
	properties
		autoShowResults = true
	end

	methods
		function obj = CausalSimulator(sigGen,voxelPolicy,pcaPolicy)
			if Opts.optConflict(sigGen.opt,voxelPolicy.opt)
				error('Arguments have incompatible opt variables.');
			end
			switch pcaPolicy
				case 'runPCA'
				case 'skipPCA'
				otherwise
					error('Invalid pcaPolicy %s',pcaPolicy);
			end
			obj.opt = sigGen.opt;
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
			nc = obj.opt.numTopComponents;
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
				obj.opt.numTimeSteps, obj.opt.numFuncSigs);
			fprintf('Num voxel sigs = %d\nNum top components = %d\n',...
				obj.opt.numVoxelSigs,...
				obj.opt.numTopComponents);
			fprintf('Source noisiness = %d\n',...
				obj.opt.noisinessForSource);
			fprintf('Destination noisiness = %d\n',...
				obj.opt.noisinessForDest);
			fprintf('Voxel-mixing freedom = %d\n', obj.opt.voxelFreedom);
			falseTrue = {'false','true'};
			fprintf('Is destination balanced = %s\n',...
				falseTrue{obj.opt.isDestBalancing+1});
		end
		function showRatios(obj,data)
			ratios = data.source.pcaSigs(:,1:obj.opt.numFuncSigs) ...
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
			gridSize = [numel(dimsList) opt.maxWOnes];
			dataGrid = cell(gridSize);
			auxW4D = zeros([nf nf gridSize]);
			wStar5D = zeros([size(auxW4D) opt.iterations]);
			for i = 1:gridSize(1)
				for count = 1:opt.iterations
					rng(opt.rngSeedBase+count-1,'twister');
					data = CausalSimulator.runDensityTest(...
						dimsList{i},optcell{:});
					if numel(data) ~= gridSize(2)
						error('Sizing error.');
					end
					for j = 1:gridSize(2)
						if count == 1
							dataGrid{i,j} = data(j);
							auxW4D(:,:,i,j) = data(j).simulator...
								.sigGen.recurrenceParams.nonsourceW;
						end
						wStar5D(:,:,i,j,count) = data(j).wStar;
					end
				end
			end
			wStar4D = mean(wStar5D,5);
			climsAuxW = IntensityPlot.getGlobalClims(auxW4D,0);
			climsWStar = IntensityPlot.getGlobalClims(wStar4D,...
				opt.outlierPercentage);
			fplotter = FuncSetPlotter;
			fplotter.timeBegin = 101;
			fplotter.timeCount = 40;
			fplotter.funcIdxBegin = 1;
			fplotter.funcIdxCount = 5;
			figGrid = zeros([gridSize 2 2]);
			for i = 1:gridSize(1)
				for j = 1:gridSize(2)
					dataCell = dataGrid{i,j};
					figGrid(i,j,1,1) = ...
						fplotter.showSigs(dataCell.source.funcSigs);
					figGrid(i,j,2,1) = ...
						fplotter.showSigs(dataCell.dest.funcSigs);
					figGrid(i,j,1,2) = IntensityPlot.showGrayscale(...
						auxW4D(:,:,i,j),climsAuxW);
					figGrid(i,j,2,2) = IntensityPlot.showGrayscale(...
						wStar4D(:,:,i,j),climsWStar);
				end
			end
			figGrid = reshape(permute(figGrid,[3 1 4 2]),2*gridSize);
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
			nf = opt.numFuncSigs;
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
				data(i) = CausalSimulator.runW(W,optcell{:});
			end
		end
		function data = runW(W,varargin)
			[opt,optcell] = Opts.getOpts(varargin);
			Opts.validateW(opt,W);
			gen = SigGen(W,optcell{:});
			voxPol = VoxelPolicy(optcell{:});
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

