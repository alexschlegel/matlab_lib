function sScore = TTCTScorer(cDirTTCT,strDirOut)
% TTCTScorer
% 
% Description:	use to score a set of TTCTs
% 
% Syntax:	TTCTScorer(cDirTTCT,strDirOut)
% 
% In:
% 	cDirTTCT	- a cell of paths to directories containing TTCT data.  data
%				  should be six .png files of the six pages of the completed
%				  TTCT, in order
%	strDirOut	- the directory to save results
% 
% Updated: 2012-07-09
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
cDirTTCT	= reshape(ForceCell(cDirTTCT),[],1);
nDir		= numel(cDirTTCT);

wDataEntry	= 300;

%get the scorer initials and existing data
	bGood	= false;
	
	while ~bGood
		strInit			= lower(ask('Initials','dialog',false));
		strPathResult	= PathUnsplit(strDirOut,['ttctscorer_' strInit],'mat');

		%check for existing scores
			if FileExists(strPathResult)
				bGood	= isequal(ask(['Scores found for ' strInit '.  Load?'],'dialog',false,'choice',{'yes','no'}),'yes');
				sScore	= load(strPathResult);
			else
				bGood	= true;
				sScore	= struct;
			end
	end
%initialize the struct
	if ~isfield(sScore,'id')
		sScore.id		= strInit;
		sScore.dir		= cDirTTCT;
		sScore.basedir	= PathGetBase(sScore.dir);
		sScore.path		= cell(nDir,1);
		sScore.result	= struct;
		sScore.score	= struct;
		
		sScore.finished	= dealstruct('s1','s2','s3',false(nDir,1));
	end
%get the union of the existing and new directories
	%make sure we're not just on another machine
		cDirOldRel	= cellfun(@(d) PathAbs2Rel(d,sScore.basedir),sScore.dir,'UniformOutput',false);
		
		strDirBaseNew	= PathGetBase(cDirTTCT);
		cDirNewRel		= cellfun(@(d) PathAbs2Rel(d,strDirBaseNew),cDirTTCT,'UniformOutput',false);
		bNew			= ~ismember(cDirNewRel,cDirOldRel);

	cDirAdd	= cDirTTCT(bNew);
	nDirAdd	= numel(cDirAdd);
	
	sScore.dir	= [sScore.dir; cDirAdd];
	nDir		= numel(sScore.dir);
	sScore.path	= [sScore.path; cell(nDirAdd,1)];
	
	sScore.finished	= structfun2(@(s) [s; false(nDirAdd,1)],sScore.finished);
	
	if numel(sScore.result)<nDir
		cField	= fieldnames(sScore.result);
		nField	= numel(cField);
		
		if nField==0
			sScore.result(nDir)				= struct;
		else
			sScore.result(nDir).(cField{1})	= [];
		end
	end
