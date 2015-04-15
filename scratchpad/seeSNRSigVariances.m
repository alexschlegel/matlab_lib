
for seed=3:2:5 % NOTE: seed 4 gives bad behavior with nVoxel=20

snrVals=[0.3 3 30];
for snrIdx=1:3

snr=snrVals(snrIdx);
%pp=Pipeline('nRun',100,'normVar',normVar);
nVoxel=100; % (The default)
nVoxel=20;  % (Override the default)
pp=Pipeline('nRun',100,'snrMode','norm','snr',snr,'nVoxel',nVoxel);
rng(seed,'twister');
doDebug=false;
sW=generateStructOfWs(pp,doDebug);
[~,target]=generateBlockDesign(pp,doDebug);
%block=ones(size(block));
t1=repmat({'A'},size(target{1}));
target=repmat({t1},size(target));
[sigs{1},sigs{2}]=generateSignalNoiseMixture(pp,[],target,sW,doDebug);
signame={'X','Y'};

for kS=1:2
	S=sigs{kS};
	vars=squeeze(var(S,0,2));
	funcSigsToShow=[1 2 11 12];
	nFuncSigsToShow=numel(funcSigsToShow);
	title=sprintf(['Variance of %s across runs '...
		'with SNR %g '...
		'(seed=%d)'],...
		signame{kS},snr,seed);
	legend=cell(nFuncSigsToShow,1);
	for kL=1:nFuncSigsToShow
		legend{kL}=sprintf('Func sig %d',funcSigsToShow(kL));
	end
	alexplot(1:size(vars,1),num2cell(vars(:,funcSigsToShow),1),...
		'title',title,...
		'xlabel','Time t (in TRs)',...
		'ylabel',sprintf('var(%s[t])',signame{kS}),...
		'legend',legend...
		);
end

end

end
