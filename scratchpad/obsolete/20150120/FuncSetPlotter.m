% Copyright (c) 2014 Trustees of Dartmouth College. All rights reserved.

classdef FuncSetPlotter
	% FuncSetPlotter:  Class for generating one plot w/ multiple functions
	%   TODO: Add detailed comments

	properties
		timeBegin = 1;
		timeCount = 1e4;
		funcIdxBegin = 1;
		funcIdxCount = 100;
	end

	methods
		function obj = FuncSetPlotter
		end
		function figHandle = showSigs(obj,sigs)
			figHandle = figure;
			timeRange = obj.getRange(size(sigs,1),...
				obj.timeBegin,obj.timeCount);
			funcIdxRange = obj.getRange(size(sigs,2),...
				obj.funcIdxBegin,obj.funcIdxCount);
			vars = var(sigs);
			minvars = min(vars);
			zsigs = zscore(sigs,0,1);
			subsigs = zsigs(timeRange,funcIdxRange);
			tieredsigs = obj.tierSigs(subsigs);
			p = plot(timeRange,tieredsigs);
			for i = 1:size(tieredsigs,2)
				logr = log(1+log(max(1e-20,vars(i))/max(1e-20,minvars)));
				beta = min(1,logr);
				alpha = 1-beta;
				set(p(i),'Color',[beta 0 alpha]);
			end
		end
		function range = getRange(obj,extent,offset,count)
			if count < 1
				error('Count must be positive');
			end
			first = max(1,min(offset,extent-count+1));
			last = min(extent,first+count-1);
			range = first:last;
		end
		function sigs = tierSigs(obj,sigs)
			numsigs = size(sigs,2);
			addends = (4*numsigs-2):-4:2;
			sigs = sigs + repmat(addends,size(sigs,1),1);
			sigs = max(0,sigs);
			sigs = min(sigs,4*numsigs);
		end
	end

	methods (Static)
	end
end
