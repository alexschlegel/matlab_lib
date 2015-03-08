function Parse(ds)
% Data.DataSet.USState.Parse
% 
% Description:	parse us state data
% 
% Syntax:	ds.Parse
% 
% Updated: 2015-03-06
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
Parse@Data.DataSet(ds);

dsState	= Data.DataSet.USState;
dState	= dsState.Load;
nState	= numel(dState.abbr);


d			= struct(...
				'name'	, {}	, ...
				'fips'	, {}	, ...
				'state'	, {}	  ...
				);

for kS=1:nState
	kCounty		= 1;
	kCountyCol	= [];
	
	dCur	= struct(...
				'name'	, {}	, ...
				'fips'	, {}	, ...
				'state'	, {}	  ...
				);
	
	kCountyStart	= kCounty;
	strFIPSState	= num2str(dState.fips(kS));
	
	strPathRaw	= PathUnsplit(ds.data_dir,lower(dState.abbr{kS}),'txt');
	strRaw		= fget(strPathRaw);
	
	%split into lines
		cLine	= split(strRaw,'[\n\r]+');
	%remove blank lines
		bKeep	= cellfun(@(s) ~isempty(StringTrim(s)),cLine);
		cLine	= cLine(bKeep);
	%remove everything after the '~~~~' line
		kEnd	= unless(find(cellfun(@(s) ~isempty(regexp(s,'\s*[~]+\s*')),cLine),1),numel(cLine)+1);
		cLine	= cLine(1:kEnd-1);
	%keep the lines with data
		bData	= cellfun(@(s) ~isempty(regexp(s,'^\s*\d+')),cLine);
		cLine	= cellfun(@StringTrim,cLine(bData),'UniformOutput',false);
		nLine	= numel(cLine);
	%parse each line
		for kL=1:nLine
			cData	= split(cLine{kL},'(\s*\d\d\d\s+)|\s+\s+','withdelim',true,'delimpost',true);
			nData	= numel(cData);
			
			for kD=1:nData
				cData{kD}	= StringTrim(cData{kD});
				
				if isempty(regexp(cData{kD},'^\d+'))
				%continuation of previous line?
					sData	= regexp(cData{kD},'^(?<name>[^\(]+)','names');
					
					dCur(kCountyCol(kD)).name	= [dCur(kCountyCol(kD)).name ' ' StringTrim(sData.name)];
				else
					sData	= regexp(cData{kD},'^(?<fips>\d+)[\s\*]+(?<name>[^\(]+)','names');
					
					if ~isempty(sData)
						dCur(end+1).name	= StringTrim(sData.name);
						dCur(end).fips		= str2num([strFIPSState sData.fips]);
						dCur(end).state		= dState.abbr{kS};
						
						kCountyCol(kD)	= kCounty;
						kCounty			= kCounty+1;
					end
				end
			end
		end
	
	%there are some duplicates
	[fipsU,kKeep]	= unique([dCur.fips]);
	dCur			= dCur(kKeep);
	
	[x,kSort]	= sort([dCur.fips]);
	dCur		= dCur(kSort);
	
	d	= [d; dCur'];
end

d	= restruct(d);

ds.Save(d);
