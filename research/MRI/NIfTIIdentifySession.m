function strSession = NIfTIIdentifySession(strPathData,varargin)
% NIfTIIdentifySession
% 
% Description:	attempt to identify the session code of a NIfTI (Analyze)
%				formatted data file
% 
% Syntax:	strSession = NIfTIIdentifySession(strPathData,[bConsiderDir]=true,[bConsiderFileName]=true,[bConsiderDesc]=true)
% 
% In:
% 	strPathData			- path to the data file to identify
%	[bConsiderDir]		- true to consider the directory structure
%	[bConsiderFileName]	- true to consider the file name
%	[bConsiderDesc]		- true to consider the NIfTI description field
% Out:
% 	strSession	- the session code, or '' if none was identified
% 
% Notes:	Requires SPM8 to be in the MATLAB path.
%
%			looks for identifying information in the .descrip element of the
%			file's nifti object, in directory names, and in the file name.
%			Strings that match between these three are identified as possible
%			session name matches, and matches that occur farther down the
%			directory chain or closer to the beginning of the file name
%			and description strings are given precedence.
% 
% Updated:	2010-02-25
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
[bConsiderDir,bConsiderFileName,bConsiderDesc]	= ParseArgs(varargin,true,true,true);

%parameters
	nDirConsider	= 4;	%# of directories to consider
	nLengthMin		= 3;	%minimum session name length


%get directory search strings
	if bConsiderDir
		%get the directory names to consider
			cDirFull	= DirSplit(strPathData);
			if numel(cDirFull)>nDirConsider
				cDirFull	= cDirFull(end-nDirConsider+1:end);
			end
		%get the directory substrings
			[cDirSub,kDirPart]	= GetAllSubstrings(cDirFull,nLengthMin);
			nDir				= numel(cDirSub);
	end
%get file name search strings
	if bConsiderFileName
		%pre-extension file name
			[dummy,strFilePre,dummy]	= PathSplit(strPathData);
		%file substrings
			[cFileSub,kFilePart]	= GetAllSubstrings(strFilePre,nLengthMin);
			nFile					= numel(cFileSub);
	end
%get description search strings
	if bConsiderDesc
		%get the description
			nii		= nifti(strPathData);
			strDesc	= nii.descrip;
			clear nii;
		%description substrings
			[cDescSub,kDescPart]	= GetAllSubstrings(strDesc,nLengthMin);
			nDesc					= numel(cDescSub);
	end

%search for matches
	cMatch		= {};
	kMatchPart	= [];
	
	%file and dir
		if bConsiderFileName && bConsiderDir
			for kFile=1:nFile
				[bMatch,kDir]	= ismember(cFileSub{kFile},cDirSub);
				if bMatch
					cMatch		= [cMatch; cFileSub{kFile}];
					kMatchPart	= [kMatchPart; min(kFilePart(kFile),kDirPart(kDir))];
				end
			end
		end
	%file and description
		if bConsiderFileName && bConsiderDesc
			for kFile=1:nFile
				[bMatch,kDesc]	= ismember(cFileSub{kFile},cDescSub);
				if bMatch
					cMatch		= [cMatch; cFileSub{kFile}];
					kMatchPart	= [kMatchPart; min(kFilePart(kFile),kDescPart(kDesc))];
				end
			end
		end
	%dir and description
		if bConsiderDir && bConsiderDesc
			for kDir=1:nDir
				[bMatch,kDesc]	= ismember(cDirSub{kDir},cDescSub);
				if bMatch
					cMatch		= [cMatch; cDirSub{kDir}];
					kMatchPart	= [kMatchPart; min(kDirPart(kDir),kDescPart(kDesc))];
				end
			end
		end
		
	nMatch	= numel(cMatch);

%consolidate multiple matches
	%get unique matches
		[cMatch,kTo,kFrom]	= unique(cMatch);
		nMatch				= numel(cMatch);
	
	%get the number of matches and minimum part index of each match
		kMatchPartAll			= kMatchPart;
		[nMatchPer,kMatchPart]	= deal(zeros(nMatch,1));
		for k=1:nMatch
			kMatch	= find(kFrom==k);
			
			nMatchPer(k)	= numel(kMatch);
			kMatchPart(k)	= min(kMatchPartAll(kMatch));
		end
		
	%reorder (unique sorts everything)
		[kTo,kSort]	= sort(kTo);
		cMatch		= cMatch(kSort);
		nMatchPer	= nMatchPer(kSort);
		kMatchPart	= kMatchPart(kSort);

