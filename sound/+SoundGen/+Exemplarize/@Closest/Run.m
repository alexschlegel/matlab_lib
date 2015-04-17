function Run(e,x,rate,s,c,str,kStart,varargin) 
% SoundGen.Exemplarize.Closest.Run
% 
% Description:	choose each candidate exemplar such that its preceding segment
%				most closely resembles the current leading edge exemplar
% 
% Syntax:	e.Run(x,rate,s,c,str,kStart,<options>)
% 
% In:
%	x		- an Nx1 audio signal
%	rate	- the sampling rate of x, in Hz
%	s		- an Mx2 array of segment start and end indices 
% 	c		- an Mx1 cluster string array
%	str		- an Sx1 generated cluster string
%	kStart	- the index in c at which the generator started
%	<options>:
%		exemplarize_n:			(e.n) the number of exemplars to consider as the
%								leading edge of the exemplar string.  see
%								SoundGen.Exemplarize.Closest.
%		exemplarize_data:		(e.data) the data to cluster.  see 
%								SoundGen.Exemplarize.Closest.
%		exemplarize_nfft:		(e.nfft) for data transformations that involve
%								fourier transforms, the N value to use
%		exemplarize_dist:		(e.dist) the exemplarize distance metric. see
%								SoundGen.Exemplarize.Closest.
%		exemplarize_groupdist:	(e.groupdist) the exemplarize group distance
%								metric.  see SoundGen.Exemplarize.Closest.
%		reset:					(false) true to reset results calculated during
%								previous runs
% 
% Side-effects:	sets e.result, an Sx1 array of segment index exemplars
% 
% Updated: 2015-04-09
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
ns	= status('exemplarizing data (closest)','silent',e.silent);

opt	= ParseArgs(varargin,...
		'exemplarize_n'			, e.n			, ...
		'exemplarize_data'		, e.data		, ...
		'exemplarize_nfft'		, e.nfft		, ...
		'exemplarize_dist'		, e.dist		, ...
		'exemplarize_groupdist'	, e.groupdist	, ...
		'reset'					, false			  ...
		);

bRan	= e.ran && ~opt.reset;

%transform the data
	bTXFunction	= false;
	
	if isa(opt.exemplarize_data,'function_handle')
	%custom function
		bTXFunction	= true;
		
		strTX	= 'custom';
		fTX		= opt.exemplarize_data;
	elseif ischar(opt.exemplarize_data)
	%string, either preset or parent property
		if ismember(lower(opt.exemplarize_data),{'signal','lcqft','hcqft'})
		%preset
			bTXFunction	= true;
		else
		%parent property?
			if isprop(e.parent,opt.exemplarize_data)
			%yep, does it have the intermediate.data field defined?
				if isfield(e.parent.(opt.exemplarize_data).intermediate,'d')
				%yep, use it
					status(['using data from ' opt.exemplarize_data ' step'],ns+1,'silent',e.silent);
					
					d	= e.parent.(opt.exemplarize_data).intermediate.d;
					
					e.intermediate.d		= d;
					e.intermediate.txlast	= [];
				else
				%use the default transformation
					bTXFunction	= true;
					
					opt.exemplarize_data	= e.parent.(opt.exemplarize_data).data;
				end
			else
			%wtf?
				error('Invalid exemplarize data specification.');
			end
		end
		
		if bTXFunction
			switch lower(opt.exemplarize_data)
				case 'signal'
					fTX	= @Data_NoTX;
				case 'lcqft'
					%spectral kernel, only needs to be calculated once
						sk	= [];
					
					fTX	= @Data_LCQFT;
				case 'hcqft'
					%spectral kernel, only needs to be calculated once
						sk	= [];
					
					fTX	= @Data_HCQFT;
			end
		end
	end
	
	if bTXFunction
		if ~bRan || ~isequal(fTX,e.intermediate.txlast)
		%transform the data
			bRan	= false;
			
			%transform
				strStatus	= ['transforming data (' strTX ')'];
				status(strStatus,ns+1,'silent',e.silent);
				
				kStart	= num2cell(s(:,1));
				kEnd	= num2cell(s(:,2));
				
				d	= cellfunprogress(@(s,e) fTX(x(s:e),rate),kStart,kEnd,'label',strStatus,'UniformOutput',false,'silent',e.silent);
			%construct the vector matrix
				nD		= cellfun(@numel,d);
				nMin	= min(nD);
				d		= cellfun(@(x) reshape(x(1:nMin),1,nMin),d,'UniformOutput',false);
				d		= cat(1,d{:});
				
				e.intermediate.txlast	= fTX;
				e.intermediate.d		= d;
		else
			status('already transformed data',ns+1,'silent',e.silent);
			
			d	= e.intermediate.d;
		end
	end
%get the distance between data vectors
	sDist	= repmat(size(d,1),[1 2]);
	
	if isa(opt.exemplarize_dist,'function_handle')
		strDist	= 'custom';
	else
		strDist	= lower(opt.exemplarize_dist);
	end
		
	if ~bRan || ~isequal(e.intermediate.distlast,opt.exemplarize_dist)
% 		status(['computing distance between data vectors (' strDist ')'],ns+1,'silent',e.silent);
		
% 		dist	= pdist(d,opt.exemplarize_dist);
% 		dist	= squareform(dist);
		
		dist	= sparse(sDist(1),sDist(2),0);
		
		e.intermediate.distlast	= opt.exemplarize_dist;
	else
