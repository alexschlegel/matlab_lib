
function [data,p] = rand_chaining(seedType,nSeq,nT,range)

% TODO: Use ParseArgs to set parameters

defaults		= {'int32',50000,500,intmax};
toyDefaults		= {'int16',150,100,30000}; %#ok

if nargin < 1
	seedType	= defaults{1};
end
if nargin < 2
	nSeq		= defaults{2};
end
if nargin < 3
	nT			= defaults{3};
end
if nargin < 4
	range		= defaults{4};
end

fprintf('Expected computation time on low-end 2012 MBP = %g sec\n', ...
		nSeq*nT*6e-4);
fprintf('Please wait...\n');
start_ms	= nowms;

data.seedType		= seedType;
data.nSeq			= nSeq;
data.nT				= nT;
data.range			= range;
data.nDupChained	= getNumDupsAcrossSeqs(seedType,'chained',nSeq,nT,range);
data.nDupUnchained	= getNumDupsAcrossSeqs(seedType,'unchained',nSeq,nT,range);
p					= [];

end_ms		= nowms;
fprintf('Time (seconds): %g\n',(end_ms-start_ms)/1000);

filename	= sprintf('%s_rand_chain_%s_%d_%d_%d.mat', ...
				FormatTime(start_ms,'yyyymmdd_HHMMSS'), ...
				seedType,nSeq,nT,range);
save(filename,'data');
fprintf('Dup counts saved to ''%s''\n',filename);

%{
% TODO: Convert following code to use alexplot
figure;
p	= plot(1:data.nT,data.nDupChained,1:data.nT,data.nDupUnchained);
title(sprintf(...
	'Collisions across %d Random Integer Sequences with Range %d', ...
	data.nSeq,data.range));
xlabel('Time (index into sequence)');
ylabel('Number of collisions');
legend(sprintf('chained with %s',data.seedType),'unchained');
%}

end

function nDup = getNumDups(seqGrid)
	s		= sort(seqGrid,2);
	nDup	= sum(s(:,1:end-1) == s(:,2:end),2);
end

function nDup = getNumDupsAcrossSeqs(seedType,chainOption,nSeq,nT,range)
	rng(0,'twister');

	nDup	= getNumDups(makeRandiSeq(seedType,chainOption,[nT,nSeq],range));
end

function seq = makeRandiSeq(seedType,chainOption,seqSize,range)
	nrow		= seqSize(1);
	ncol		= prod(seqSize(2:end));
	if ncol ~= 1
		seq		= zeros(nrow,ncol);
		seeds	= randi(intmax(seedType),1,ncol);
		for kcol=1:ncol
			rng(seeds(kcol),'twister');
			seq(:,kcol)	= makeRandiSeq(seedType,chainOption,nrow,range);
		end
		seq		= reshape(seq,seqSize);
	else
		switch chainOption
			case 'chained'
				seq	= zeros(nrow,1);
				for i=1:nrow
					seq(i)	= randi(range);
					rng(randi(intmax(seedType)),'twister');
				end
			case 'unchained'
				seq	= randi(range,2*nrow,1);
				seq = seq(1:2:end);
			otherwise
				error('Unknown option %s',chainOption);
		end
	end
end
