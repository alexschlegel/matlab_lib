function Run(c,x,rate,s,varargin) 
% SoundGen.Cluster.ClusterData.Run
% 
% Description:	cluster audio segments using 
% 
% Syntax:	c.Run(x,rate,s,<options>)
% 
% In:
% 	x		- an Nx1 audio signal
%	rate	- the sampling rate of the audio signal, in Hz
%	s		- an Mx2 array of segment start and end indices
%	<options>:
%		cluster_data:		(c.data) the data to cluster.  see 
%							SoundGen.Cluster.ClusterData.
%		cluster_nfft:		(c.nfft) for data transformations that involve
%							fourier transforms, the N value to use
%		cluster_dist:		(c.dist) the cluster distance metric. see
%							SoundGen.Cluster.ClusterData.
%		cluster_linkage:	(c.linkage) the clusterdata linkage parameter
%		cluster_cutoff:		(c.cutoff) the CUTOFF argument to clusterdata
%		reset:				(false) true to reset results calculated during
%							previous runs
% 
% Side-effects: sets c.result, an Mx1 cluster string array of clusters assigned
%				to each segment
% 
% Updated: 2012-11-18
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
ns	= status('clustering data (clusterdata)','silent',c.silent);

opt	= ParseArgs(varargin,...
		'cluster_data'		, c.data	, ...
		'cluster_nfft'		, c.nfft	, ...
		'cluster_dist'		, c.dist	, ...
		'cluster_linkage'	, c.linkage	, ...
		'cluster_cutoff'	, c.cutoff	, ...
		'reset'				, false		  ...
		);
bCustom	= ~isequal(opt.cluster_data,c.data) || opt.cluster_nfft~=c.nfft || ~isequal(opt.cluster_dist,c.dist) || ~isequal(opt.cluster_linkage,c.linkage) || opt.cluster_cutoff~=c.cutoff;

bRan	= c.ran && ~opt.reset && ~bCustom;

%transform the data
	%get the transform function
		if isa(opt.cluster_data,'function_handle')
			strTX	= 'custom';
			
			fTX	= opt.cluster_data;
		else
			switch lower(opt.cluster_data)
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
				otherwise
					error('Invalid cluster data specification.');
			end
			
			strTX	= lower(opt.cluster_data);
		end
	
	if ~bRan || ~isequal(func2str(fTX),func2str(c.intermediate.txlast))
		bRan	= false;
		
		%transform
			strStatus	= ['transforming data (' strTX ')'];
			status(strStatus,ns+1,'silent',c.silent);
			
			kStart	= num2cell(s(:,1));
			kEnd	= num2cell(s(:,2));
			
			d	= cellfunprogress(@(s,e) fTX(x(s:e),rate),kStart,kEnd,'label',strStatus,'UniformOutput',false,'silent',c.silent);
		%construct the vector matrix
			nD		= cellfun(@numel,d);
			nMin	= min(nD);
			d		= cellfun(@(x) reshape(x(1:nMin),1,nMin),d,'UniformOutput',false);
			d		= cat(1,d{:});
			
			c.intermediate.txlast	= fTX;
			c.intermediate.d		= d;
	else
		status('already transformed data',ns+1,'silent',c.silent);
		
		d	= c.intermediate.d;
	end
%cluster!
	strParam	= conditional(opt.cluster_cutoff>=2,'maxclust','cutoff');
	strDist		= conditional(ischar(opt.cluster_dist),opt.cluster_dist,'custom');
	
	status(['clustering (dist=' strDist ', link=' opt.cluster_linkage ', ' strParam '=' num2str(opt.cluster_cutoff) ')'],ns+1,'silent',c.silent);
	
	warning('off','stats:linkage:NotEuclideanMethod');
	
	c.result	= clusterdata(d,...
					strParam	, opt.cluster_cutoff	, ...
					'distance'	, opt.cluster_dist		, ...
					'linkage'	, opt.cluster_linkage	  ...
					);

%------------------------------------------------------------------------------%
function x = Data_NoTX(x,rate)
	
end
%------------------------------------------------------------------------------%
function d = Data_LCQFT(x,rate)
	%calculate the CQFCCs of the signal
		dur	= k2t(numel(x)+1,rate);
		
		[cq,t,D,f,sk]	= CQFCC(x,rate,...
							'win'	, dur				, ...
							'hop'	, dur				, ...
							'n'		, opt.cluster_nfft	, ...
							'sk'	, sk				  ...
							);
	%calculate the lcqft
		d	= lcqft(cq,D);
end
%------------------------------------------------------------------------------%
function d = Data_HCQFT(x,rate)
	%calculate the CQFCCs of the signal
		dur	= k2t(numel(x)+1,rate);
		
		[cq,t,D,f,sk]	= CQFCC(x,rate,...
							'win'	, dur				, ...
							'hop'	, dur				, ...
							'n'		, opt.cluster_nfft	, ...
							'sk'	, sk				  ...
							);
	%calculate the hcqft
		d	= hcqft(cq,D);
end
%------------------------------------------------------------------------------%

end
