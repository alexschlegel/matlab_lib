% Copyright (c) 2014 Trustees of Dartmouth College. All rights reserved.

classdef FuncSetPlotter
	% FuncSetPlotter:  Class for generating one plot w/ multiple functions
	%   TODO: Add detailed comments

	properties
		timeBegin
		timeCount
		funcIdxBegin
		funcIdxCount
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
			zsigs = zscore(sigs,0,1);
			subsigs = zsigs(timeRange,funcIdxRange);
			tieredsigs = obj.tierSigs(subsigs);
			plot(timeRange,tieredsigs);
		end
		function range = getRange(obj,extent,offset,count)
			if count < 1
				error('Count must be positive');
			end
			first = max(0,min(offset,extent-count+1));
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
