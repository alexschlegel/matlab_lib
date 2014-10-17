function Run(g,c,kStart,S,varargin) 
% SoundGen.Generate.NGram.Run
% 
% Description:	run the NGram generate process
% 
% Syntax:	g.Run(c,kStart,S,<options>)
% 
% In:
% 	c		- an Mx1 cluster string array
%	kStart	- the index in c at which to start
%	S		- the length of the cluster string to generate
%	<options>:
%		generate_n:	(g.n) the n-gram length
%		reset:		(false) true to reset results calculated during previous runs
% 
% Side-effects:	sets g.result, an Sx1 generated cluster string array
% 
% Updated: 2012-11-02
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
ns	= status('generating cluster string (ngram)','silent',g.silent);

opt	= ParseArgs(varargin,...
		'generate_n'	, g.n	, ...
		'reset'			, false	  ...
		);

bRan	= g.ran && ~opt.reset;

%generate the corpus statistics
if ~bRan || opt.generate_n~=g.intermediate.nlast
	n	= opt.generate_n;
	
	%add the beginning to the end
		c	= [c; c(1:n-1)];
	
	nC	= numel(c);
	
	%get the (n-1)-length substrings
		status(['constructing ngrams (n=' num2str(n) ')'],ns+1,'silent',g.silent);
		
		ngram	= [];
		
		for kS=1:n
			kE	= n*floor((nC-kS+1)/n) + kS - 1;
			
			ngram	= [ngram; reshape(c(kS:kE),n,[])'];
		end
		
		nNGram	= size(ngram,1);
	%get the unique strings and their frequency
		status('finding unique ngrams',ns+1,'silent',g.silent);
		
		[ngramU,kFrom,kTo]	= unique(ngram,'rows');
		nNGramU				= size(ngramU,1);
	%get the frequency of each unique ngram
		status('calculating ngram frequencies',ns+1,'silent',g.silent);
		
		fNGramU	= hist(kTo,1:nNGramU);
		
		%order from frequent to infrequent
			[freq,kSort]	= sort(fNGramU,'descend');
			ngram			= ngramU(kSort,:);
		
			sub	= ngram;
			sub	= sub(:,1:end-1);
		
		ngram	= mat2cell(ngram,ones(nNGramU,1),n);
	%save to intermediate
		g.intermediate.nlast	= n;
		g.intermediate.ngram	= ngram;
		g.intermediate.freq		= freq;
		g.intermediate.sub		= sub;
else
	n		= g.intermediate.nlast;
	ngram	= g.intermediate.ngram;
	freq	= g.intermediate.freq;
	sub		= g.intermediate.sub;
	
	status(['already calculated corpus statistics (n=' num2str(n) ')'],ns+1,'silent',g.silent);
end

%generate the cluster string
	status('generating cluster string',ns+1,'silent',g.silent);
	
	gen	= zeros(S,1);
	
	%get the start of the string
		gen(1:n)	= c(kStart + (0:n-1));
	%now pick the rest
		nJoin	= n-1;
		nNGram	= size(sub,1);
		
		for kAdd=n+1:S
			%find all blocks that begin with the end of the string
				genEnd	= gen(kAdd-nJoin:kAdd-1)';
				
				b	= all(sub==repmat(genEnd,[nNGram 1]),2);
			%pick randomly from one of these blocks
				genAdd	= distpick(ngram(b),freq(b));
			%add it
				gen(kAdd)	= genAdd(end);
		end
	
	g.result	= gen;
	