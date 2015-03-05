function [a,label] = cvtPlotCapsule2Array(capsule)
	if isstruct(capsule)
		[a,label]	= cvtPlotCapsule2Array({capsule});
		return;
	end
	if isempty(capsule)
		label		= {'seed','acc','p'};
		a			= zeros(0,0,0,numel(label));
		return;
	end

	nCapsule		= numel(capsule);
	sizeResult		= size(capsule{1}.result);
	[~,label]		= cvtPlotCapsule2Array({});
	a				= zeros([sizeResult nCapsule numel(label)]);

	for kCap=1:nCapsule
		rgrid			= capsule{kCap}.result;
		a(:,:,kCap,1)	= cellfun(@(r) r.seed,rgrid);
		a(:,:,kCap,2)	= cellfun(@(r) r.summary.alex.acc,rgrid);
		a(:,:,kCap,3)	= cellfun(@(r) r.summary.alex.p,rgrid);
	end

end
