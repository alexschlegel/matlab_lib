function GroupAssign(c,varargin)
% GroupAssign
% 
% Description:	randomly assign subjects to groups
% 
% Syntax:	GroupAssign(c,<options>)
% 
% In:
% 	c	- an array of unique subject identifiers
%	<options>:
%		group:		({'exp','con'}) a cell of groups to which to assign the
%					subjects
%		size:		([]) an array with up to (nGroup-1) elements specifying the
%					size of each group
%		match:		({}) an array the same size as c of trait values to match
%					between the two groups, or a cell of such arrays to match
%					each trait
%		trait:		(<auto>) the name of each trait being matched
%		attempts:	(1000) the number of randomized attempts to make to assign
%					groups with matching traits
% 
% Updated: 2015-04-08
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'group'		, {'exp','con'}	, ...
		'size'		, []			, ...
		'match'		, {}			, ...
		'trait'		, []			, ...
		'attempts'	, 1000			  ...
		);
opt.group	= reshape(opt.group,[],1);
opt.match	= ForceCell(opt.match);

nSubject	= numel(c);
nGroup		= numel(opt.group);

cTrait	= cellfun(@(x) reshape(x,[],1),opt.match,'UniformOutput',false);
nTrait	= numel(cTrait);

%get the number of subjects in each group
	nManual			= sum(opt.size);
	nAuto			= nSubject-nManual;
	nGroupManual	= numel(opt.size);
	nGroupAuto		= nGroup-nGroupManual;
	nPerAuto		= floor(nAuto/nGroupAuto);
	
	opt.size(nGroupManual+1:nGroup)	= nPerAuto;
	opt.size(end)					= opt.size(end)+nSubject-sum(opt.size);
%get subject identifiers as strings
	if ~iscell(c)
		c	= num2cell(c);
	end
	
	cSubject	= cellfun(@tostring,c,'UniformOutput',false);
%get trait names
	if isempty(opt.trait)
		opt.trait	= arrayfun(@num2str,(1:nTrait),'UniformOutput',false);
	end
%normalize the traits
	bTrait	= nTrait>0;
	
	if ~bTrait
		cTrait	= {ones(nSubject,1)};
	end
	
	nTrait	= numel(cTrait);
%assign to groups
	kGroup		= cell(opt.attempts,nGroup);
	pTraitDiff	= NaN(opt.attempts,nTrait);
	
	progress('action','init','total',opt.attempts,'label','Random Group Assignment');
	for kA=1:opt.attempts
		kSubject	= (1:nSubject)';
		kNumGroup	= NaN(nSubject,1);
		
		for kG=1:nGroup
			kGroup{kA,kG}	= sort(randFrom(kSubject,[opt.size(kG) 1]));
			kSubject		= setdiff(kSubject,kGroup{kA,kG});
			
			kNumGroup(kGroup{kA,kG})	= kG;
		end
		
		%evaluate the assignment
			pTraitDiff(kA,:)	= cellfun(@(x) anova1(x,kNumGroup,'off'),cTrait);
		
		progress;
	end
	
	%find the attempt with the largest minimum p-value
		pTraitDiffMin	= min(pTraitDiff,[],2);
		kAttemptMax		= find(pTraitDiffMin==max(pTraitDiffMin));
	%randomly choose from one of the matches
		kAttempt	= randFrom(kAttemptMax);
		kGroup		= kGroup(kAttempt,:)';
%display the results
	%groups
		sGroup		= cellfun(@numel,opt.group,'UniformOutput',false);
		cGroup		= cellfun(@(k) cSubject(k),kGroup,'UniformOutput',false);
		nGroupFill	= cellfun(@(g,s) max(g,max(cellfun(@numel,s))),sGroup,cGroup);
		
		nMax	= max(cellfun(@numel,cGroup));
		nFill	= numel(num2str(nMax));
		
		%header
			strHeader	= [repmat(' ',[1 nFill+2]) join(arrayfun(@(g) StringFill(opt.group{g},nGroupFill(g),' ','right'),(1:nGroup)','UniformOutput',false),' | ')];
			strSep		= repmat('-',[1 numel(strHeader)]);
		%items
			cLine	= cell(nMax,1);
			
			for kL=1:nMax
				cItem	= cell(nGroup,1);
				
				for kG=1:nGroup
					if opt.size(kG)>=kL
						cItem{kG}	= StringFill(cGroup{kG}{kL},nGroupFill(kG),' ','right');
					else
						cItem{kG}	= repmat(' ',[1 nGroupFill(kG)]);
					end
				end
				
				cLine{kL}	= [StringFill(kL,nFill,' ') ') ' join(cItem,' | ')];
			end
		
		strGroup	= join([strHeader; strSep; cLine],10);
	%traits
		if bTrait
			kNumGroup	= NaN(nSubject,1);
			
			for kG=1:nGroup
				kNumGroup(kGroup{kG})	= kG;
			end
			
			cDispTrait	= {};
			for kT=1:nTrait
				cDispTrait	= [cDispTrait; 'Trait "' opt.trait{kT} '":'];
				
				for kG=1:nGroup
					t	= mean(opt.match{kT}(kGroup{kG}));
					
					cDispTrait	= [cDispTrait; ' ' opt.group{kG} ' - ' num2str(sigfig(t,3))];
				end
				
				[p,tab,stats] = anova1(opt.match{kT},kNumGroup,'off');
				
				dfN	= tab{2,3};
				dfD	= tab{3,3};
				F	= tab{2,5};
				
				cDispTrait	= [cDispTrait; ' F(' num2str(dfN) ',' num2str(dfD) ')=' num2str(sigfig(F,3)) ', p=' num2str(sigfig(p,3))];
			end
			
			strTrait	= join(cDispTrait,10);
		end

	disp(strGroup);
	
	if bTrait
		disp('   ');
		disp(strTrait);
	end
