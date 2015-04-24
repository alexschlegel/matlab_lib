function ifo = PARRECParseRaw(cDirRaw,varargin)
% PARRECParseRaw
% 
% Description:	extract info from a directory or set of directories of raw
%				PAR/REC data
% 
% Syntax:	ifo = PARRECParseRaw(cDirRaw)
% 
% In:
% 	cDirRaw	- a raw data directory path, cell of paths, or the path to a
%			  directory that contains raw data directories
%	<options>:
%		silent:	(false) true to suppress status messages
% 
% Out:
% 	ifo	- a Nx1 struct array with info about each raw data set
% 
% Notes:	a file name parse.cfg can be placed in directory paths to override
%			automatically extracted info.  this plain text file contains a set
%			of directives, one per line, as follows:
%				ignore
%				id:<other> --> the output subject initials should be <other>
%				run:<k> --> map the functional runs in <k> to 1:Nk and ignore
%					the rest (<k> is of the form "<k1> <k2> ... <kN>"). for
%					example, if the directory has 6 functional runs and
%					"run:5 4 3" is specified, runs 1, 2, and 6 are ignored,
%					run 5 is treated as run 1, 4 as 2, and 3 is kept as 3.
%				date:<ddmmmyy> --> specify an alternate date
%				file_ignore:<f1> <f2> ... <fN> --> ignore the specified
%					files (e.g. '29mar15jp_04_1-DwiSE').  NOTE: don't use this
%					for functional scans.  use 'run'.
% 
% Updated: 2015-04-24
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'silent'	, false	  ...
		);

%get a cell of directories to parse
	if ~iscell(cDirRaw)
		cDirSub	= FindDirectories(cDirRaw);
		bRaw	= cellfun(@(d) ~isnan(ParseSessionCode(RemoveSlash(DirSub(d,0,0)))),cDirSub);
		if ~isempty(cDirSub) || any(bRaw)
		%directory of raw directories
			cDirRaw	= cDirSub(bRaw);
		else
		%single directory
			cDirRaw	= {cDirRaw};
		end
	else
		cDirRaw	= reshape(cDirRaw,[],1);
	end
	
	nRaw	= numel(cDirRaw);
%parse each
	ifo	= cellfun(@ReadConfig,cDirRaw);
	
	ifo([ifo.ignore])	= [];

%------------------------------------------------------------------------------%
function ifo = ReadConfig(strDir)
	%default info
		ifo	= struct(...
				'code'			, ''	, ...
				't'				, NaN	, ...
				'id'			, ''	, ...
				'files'			, {{}}	, ...
				'scantype'		, {{}}	, ...
				'ignore'		, false	, ...
				'runmap'		, []	, ...
				'structural'	, {{}}	, ...
				'functional'	, {{}}	, ...
				'diffusion'		, {{}}	  ...
				);
		
		ifo.code		= RemoveSlash(DirSub(strDir,0,0));
		[ifo.t,ifo.id]	= ParseSessionCode(ifo.code);
		
		ifo.files		= FindFilesByExtension(strDir,'PAR');
		ifo.scantype	= cellfun(@PARRECScanType,ifo.files,'UniformOutput',false);
		kEPI			= FindCell(ifo.scantype,'functional');
		nEPI			= numel(kEPI);
	
		ifo.runmap	= (1:nEPI)';
	
	%parse the config info
		strPathCfg	= PathUnsplit(strDir,'parse','cfg');
		
		if FileExists(strPathCfg)
			%read the file and break into lines
				cLine	= cellfun(@StringTrim,split(fget(strPathCfg),'[\r\n]+'),'UniformOutput',false);
				nLine	= numel(cLine);
			%parse each line
				re	= '^(?<var>[^:]+):?(?<val>.*)$';
				
				for kL=1:nLine
					s	= regexp(cLine{kL},re,'names');
					
					if ~isempty(s)
						switch lower(s.var)
							case 'ignore'
								ifo.ignore	= true;
								
								status(['ignoring ' ifo.code],'silent',opt.silent);
							case 'run'
								ifo.runmap	= reshape(str2num(s.val),[],1);
								
								status(['remapping runs for ' ifo.code ': ' join(ifo.runmap,',')],'silent',opt.silent);
							case 'id'
								ifo.id	= s.val;
								
								status(['remapping subject initials for ' ifo.code ' to ' ifo.id],'silent',opt.silent);
							case 'date'
								ifo.t	= FormatTime(s.val);
								
								status(['reassigning date for ' ifo.code ' to ' FormatTime(ifo.t)],'silent',opt.silent);
							case 'file_ignore'
								cFileIgnore			= cellfun(@PathGetFilePre,split(s.val,'\s+'),'uni',false);
								cFile				= cellfun(@PathGetFilePre,ifo.files,'uni',false);
								[bIgnore,kIgnore]	= ismember(cFileIgnore,cFile);
								
								ifo.files(kIgnore)		= [];
								ifo.scantype(kIgnore)	= [];
								
								status(['ignoring files: ' join(cFileIgnore,', ')],'silent',opt.silent);
							otherwise
								status(['unrecognized instruction "' s.var '" found in ' strPathCfg],'warning',true,'silent',opt.silent);
						end
					end
				end
		end
		
		ifo.code	= sessioncode(ifo.id,ifo.t);
	%parse the files
		kS	= find(ismember(ifo.scantype,'structural'));
		if ~isempty(kS)
			ifo.structural	= ifo.files(kS);
		end
		
		kF	= find(ismember(ifo.scantype,'functional'));
		if ~isempty(kF)
			ifo.functional	= ifo.files(kF);
			ifo.functional	= ifo.functional(ifo.runmap);
		end
		
		kD	= find(ismember(ifo.scantype,'diffusion'));
		if ~isempty(kD)
			ifo.diffusion	= ifo.files(kD);
		end
end
%------------------------------------------------------------------------------%

end