%get the scoring order
	sScore.kOrder	= randomize((1:nDir)');
%score the first section
	nFinished	= sum(sScore.finished.s1);
	for kD=1:nDir
		kScore	= sScore.kOrder(kD);
		
		if isempty(sScore.path{kScore})
			sScore.path{kScore}	= FindFilesByExtension(sScore.dir{kScore},'png');
			nData		= numel(sScore.path{kScore});
		
			if nData<6
				error(['Invalid TTCT directory: ' sScore.dir{kScore} '.']);
			end
		end
		
		if ~sScore.finished.s1(kScore)
			status(['scoring activity 1 ' num2str(nFinished+1) '/' num2str(nDir)]);
			
			if ~Score1(kScore)
				status('aborted');
				return;
			end
			
			sScore.finished.s1(kScore)	= true;
			nFinished					= nFinished+1;
			
			save(strPathResult,'-struct','sScore');
		end
	end
%score the second section
	nFinished	= sum(sScore.finished.s2);
	for kD=1:nDir
		kScore	= sScore.kOrder(kD);
		
		if ~sScore.finished.s2(kScore)
			status(['scoring activity 2 ' num2str(nFinished+1) '/' num2str(nDir)]);
			
			if ~Score2(kScore)
				status('aborted');
				return;
			end
			
			sScore.finished.s2(kScore)	= true;
			nFinished					= nFinished+1;
			
			save(strPathResult,'-struct','sScore');
		end
	end
%score the third section
	nFinished	= sum(sScore.finished.s3);
	for kD=1:nDir
		kScore	= sScore.kOrder(kD);
		
		if ~sScore.finished.s3(kScore)
			status(['scoring activity 3 ' num2str(nFinished+1) '/' num2str(nDir)]);
			
			if ~Score3(kScore)
				status('aborted');
				return;
			end
			
			sScore.finished.s3(kScore)	= true;
			nFinished					= nFinished+1;
			
			save(strPathResult,'-struct','sScore');
		end
	end
%calculate the creativity scores
	status('compiling scores');
	
	strPathNorm	= PathAddSuffix(mfilename('fullpath'),'_norm','csv');
	sNorm		= table2struct(fget(strPathNorm),'delim','csv');
	rsMax		= numel(sNorm.RS);
	ssciMin		= min(sNorm.Average_Index_SS_CI);
	ssciMax		= max(sNorm.Average_Index_SS_CI);
	em1Max		= numel(sNorm.Elaboration_Map_1);
	em2Max		= numel(sNorm.Elaboration_Map_2);
	em3Max		= numel(sNorm.Elaboration_Map_3);
	
	sScore.score.fluency.rs	= reshape([sScore.result.S2_Fluency] + [sScore.result.S3_Fluency],[],1);
	sScore.score.fluency.np	= sNorm.Fluency_NP(max(1,min(rsMax,sScore.score.fluency.rs)));
	sScore.score.fluency.ss	= sNorm.Fluency_SS(max(1,min(rsMax,sScore.score.fluency.rs)));
	
	sScore.score.originality.rs	= reshape([sScore.result.S1_Originality] + [sScore.result.S2_Originality] + [sScore.result.S2_Originality_Bonus] + [sScore.result.S3_Originality] + [sScore.result.S3_Originality_Bonus],[],1);
	sScore.score.originality.np	= sNorm.Originality_NP(max(1,min(rsMax,sScore.score.originality.rs)));
	sScore.score.originality.ss	= sNorm.Originality_SS(max(1,min(rsMax,sScore.score.originality.rs)));
	
	sScore.score.elaboration.rs	= reshape(sNorm.Elaboration_Map_1(max(1,min(em1Max,[sScore.result.S1_Elaboration]))) + sNorm.Elaboration_Map_2(max(1,min(em2Max,[sScore.result.S2_Elaboration]))) + sNorm.Elaboration_Map_3(max(1,min(em3Max,[sScore.result.S3_Elaboration]))),[],1);
	sScore.score.elaboration.np	= sNorm.Elaboration_NP(max(1,min(rsMax,sScore.score.elaboration.rs)));
	sScore.score.elaboration.ss	= sNorm.Elaboration_SS(max(1,min(rsMax,sScore.score.elaboration.rs)));
	
	sScore.score.titles.rs	= reshape([sScore.result.S1_Abstractness_of_Titles] + [sScore.result.S2_Abstractness_of_Titles],[],1);
	sScore.score.titles.np	= sNorm.Titles_NP(max(1,min(rsMax,sScore.score.titles.rs)));
	sScore.score.titles.ss	= sNorm.Titles_SS(max(1,min(rsMax,sScore.score.titles.rs)));
	
	sScore.score.closure.rs	= reshape([sScore.result.S2_Resistance_to_Premature_Closure],[],1);
	sScore.score.closure.np	= sNorm.Closure_NP(max(1,min(rsMax,sScore.score.closure.rs)));
	sScore.score.closure.ss	= sNorm.Closure_SS(max(1,min(rsMax,sScore.score.closure.rs)));
	
	sScore.score.checklist.emotion			= reshape([sScore.result.S1_Emotional_Expressiveness] + [sScore.result.S2_Emotional_Expressiveness] + [sScore.result.S3_Emotional_Expressiveness],[],1);
	sScore.score.checklist.story			= reshape([sScore.result.S1_Storytelling_Articulateness] + [sScore.result.S2_Storytelling_Articulateness] + [sScore.result.S3_Storytelling_Articulateness],[],1);
	sScore.score.checklist.movement			= reshape([sScore.result.S1_Movement_or_Action] + [sScore.result.S2_Movement_or_Action] + [sScore.result.S3_Movement_or_Action],[],1);
	sScore.score.checklist.expressiveness	= reshape([sScore.result.S1_Expressiveness_of_Titles] + [sScore.result.S2_Expressiveness_of_Titles] + [sScore.result.S3_Expressiveness_of_Titles],[],1);
	sScore.score.checklist.synthesis_fig	= reshape([sScore.result.S2_Synthesis_of_Incomplete_Figures],[],1);
	sScore.score.checklist.synthesis_line	= reshape([sScore.result.S3_Synthesis_of_Lines],[],1);
	sScore.score.checklist.unusual_visual	= reshape([sScore.result.S1_Unusual_Visualization] + [sScore.result.S2_Unusual_Visualization] + [sScore.result.S3_Unusual_Visualization],[],1);
	sScore.score.checklist.internal_visual	= reshape([sScore.result.S1_Internal_Visualization] + [sScore.result.S2_Internal_Visualization] + [sScore.result.S3_Internal_Visualization],[],1);
	sScore.score.checklist.boundaries		= reshape([sScore.result.S3_Extending_or_Breaking_Boundaries],[],1);
	sScore.score.checklist.humor			= reshape([sScore.result.S1_Humor] + [sScore.result.S2_Humor] + [sScore.result.S3_Humor],[],1);
	sScore.score.checklist.richness			= reshape([sScore.result.S1_Richness_of_Imagery] + [sScore.result.S2_Richness_of_Imagery] + [sScore.result.S3_Richness_of_Imagery],[],1);
	sScore.score.checklist.colorfulness		= reshape([sScore.result.S1_Colorfulness_of_Imagery] + [sScore.result.S2_Colorfulness_of_Imagery] + [sScore.result.S3_Colorfulness_of_Imagery],[],1);
	sScore.score.checklist.fantasy			= reshape([sScore.result.S1_Fantasy] + [sScore.result.S2_Fantasy] + [sScore.result.S3_Fantasy],[],1);
	
	sScore.score.avg.ss	= mean([sScore.score.fluency.ss sScore.score.originality.ss sScore.score.elaboration.ss sScore.score.titles.ss sScore.score.closure.ss],2);
	sScore.score.avg.np	= interp1(sNorm.Average_Index_SS_CI,sNorm.Average_Index_SS_NP,max(ssciMin,min(ssciMax,sScore.score.avg.ss)),'linear');
	sScore.score.bonus	= 	arrayfun(@(x) switch2(x,0,0,1,1,2,1,2),sScore.score.checklist.emotion)					+ ...
							arrayfun(@(x) switch2(x,0,0,1,1,2,1,2),sScore.score.checklist.story)					+ ...
							arrayfun(@(x) switch2(x,0,0,1,1,2,1,2),sScore.score.checklist.movement)					+ ...
							arrayfun(@(x) switch2(x,0,0,1,1,2,1,2),sScore.score.checklist.expressiveness)			+ ...
							arrayfun(@(x) switch2(x,0,0,1,1,2),sScore.score.checklist.synthesis_fig)				+ ...
							arrayfun(@(x) switch2(x,0,0,1,1,2,1,2),sScore.score.checklist.synthesis_line)			+ ...
							arrayfun(@(x) switch2(x,0,0,1,1,2,1,2),sScore.score.checklist.unusual_visual)			+ ...
							arrayfun(@(x) switch2(x,0,0,1,1,2,1,2),sScore.score.checklist.internal_visual)			+ ...
							arrayfun(@(x) switch2(x,0,0,1,1,2,1,2),sScore.score.checklist.boundaries)				+ ...
							arrayfun(@(x) switch2(x,0,0,1,1,2,1,2),sScore.score.checklist.humor)					+ ...
							arrayfun(@(x) switch2(x,0,0,1,0,2,0,3,0,4,1,5,1,2),sScore.score.checklist.richness)		+ ...
							arrayfun(@(x) switch2(x,0,0,1,1,2,1,2),sScore.score.checklist.colorfulness)				+ ...
							arrayfun(@(x) switch2(x,0,0,1,1,2,1,2),sScore.score.checklist.fantasy)					  ...
							;
	
	sScore.score.ci.ss	= sScore.score.avg.ss + sScore.score.bonus;
	sScore.score.ci.np	= interp1(sNorm.Average_Index_SS_CI,sNorm.Average_Index_CI_NP,max(ssciMin,min(ssciMax,sScore.score.ci.ss)),'linear');
	
	save(strPathResult,'-struct','sScore');
%done?
	status('finished!');

%------------------------------------------------------------------------------%
function bFinished = Score1(k)
	%show the first page
		im	= rgbRead(sScore.path{k}{1});
		hIm	= ImageViewer(im,'zoom',33);
	%show the data entry
		cName	=	{
						'S1 Originality'
						'S1 Elaboration'
						'S1 Abstractness of Titles'
						'S1 Emotional Expressiveness'
						'S1 Storytelling Articulateness'
						'S1 Movement or Action'
						'S1 Expressiveness of Titles'
						'S1 Unusual Visualization'
						'S1 Internal Visualization'
						'S1 Humor'
						'S1 Richness of Imagery'
						'S1 Colorfulness of Imagery'
						'S1 Fantasy'
					};
					
		x			= DataEntry(cName,'title','Activity 1','default',0,'output','struct','width',wDataEntry);
		bFinished	= ~isempty(x);
		
		if bFinished
			sScore.result		= addfields(sScore.result,sort(fieldnames(x)));
			sScore.result(k)	= StructMerge(sScore.result(k),x);
		end
	%close the image
		if ishandle(hIm)
			close(hIm);
		end
end
%------------------------------------------------------------------------------%
function bFinished = Score2(k)
	%show the second and third pages
		im	= [rgbRead(sScore.path{k}{2}) rgbRead(sScore.path{k}{3})];
		hIm	= ImageViewer(im,'zoom',33,'position',[0 0]);
	%show the data entry
		cName	=	{
						'S2 Fluency'
						'S2 Originality'
						'S2 Originality Bonus'
						'S2 Elaboration'
						'S2 Abstractness of Titles'
						'S2 Resistance to Premature Closure'
						'S2 Emotional Expressiveness'
						'S2 Storytelling Articulateness'
						'S2 Movement or Action'
						'S2 Expressiveness of Titles'
						'S2 Synthesis of Incomplete Figures'
						'S2 Unusual Visualization'
						'S2 Internal Visualization'
						'S2 Humor'
						'S2 Richness of Imagery'
						'S2 Colorfulness of Imagery'
						'S2 Fantasy'
					};
					
		x			= DataEntry(cName,'title','Activity 2','default',0,'output','struct','width',wDataEntry);
		bFinished	= ~isempty(x);
		
		if bFinished
			sScore.result		= addfields(sScore.result,sort(fieldnames(x)));
			sScore.result(k)	= StructMerge(sScore.result(k),x);
		end
	%close the image
		if ishandle(hIm)
			close(hIm);
		end
end
%------------------------------------------------------------------------------%
function bFinished = Score3(k)
	%show the fourth through sixth pages
		im	= [rgbRead(sScore.path{k}{4}) rgbRead(sScore.path{k}{5}) rgbRead(sScore.path{k}{6})];
		hIm	= ImageViewer(im,'zoom',33,'position',[0 0]);
	%show the data entry
		cName	=	{
						'S3 Fluency'
						'S3 Originality'
						'S3 Originality Bonus'
						'S3 Elaboration'
						'S3 Emotional Expressiveness'
						'S3 Storytelling Articulateness'
						'S3 Movement or Action'
						'S3 Expressiveness of Titles'
						'S3 Synthesis of Lines'
						'S3 Unusual Visualization'
						'S3 Internal Visualization'
						'S3 Extending or Breaking Boundaries'
						'S3 Humor'
						'S3 Richness of Imagery'
						'S3 Colorfulness of Imagery'
						'S3 Fantasy'
					};
					
		x			= DataEntry(cName,'title','Activity 3','default',0,'output','struct','width',wDataEntry);
		bFinished	= ~isempty(x);
		
		if bFinished
			sScore.result		= addfields(sScore.result,sort(fieldnames(x)));
			sScore.result(k)	= StructMerge(sScore.result(k),x);
		end
	%close the image
		if ishandle(hIm)
			close(hIm);
		end
end
%------------------------------------------------------------------------------%

end
