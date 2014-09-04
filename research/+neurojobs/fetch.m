function s = fetch(varargin)
% neurojobs.fetch
% 
% Description:	get some jerbs!
% 
% Syntax:	s = neurojobs.fetch(<options>)
%
% In:
%	<options>:
%		date_start:	(0) the starting date
% 
% Updated: 2014-08-02
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'urls'			, false	, ...
		'date_start'	, 0		  ...
		);

cSite	=	{
				'chroniclevitae'	'neuroscience'
				'chroniclevitae'	'psychology'
				'chroniclevitae'	'cognitive'
				'aps'				'Cognitive'
				'aps'				'Neuroscience'
				'aps'				'Cognitive+Neuroscience'
				'hercjobs'			'neuroscience'
				'hercjobs'			'psychology'
				'hercjobs'			'cognitive'
				'naturejobs'		'neuroscience'
				'naturejobs'		'psychology'
				'naturejobs'		'cognitive'
				'apa'				'neuroscience'
				'apa'				'psychology'
				'apa'				'cognitive'
				'higheredjobs'		'neuroscience'
				'higheredjobs'		'psychology'
				'higheredjobs'		'cognitive'
				'academicjobs'		'neuroscience'
				'academicjobs'		'psychology'
				'academicjobs'		'cognitive'
				'academickeys'		'neuroscience'
				'academickeys'		'psychology'
				'academickeys'		'cognitive'
				'sfn'				''
				'sciencecareers'	''
			};

nSite	= size(cSite,1);

%get the jobs
	s	= cell(nSite,1);
	for kS=1:nSite
		status(sprintf('(%02d/%02d) %s (%s)',kS,nSite,cSite{kS,1},cSite{kS,2}));
		
		try
			strCall			= sprintf('neurojobs.site.%s(''%s'')',cSite{kS,1},cSite{kS,2});
			[s{kS},extra]	= eval(strCall);
			
			if opt.urls
				s{kS}	= {extra.url};
			end
		catch me
			status(sprintf('%s(%s) failed!',cSite{kS,1},cSite{kS,2}),'warning',true);
		end
	end
	
	s	= cat(1,s{:});

if ~opt.urls
	%get rid of duplicates
		cHash				= cellfun(@(p,l) [p ' | ' l],{s.title}',{s.location}','uni',false);
		[cHashU,kUnique]	= unique(cHash);
		
		s	= s(kUnique);
	
	%sort by date
		t			= [s.date];
		[tS,kSort]	= sort(t,'descend');
		
		s	= s(kSort);
	
	%keep only the selected dates
		kLast	= find([s.date]>=opt.date_start,1,'last');
		s		= s(1:kLast);
end