%numerical matches have to occur in the first part of a group
	bKeep	= true(nMatch,1);
	for k=1:nMatch
		if isnumstr(cMatch{k})
			bKeep(k)	= kMatchPart(k)==1;
		end
	end
	cMatch		= cMatch(bKeep);
	nMatchPer	= nMatchPer(bKeep);
	kMatchPart	= kMatchPart(bKeep);
	
	nMatch	= numel(cMatch);

%if there are no matches, take the first part of the file name that isn't a year
	if nMatch==0
		if bConsiderFileName
			k=1;
			while isnumstr(cFileSub{1}) && ~isYear(cFileSub{1})
				k	= k+1;
			end
			strSession	= cFileSub{1};
		else
			strSession	= '';
		end
		
		return;
	end
	
%calculate a score for the remaining matches
%	1 point per character * # of matches
	nLen	= zeros(nMatch,1);
	for k=1:nMatch
		nLen(k)	= numel(cMatch{k});
	end
	
	score			= nLen .* nMatchPer;
	[score,kMax]	= max(score);
	
	strSession	= cMatch{kMax};
	
	%cMatch
	%score
	
%if the session name is in the first part of the file name, take the trailing
%part of the first part of the file name instead
	if bConsiderFileName && nFile>=1
		reSession	= StringForRegExp(strSession);
		k			= regexpi(cFileSub{1},reSession);
		if ~isempty(k)
			strSession	= cFileSub{1}(k:end);
		end
	end
	
	
%------------------------------------------------------------------------------%
function b = IsYear(str)
	b	= isnumstr(str) && IsBetween(str2num(str),1990,2381);
%------------------------------------------------------------------------------%
function [cSub,kPart] = GetAllSubstrings(cStr,nLengthMin)
	if ~iscell(cStr)
		cStr	= {cStr};
	end
	nStr	= numel(cStr);
	
	%divide into string parts
		cPart	= {};
		kPart	= [];
		for k=nStr:-1:1
			[cPartCur,kPartCur]	= GetStringParts(cStr{k},nLengthMin);
			
			cPart	= [cPart;cPartCur];
			kPart	= [kPart;kPartCur];
		end
		nPart	= numel(cPart);
	%get the substrings from each part
		cSub		= {};
		nLen		= [];
		kPartSub	= [];
		for k=1:nPart
			%make sure it's not a year
				if IsYear(cPart{k})
					continue;
				end
				
			[cSubCur,nLenCur] = GetSubstrings(cPart{k},nLengthMin);
			
			cSub		= [cSub;cSubCur];
			nLen		= [nLen;nLenCur];
			
			nSub		= numel(cSubCur);
			kPartSub	= [kPartSub;repmat(kPart(k),[nSub 1])];
		end
	%order by decreasing cell position, increasing string position, and
	%decreasing string length
		[nLen,kSort]	= sort(nLen,1,'descend');
		cSub			= cSub(kSort);
		kPart			= kPartSub(kSort);
%------------------------------------------------------------------------------%
function [cSub,nLen] = GetSubstrings(str,nLengthMin)
	%calculate number of substrings
		nStr	= numel(str);
		nSub	= sum( nStr-(nLengthMin:nStr) + 1);
	%initialize the output
		cSub	= cell(nSub,1);
		nLen	= zeros(nSub,1);
		
	%add each substring
		kSub	= 0;
		for kLength=nStr:-1:nLengthMin
			for kStart=1:nStr-kLength+1
				kSub		= kSub + 1;
				cSub{kSub}	= str(kStart + (0:kLength-1));
				nLen(kSub)	= kLength;
			end
		end
%------------------------------------------------------------------------------%
function [cPart,kPart] = GetStringParts(strFull,nMin)
%breakup a string that is divided by [\W_] characters
	%cPart	= split(strFull,'[/,._-\s]');
	cPart	= split(strFull,'[\W_]');
	nPart	= numel(cPart);
	kPart	= reshape(1:nPart,[],1);
	
	bKeep	= false(nPart,1);
	for k=1:numel(cPart)
		bKeep(k)	= numel(cPart{k})>=nMin;
	end
	cPart	= cPart(bKeep);
	kPart	= kPart(bKeep);
%------------------------------------------------------------------------------%
