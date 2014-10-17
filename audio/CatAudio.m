function bSuccess = CatAudio(cPathIn,strPathOut,varargin)
% CatAudio
% 
% Description:	concatenate audio files (requires sox)
% 
% Syntax:	bSuccess = CatAudio(cPathIn,strPathOut,<options>)
% 
% In:
% 	cPathIn		- a cell of input files
%	strPathOut	- the output file
%	<options>:
%		lamemp3:	(true) true to use lame for mp3 output
%		silent:		(false) true to suppress output messages
% 
% Out:
% 	bSuccess	- true if the sox script ran successfully
% 
% Updated: 2011-11-12
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgs(varargin,...
		'lamemp3'	, true	, ...
		'silent'	, false	  ...
		);
		
strExt			= lower(PathGetExt(strPathOut));
bMP3			= isequal(strExt,'mp3');
bIntermediate	= bMP3 && opt.lamemp3;

if bIntermediate
	strDirTemp		= GetTempDir;
	strPathOutFinal	= strPathOut;
	strPathOut		= PathUnsplit(strDirTemp,'temp','wav');
end

[ec,strOutput]	= RunBashScript(['sox "' join(cPathIn,'" "') '" "' strPathOut '"'],'silent',opt.silent);
bSuccess		= ec==0;

if bIntermediate
	if bSuccess && bMP3
		[ec,strOutput]	= RunBashScript(['lame "' strPathOut '" "' strPathOutFinal '"'],'silent',opt.silent);
		bSuccess		= ec==0;
	end
	
	RunBashScript(['rm -r "' strDirTemp '"'],'silent',opt.silent);
end