% 		status('already computed distance between data vectors',ns+1,'silent',e.silent);
		
		dist	= e.intermediate.dist;
	end
%get the group distance function
	if isa(opt.exemplarize_groupdist,'function_handle')
		strDistGroup	= 'custom';
		fDistGroup		= opt.exemplarize_groupdist;
	elseif ischar(opt.exemplarize_groupdist) && ismember(lower(opt.exemplarize_groupdist),{'min','max','mean'})
		strDistGroup	= lower(opt.exemplarize_groupdist);
		fDistGroup		= switch2(lower(opt.exemplarize_groupdist),...
							'min'	, @min	, ...
							'max'	, @max	, ...
							'mean'	, @mean	  ...
							);
	else
		error('Invalid exemplarize groupdist specification.');
	end
%get the leading edge size
	if isnumeric(opt.exemplarize_n)
		n	= opt.exemplarize_n;
	elseif ischar(opt.exemplarize_n) && isprop(e.parent,opt.exemplarize_n)
	%use the n from another object
		if isprop(e.parent.(opt.exemplarize_n),'n')
			n	= e.parent.(opt.exemplarize_n).n;
		else
			n	= e.n_otherwise;
		end
	else
		
	end
%exemplarize!
	strStatus	= ['exemplarizing (groupdist=' strDistGroup ', n=' num2str(n) ')'];
	status(strStatus,ns+1,'silent',e.silent);
	
	bWarning	= false;
	
	S	= numel(str);
	ex	= NaN(1,S);
	
	%get the first leading edge of exemplars
		kLEC	= mod(kStart-1 + (0:n-1),numel(c)-1)+1;
		kLEStr	= mod(0:n-1,numel(str)-1)+1;
		
		kDiff	= unless(find(c(kLEC)~=str(kLEStr),1,'first'),n+1);
		
		ex(1:kDiff-1)	= kLEC(1:kDiff-1);
	%step through each exemplar
		%for strfind
			kSeg	= [1:numel(c) 1:n-1];
			ce		= [c; c(1:n-1)]';
			str		= str';
		
		progress('action','init','total',S-kDiff+1,'label',strStatus,'silent',e.silent,'status',false);
		for kS=kDiff:S
			%find the exemplars of the current cluster type that follow the
			%leading edge
				%leading edge
					kLE	= max(1,kS-n+1):kS-1;
					nLE	= numel(kLE);
					
					LEs	= ex(kLE);
					LEc	= str([kLE kS]);
				%find the occurrences of the leading edge subcluster string in
				%the corpus
					kSub	= reshape(strfind(ce,LEc),[],1);
					
					if isempty(kSub)
					%subcluster string doesn't exist, just pick a random segment
						if ~bWarning
							bWarning	= true;
							
							status('subcluster string not found in corpus!',ns+1,'silent',e.silent);
						end
						
						kSub	= randFrom(find(c(1:end-nLE+1)==str(kS)));
					end
					
					nSub	= numel(kSub);
				%find the corresponding subsegment string with the minimum group
				%distance from the leading edge exemplar string
					%segment indices of each subsegment string
						kSub	= repmat(kSub,[1 nLE]) + repmat(0:nLE-1,[nSub 1]);
					%distance of each segment from the corresponding leading
					%edge exemplar string
						kLEs	= repmat(LEs,[nSub 1]);
						
						k1		= kSeg(min(kSub,kLEs));
						k2		= kSeg(max(kSub,kLEs));
						kDist	= sub2ind(sDist,k1,k2);
						
						%calculate the distances
							kCalc				= find(dist(kDist)==0);
							dist(kDist(kCalc))	= arrayfun(@(k) pdist([d(k1(k),:); d(k2(k),:)],opt.exemplarize_dist)+eps,kCalc);
						
						LEDist	= full(dist(kDist));
					%group distances
						gDist	= fDistGroup(LEDist,2);
					%group with minimum group distance
						kMin	= find(gDist==min(gDist),1);
				%corresponding exemplar
					ex(kS)	= kSeg(kSub(kMin,end)+1);
			
			progress;
		end
	
	e.result	= ex';
%save the calculated distances
	e.intermediate.dist		= dist;


%------------------------------------------------------------------------------%
function x = Data_NoTX(x,rate)
	
end
%------------------------------------------------------------------------------%
function d = Data_LCQFT(x,rate)
	%calculate the CQFCCs of the signal
		dur	= k2t(numel(x)+1,rate);
		
		[cq,t,D,f,sk]	= CQFCC(x,rate,...
							'win'	, dur					, ...
							'hop'	, dur					, ...
							'n'		, opt.exemplarize_nfft	, ...
							'sk'	, sk					  ...
							);
	%calculate the lcqft
		d	= lcqft(cq,D);
end
%------------------------------------------------------------------------------%
function d = Data_HCQFT(x,rate)
	%calculate the CQFCCs of the signal
		dur	= k2t(numel(x)+1,rate);
		
		[cq,t,D,f,sk]	= CQFCC(x,rate,...
							'win'	, dur					, ...
							'hop'	, dur					, ...
							'n'		, opt.exemplarize_nfft	, ...
							'sk'	, sk					  ...
							);
	%calculate the hcqft
		d	= hcqft(cq,D);
end
%------------------------------------------------------------------------------%

end
