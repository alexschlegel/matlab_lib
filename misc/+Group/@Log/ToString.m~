function [strStatus,strFile] = ToString(lg,kLog)
% PTB.Log.ToString
% 
% Description:	convert a set of log entries to a string
% 
% Syntax:	[strStatus,strFile] = lg.ToString(kLog)
% 
% In:
% 	kLog	- the log entry indices to convert
% 
% Out:
%	strStatus	- the log entries as a string for status output
%	strFile		- the log entries as a string for file output
% 
% Updated: 2011-12-17
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global PTBIFO;

nFillType	= PTBIFO.log.fill_type;
nInfoCutoff	= PTBIFO.log.info_cutoff;

nLog	= numel(kLog);

if nLog==1
%just one
	t		= PTBIFO.log.event.time(kLog);
	strType	= PTBIFO.log.event.type{kLog};
	ifo		= PTBIFO.log.event.info{kLog};

	strTimeN		= Time2N(t);
	strTimeStr		= Time2Str(t);
	strTypeFill		= Type2Fill(strType);
	strInfoFile		= Info2File(ifo);
	strInfoStatus	= Info2Status(strInfoFile);
	
	strStatus	= CatStatus(strTimeN,strTimeStr,strTypeFill,strInfoStatus);
	strFile		= CatFile(strTimeN,strType,strInfoFile);
else
%multiple
	t		= PTBIFO.log.event.time(kLog);
	cType	= PTBIFO.log.event.type(kLog);
	ifo		= PTBIFO.log.event.info(kLog);
	
	cTimeN		= arrayfun(@Time2N,t,'UniformOutput',false);
	cTimeStr	= arrayfun(@Time2Str,t,'UniformOutput',false);
	cTypeFill	= cellfun(@Type2Fill,cType,'UniformOutput',false);
	cInfoFile	= cellfun(@Info2File,ifo,'UniformOutput',false);
	cInfoStatus	= cellfun(@Info2Status,cInfoFile,'UniformOutput',false);
	
	cStatus		= cellfun(@CatStatus,cTimeN,cTimeStr,cTypeFill,cInfoStatus,'UniformOutput',false);
	strStatus	= join(cStatus,10);
	
	cFile	= cellfun(@CatFile,cTimeN,cType,cInfoFile,'UniformOutput',false);
	strFile	= join(cFile,10);
end

%------------------------------------------------------------------------------%
function str = CatStatus(strTimeN,strTimeStr,strTypeFill,strInfoStatus)
	str	= join({[strTimeStr '/' strTimeN],['event: ' strTypeFill],['info: ' strInfoStatus]},' | ');
end
%------------------------------------------------------------------------------%
function str = CatFile(strTimeN,strType,strInfoFile)
	str	= [strTimeN 9 strType 9 strInfoFile];
end
%------------------------------------------------------------------------------%
function str = Time2N(t)
	str	= num2str(t,'%0.3f');
end
%------------------------------------------------------------------------------%
function str = Time2Str(t)
	str	= FormatTime(t);
end
%------------------------------------------------------------------------------%
function str = Type2Fill(strType)
	str	= StringFill(strType,nFillType,' ','right');
end
%------------------------------------------------------------------------------%
function str = Info2File(ifo)
	str	= regexprep(tostring(ifo),'[\r\n\t]+',' ');
end
%------------------------------------------------------------------------------%
function str= Info2Status(strInfo)
	str	= strInfo(1:min(end,nInfoCutoff));
end
%------------------------------------------------------------------------------%

end
