function Run(s,x,rate,varargin) 
% SoundGen.Segment.ChangeDetect.Run
% 
% Description:	calculate segments.  set segments at points in time where the
%				specified distance crosses the specified threshold.
% 
% Syntax:	s.Run(x,rate,<options>)
% 
% In:
% 	x		- an Nx1 audio signal
%	rate	- the sampling rate of the audio signal, in Hz
%	<options>:
%		segment_target:		(s.target) the target mean segment duration, in
%							seconds
%		segment_feature:	(s.feature) the audio feature to use
%		segment_nfft:		(s.nfft) the N to use for fourier transforms
%		segment_dur:		(s.dur) the duration of audio to use for each
%							feature calculation, in seconds
%		segment_hop:		(s.hop) the feature hop size to use, in seconds
%		segment_dist:		(s.dist) the distance metric to use on features
%		segment_compare:	(s.compare) the number of previous features to
%							compare
%		segment_depoly:		(s.depoly) the order of the polynomial to remove
%							from the distance array before thresholding
%		reset:				(false) true to reset results calculated during
%							previous runs
% 
% Side-effects: sets s.result, an Mx2 array of segment start and end indices
% 
% Updated: 2015-04-09
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'segment_target'	, s.target	, ...
		'segment_feature'	, s.feature	, ...
		'segment_nfft'		, s.nfft	, ...
		'segment_dur'		, s.dur		, ...
		'segment_hop'		, s.hop		, ...
		'segment_dist'		, s.dist	, ...
		'segment_compare'	, s.compare	, ...
		'segment_depoly'	, s.depoly	, ...
		'reset'				, false		  ...
		);

opt.segment_feature	= ForceCell(opt.segment_feature);

ns	= status('segmenting data (changedetect)','silent',s.silent);

nX	= numel(x);

bRan	= s.ran && ~opt.reset;

%calculate the features
	%get the feature functions
		nFeature				= numel(opt.segment_feature);
		[fFeature,cStrFeature]	= deal(cell(nFeature,1));
		
		bCQFT	= false;
		
		for kF=1:nFeature
			if isa(opt.segment_feature{kF},'function_handle')
				cStrFeature{kF}	= 'custom';
				fFeature{kF}	= opt.segment_feature{kF};
			else
				switch opt.segment_feature{kF}
					case 'signal'
						fFeature{kF}	= @Feature_Signal;
					case 'lcqft'
						bCQFT	= true;
						
						%spectral kernel, only needs to be calculated once
							sk		= [];
							
						fFeature{kF}	= @Feature_LCQFT;
					case 'hcqft'
						bCQFT	= true;
							
						%spectral kernel, only needs to be calculated once
							sk	= [];
						
						fFeature{kF}	= @Feature_HCQFT;
				end
				
				cStrFeature{kF}	= opt.segment_feature{kF};
			end
		end
	
	kStart	= (1:opt.segment_hop*rate:nX)';
	kEnd	= round(kStart + opt.segment_dur*rate);
	kStart	= round(kStart);
	
	bGood	= kEnd<=nX;
	kStart	= kStart(bGood);
	kEnd	= kEnd(bGood);
	nSeg	= numel(kStart);
	
	if ~bRan || s.intermediate.durlast~=opt.segment_dur || s.intermediate.hoplast~=opt.segment_hop || ~isequal(cellfun(@func2str,fFeature,'UniformOutput',false),cellfun(@func2str,s.intermediate.featurelast,'UniformOutput',false))
		bRan	= false;
		
		%calculate features
			strStatus	= ['calculating features (dur=' num2str(opt.segment_dur) ', hop=' num2str(opt.segment_hop) ', ' join(cStrFeature,',') ')'];
			status(strStatus,ns+1,'silent',s.silent);
			
			if bCQFT
				cqft	= cell(nSeg,1);
			end
			
			d	= cell(nFeature,1);
			
			progress('action','init','total',nFeature,'name','feature','label','Calculating features','silent',s.silent);
			for kF=1:nFeature
				d{kF}	= cell(nSeg,1);
				
				progress('action','init','total',nSeg,'name','segment','label',cStrFeature{kF},'silent',s.silent);
				for kS=1:nSeg
					d{kF}{kS}	= reshape(fFeature{kF}(x(kStart(kS):kEnd(kS)),rate),1,[]);
					
					progress('name','segment');
				end
				
				progress('name','feature');
			end
		
		s.intermediate.featurelast	= fFeature;
		s.intermediate.durlast		= opt.segment_dur;
		s.intermediate.hoplast		= opt.segment_hop;
		s.intermediate.d			= d;
	else
		status('already calculated features',ns+1,'silent',s.silent);
		
		d	= s.intermediate.d;
	end
