
for seed=1:3

for doNormVar=0:1

pp=Pipeline('nRun',100,'normVar',doNormVar);
rng(seed,'twister');
doDebug=false;
sW=generateStructOfWs(pp,doDebug);
[~,target]=generateBlockDesign(pp,doDebug);
%block=ones(size(block));
t1=repmat({'A'},size(target{1}));
target=repmat({t1},size(target));
[sigs{1},sigs{2}]=generateFunctionalSignals(pp,[],target,sW,doDebug);
signame={'X','Y'};

for kS=1:2
	S=sigs{kS};
	vars=squeeze(var(S,0,2));
	nFuncSigsToShow=3;
	%-%%%%%figure; plot(1:size(vars,1),vars(:,1:nFuncSigsToShow));
	withOrWithout={'with','without'};
	title=sprintf(['Variance of %s across runs, '...
		'%s variance normalization '...
		'(seed=%d)'],...
		signame{kS},withOrWithout{2-doNormVar},seed);
	legend=cell(nFuncSigsToShow,1);
	for kL=1:nFuncSigsToShow
		legend{kL}=sprintf('Func sig %d',kL);
	end
	alexplot(1:size(vars,1),num2cell(vars(:,1:nFuncSigsToShow),1),...
		'title',title,...
		'xlabel','Time t (in TRs)',...
		'ylabel',sprintf('var(%s[t])',signame{kS}),...
		'legend',legend...
		);
end

end

end
