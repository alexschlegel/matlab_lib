function [strPathBatch,cPathJob,kJobBlock] = MakeQSUBScript(strPathTemplate,s,varargin)
% MakeQSUBScript
% 
% Description:	make a set of qsub scripts from a template
% 
% Syntax:	[strPathBatch,cPathJob,kJobBlock] = MakeQSUBScript(strPathTemplate,s,<options>)
% 
% In:
% 	strPathTemplate	- path to the template file.  sections to replace are
%					  denoted in the template with brackets (e.g. <session>).
%					  The template should have at least the following lines:
%						#PBS -N <script_name>
%						#PBS -l walltime=<walltime>
%					  <script_name> and <walltime> substitutions are made
%					  automatically.
%	s				- a struct whose elements are cell arrays the same size
%					  denoting substitutions to make for each script file.  the
%					  field names signify the bracketed string to search for in
%					  the template.  e.g. if s.session{7} is the string
%					  '11oct81as', then all instances of <session> in the
%					  template file will be replaced by '11oct81as' in the 7th
%					  script file.
%	<options>:
%		outdir:			(<dir_template>/<template_file_pre>/) the output
%						directory
%		walltime:		(24) walltime, in hours.  can be an array of wall times
%		block_field:	(<none>) specify the name of a field to create batch
%						submission scripts by grouping by values of this field
%		block:			(1) create <block> batch submission scripts with jobs
%						distributed between them.  overrides block_field.
% 
% Out:
%	strPathBatch	- path to a shell script that will add all of the generated
%					  scripts as jobs using qsub.  a cell of paths will be
%					  returned if <block>~=1.
%	cPathJob		- the path to each script file
%	kJobBlock		- a cell of array of job indices included in each block
% 
% Updated: 2015-04-08
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
cSub	= fieldnames(s);
sScript	= size(s.(cSub{1}));
nScript	= prod(sScript);

opt	= ParseArgs(varargin,...
		'outdir'		, []		, ...
		'walltime'		, 24		, ...
		'block_field'	, []		, ...
		'block'			, []		  ...
		);

strDirOut	= unless(opt.outdir,DirAppend(PathGetDir(strPathTemplate),PathGetFilePre(strPathTemplate)));
CreateDirPath(strDirOut,'error',true);

%add substitutions
	%script name
		strScriptPrefix	= PathGetFilePre(strPathTemplate);
		if ~isfield(s,'script_name')
			cKJob	= StringFill(num2cell(1:nScript));
			cKJob	= mat2cell(cKJob,ones(nScript,1),size(cKJob,2));
			
			s.script_name	= cellfun(@(k) [strScriptPrefix '-' k],cKJob,'UniformOutput',false);
		end
	%wall time
		if ~isfield(s,'walltime')
			s.walltime	= repmat({FormatTime(ConvertUnit(opt.walltime,'hour','ms'),'H:MM:SS')},sScript);
		end

%read the template file
	strTemplate	= fget(strPathTemplate);
%output paths
	cPathJob	= cellfun(@(x) PathUnsplit(strDirOut,x,'job'),s.script_name,'UniformOutput',false);
	cFileJob	= cellfun(@PathGetFileName,cPathJob,'UniformOutput',false);
%construct the scripts
	cSub	= fieldnames(s);
	nSub	= numel(cSub);

	progress('action','init','total',nScript,'label','Making qsub scripts');
	for kS=1:nScript
		strScript	= strTemplate;
		
		for kU=1:nSub
			strScript	= strrep(strScript,['<' cSub{kU} '>'],s.(cSub{kU}){kS});
		end
		
		fput(strScript,cPathJob{kS});
		
		progress;
	end

%make the job submitter scripts
	%get the block intervals and submission script names
		bOneBlock		= false;
		strPathBatch	= PathUnsplit(strDirOut,['submit_' strScriptPrefix],'sh');
		
		if ~isempty(opt.block)
			nJobPer	= ceil(nScript/opt.block);
			
			kBlockStart	= 1:nJobPer:nScript;
			
			cBlock	= StringFill(num2cell(1:opt.block));
			cBlock	= mat2cell(cBlock,ones(opt.block,1),size(cBlock,2));
			
			strPathBatch	= cellfun(@(n) PathAddSuffix(strPathBatch,['_' n]),cBlock,'UniformOutput',false);
		elseif ~isempty(opt.block_field)
			[u,ku]				= unique(s.(opt.block_field),'first');
			[kBlockStart,ks]	= sort(ku);
			u					= u(ks);
			
			if ~iscell(u)
				u	= num2cell(u);
			end
			
			strPathBatch	= cellfun(@(f) PathAddSuffix(strPathBatch,['_' tostring(f)]),u,'UniformOutput',false);
		else
			bOneBlock	= true;
			
			kBlockStart		= 1;
			strPathBatch	= {strPathBatch};
		end
		
		nBlock		= numel(kBlockStart);
		kBlockStart	= [reshape(kBlockStart,[],1); nScript+1];
	%construct the scripts
		cJob		= cellfun(@(x) ['qsub ./' x],cFileJob,'UniformOutput',false);
		kJobBlock	= cell(nBlock,1);
		
		for kB=1:nBlock
			kBStart			= kBlockStart(kB);
			kBEnd			= kBlockStart(kB+1)-1;
			kJobBlock{kB}	= kBStart:kBEnd;
			
			strBatch	= join(cJob(kJobBlock{kB}),10);
			
			fput(strBatch,strPathBatch{kB});
		end
	%convert to char
		if bOneBlock
			strPathBatch	= strPathBatch{1};
		end