%calculate the needed distances
	if ~bRan || s.intermediate.clast~=opt.segment_compare || ~isequal(s.intermediate.distlast,opt.segment_distance) || s.intermediate.plast~=opt.segment_depoly
		status(['calculating distances (d=' opt.segment_dist ', c=' num2str(opt.segment_compare) ')'],ns+1,'silent',s.silent);
			
		bRan	= false;
		
		%get the pairs we need distances for
			kSeg		= repmat((1:nSeg)',[1 opt.segment_compare]);
			kCompare	= kSeg - repmat(1:opt.segment_compare,[nSeg 1]);
			kPair		= [reshape(kSeg,[],1) reshape(kCompare,[],1)];
			kCalc		= 1:numel(kSeg);
			
			bBad			= any(kPair<1,2);
			kPair(bBad,:)	= [];
			kCalc(bBad)		= [];
			nPair			= size(kPair,1);
		%calculate the distances
			dist	= NaN(nSeg,nFeature);
			
			progress('action','init','total',nFeature,'name','feature','label','Calculating distance for each feature','silent',s.silent);
			for kF=1:nFeature
				distCur		= NaN(nSeg,opt.segment_compare);
				distPair	= NaN(nPair,1);
				
				progress('action','init','total',nPair,'name','pair','label',cStrFeature{kF},'silent',s.silent);
				
				for kP=1:nPair
					dCur			= [d{kF}{kPair(kP,1)}; d{kF}{kPair(kP,2)}];
					distPair(kP)	= pdist(dCur,opt.segment_dist);
					
					progress('name','pair');
				end
				
				distCur(kCalc)	= distPair;
				dist(:,kF)		= nanmedian(distCur,2);
				
				progress('name','feature');
			end
			
			dist	= nanmax(dist,[],2);
			
			%depoly
				dist	= depoly(dist,opt.segment_depoly);
		
		s.intermediate.clast	= opt.segment_compare;
		s.intermediate.distlast	= opt.segment_dist;
		s.intermediate.plast	= opt.segment_depoly;
		s.intermediate.dist		= dist;
	else
		status('already calculated distances',ns+1,'silent',s.silent);
		
		dist	= s.intermediate.dist;
	end
%determine the threshold
	if ~bRan || s.intermediate.target~=opt.segment_target
		status(['calculating threshold (target=' num2str(opt.segment_target) 's)'],ns+1,'silent',s.silent);
		
		bRan	= false;
		
		%time at each uniform segment
			tSeg	= k2t(kStart,rate);
			tTotal	= k2t(numel(x)+1,rate);
		
		%order the distances from largest to smallest
			distO	= unique(dist);
			distO	= distO(~isnan(distO));
			distO	= distO(end:-1:1);
			nDist	= numel(distO);
		
		%step the threshold down until we get close to the mean target duration
			bSeg	= NaN(size(dist));
			mDur	= inf;
			for kD=1:nDist
				bSegLast	= bSeg;
				bSeg		= dist>=distO(kD);
				
				%mean time between segment borders
					mDurLast	= mDur;
					mDur		= mean(diff([0; tSeg(bSeg); tTotal]));
				
				if mDur<opt.segment_target
					break;
				end
			end
		%keep the threshold with the duration closest to the target
			if abs(mDurLast-opt.segment_target)<abs(mDur-opt.segment_target)
				bSeg	= bSegLast;
			end
		
		s.intermediate.target	= opt.segment_target;
		s.intermediate.bseg		= bSeg;
	else
		status('already calculated threshold',ns+1,'silent',s.silent);
		
		bSeg	= s.intermediate.bseg;
	end
%construct the segments
	kStart	= [1; kStart(bSeg)];
	kEnd	= [kStart(2:end); numel(x)];
	
	s.result	= [kStart kEnd];


%------------------------------------------------------------------------------%
function x = Feature_Signal(x,rate)
	
end
%------------------------------------------------------------------------------%
function d = Feature_LCQFT(x,rate)
	if bCQFT && ~isempty(cqft{kS})
		d	= lcqft(cqft{kS}{1},cqft{kS}{2});
	else
	%calculate the CQFCCs of the signal
		dur	= k2t(numel(x)+1,rate);
		
		[cq,t,D,f,sk]	= CQFCC(x,rate,...
							'win'	, dur				, ...
							'hop'	, dur				, ...
							'n'		, opt.segment_nfft	, ...
							'sk'	, sk				  ...
							);
	%calculate the lcqft
		d	= lcqft(cq,D);
	%save the result
		if bCQFT
			cqft{kS}	= {cq D};
		end
	end
end
%------------------------------------------------------------------------------%
function d = Feature_HCQFT(x,rate)
	if bCQFT && ~isempty(cqft{kS})
		d	= hcqft(cqft{kS}{1},cqft{kS}{2});
	else
	%calculate the CQFCCs of the signal
		dur	= k2t(numel(x)+1,rate);
		
		[cq,t,D,f,sk]	= CQFCC(x,rate,...
							'win'	, dur				, ...
							'hop'	, dur				, ...
							'n'		, opt.segment_nfft	, ...
							'sk'	, sk				  ...
							);
	%calculate the hcqft
		d	= hcqft(cq,D);
	%save the result
		if bCQFT
			cqft{kS}	= {cq D};
		end
	end
end
%------------------------------------------------------------------------------%

end
