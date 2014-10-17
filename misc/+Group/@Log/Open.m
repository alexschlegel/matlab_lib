function Open(lg,varargin)
% Group.Log.Open
% 
% Description:	start the log file
% 
% Syntax:	lg.Open([strPathLog]=<auto>,<options>)
% 
% In:
% 	[strPathLog]	- the path to the log file
%	<options>:
%		append:	(true) true to append, false to overwrite existing log files
% 
% Updated: 2011-12-27
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
[strPathLog,opt]	= ParseArgs(varargin,[],...
						'append'	, true	  ...
						);

%get the log file path
	if isempty(strPathLog)
		strDir	= 'data';
		strName	= [lg.root.type '.log'];
	else
		strDir	= PathGetDirectory(strPathLog);
		strName	= PathGetFileName(strPathLog);
	end
	
	lg.root.File.SetDirectory(lg.type,strDir,false);
	lg.root.File.Set(lg.type,lg.type,strName,false);
	
	strPathLog	= lg.root.File.Get(lg.type);
	bExists		= FileExists(strPathLog);

%delete the log if we're overwriting
	if lg.Info.Get('save') && ~opt.append && bExists
		delete(strPathLog);
	end
%load the existing log or create a new one
	cFieldGood	= {'time','type','info'};
	
	bBlank	= false;
	if bExists
		try
			evt			= table2struct(lg.root.File.Read(lg.type));
		catch me
		%hmm
			evt	= [];
		end
		
		if isempty(evt)
		%nothing
			bBlank	= true;
		else
			if ~all(isfield(evt,cFieldGood))
			%we don't have all the needed fields
				bBlank	= true;
			else
			%we got something
				cField	= fieldnames(evt);
				bRemove	= ~ismember(cField,cFieldGood);
				
				if any(bRemove)
				%we got some extra fields
					evt	= rmfield(evt,cField(bRemove));
				end
				
				evt	= orderfields(evt,cFieldGood);
			end
		end
	else
	%the log doesn't exist
		bBlank	= true;
	end
	
	if bBlank
		evt	= struct('time',[],'type',{{}},'info',{{}});
		
		if lg.Info.Get('save')
			if bExists
				delete(strPathLog);
			end
			
			lg.root.File.Write(join(cFieldGood,9),lg.type);
		end
	end
	
	lg.Info.Set('event',evt);

%get the diary path
	strNameDiary	= PathAddSuffix(strName,'','diary');
	lg.root.File.Set([lg.type '_diary'],lg.type,strNameDiary,false);
	
	strPathDiary	= lg.root.File.Get([lg.type '_diary']);

if lg.Info.Get('save')
%open the log for fast writing
	b	= lg.root.File.Open(lg.type);
	if ~b
		error(['Could not open log: "' strPathLog '"']);
	end
%start the diary
	if ~opt.append && FileExists(strPathDiary)
		delete(strPathDiary);
	end
	
	diary(strPathDiary);
%show some info
	strStatusLog	= ['log saving to: "' strPathLog '"'];
	lg.root.Status.Show(strStatusLog,'time',false);
	
	strStatusDiary	= ['diary saving to: "' strPathDiary '"'];
	lg.root.Status.Show(strStatusDiary,'time',false);
end
