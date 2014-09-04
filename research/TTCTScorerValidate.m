function sScore = TTCTScorerValidate(strDirTTCT,strScorer)
% TTCTScorerValidate
% 
% Description:	use to validate scores completed using TTCTScorer
% 
% Syntax:	TTCTScorerValidate(strDirTTCT,strScorer)
% 
% In:
%	strDirTTCT	- the directory containing saved results
%	strScorer	- the scorer's initials
% 
% Updated: 2012-07-30
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
wDataEntry	= 300;

strPathResult	= PathUnsplit(strDirTTCT,['ttctscorer_' strScorer],'mat');
sScore			= load(strPathResult);
nScore			= numel(sScore.dir);

%find the scores that need to be checked
	[bCheck,cFieldCheck,kActivityCheck]	= arrayfun(@CheckScore,sScore.result,'UniformOutput',false);
	kCheck									= find(cell2mat(bCheck));
	nCheck									= numel(kCheck);
%check 'em
	for kC=1:nCheck
		status(['checking ' num2str(kC) '/' num2str(nCheck)]);
		
		kCur			= kCheck(kC);
		cFieldCheckCur	= cFieldCheck{kCur};
		kActivityCur	= kActivityCheck{kCur};
		
		%score 1
			if ismember(kActivityCur,1)
				if ~Score1(kCur,cFieldCheckCur)
					status('aborted');
					return;
				end
				
				save(strPathResult,'-struct','sScore');
			end
		%score 2
			if ismember(kActivityCur,2)
				if ~Score2(kCur,cFieldCheckCur)
					status('aborted');
					return;
				end
				
				save(strPathResult,'-struct','sScore');
			end
		%score 3
			if ismember(kActivityCur,3)
				if ~Score3(kCur,cFieldCheckCur)
					status('aborted');
					return;
				end
				
				save(strPathResult,'-struct','sScore');
			end
	end



%------------------------------------------------------------------------------%
function [bCheck,cFieldCheck,kActivityCheck] = CheckScore(res)
	persistent ifoCheck nField;
	
	if isempty(ifoCheck)
		ifoCheck	=	{	%field name								%upper bound	%compare to								%compare op	%compare val
							'S1_Abstractness_of_Titles'			3				NaN										NaN			NaN
							'S1_Colorfulness_of_Imagery'			1				NaN										NaN			NaN
							'S1_Elaboration'						100				NaN										NaN			NaN
							'S1_Emotional_Expressiveness'			1				NaN										NaN			NaN
							'S1_Expressiveness_of_Titles'			1				NaN										NaN			NaN
							'S1_Fantasy'							1				NaN										NaN			NaN
							'S1_Humor'								1				NaN										NaN			NaN
							'S1_Internal_Visualization'			1				NaN										NaN			NaN
							'S1_Movement_or_Action'				1				NaN										NaN			NaN
							'S1_Originality'						1				NaN										NaN			NaN
							'S1_Richness_of_Imagery'				1				NaN										NaN			NaN
							'S1_Storytelling_Articulateness'		1				NaN										NaN			NaN
							'S1_Unusual_Visualization'				1				NaN										NaN			NaN
							'S2_Abstractness_of_Titles'			30				NaN										NaN			NaN
							'S2_Colorfulness_of_Imagery'			10				NaN										NaN			NaN
							'S2_Elaboration'						150				NaN										NaN			NaN
							'S2_Emotional_Expressiveness'			10				NaN										NaN			NaN
							'S2_Expressiveness_of_Titles'			10				NaN										NaN			NaN
							'S2_Fantasy'							10				NaN										NaN			NaN
							'S2_Fluency'							10				NaN										NaN			NaN
							'S2_Humor'								10				NaN										NaN			NaN
							'S2_Internal_Visualization'			10				NaN										NaN			NaN
							'S2_Movement_or_Action'				10				NaN										NaN			NaN
							'S2_Originality'						10				NaN										NaN			NaN
							'S2_Originality_Bonus'					10				'S2_Synthesis_of_Incomplete_Figures'	'>='		2
							'S2_Resistance_to_Premature_Closure'	20				NaN										NaN			NaN
							'S2_Richness_of_Imagery'				10				NaN										NaN			NaN
							'S2_Storytelling_Articulateness'		10				NaN										NaN			NaN
							'S2_Synthesis_of_Incomplete_Figures'	5				'S2_Originality_Bonus'					'<='		1/2
							'S2_Unusual_Visualization'				10				NaN										NaN			NaN
							'S3_Colorfulness_of_Imagery'			30				NaN										NaN			NaN
							'S3_Elaboration'						200				NaN										NaN			NaN
							'S3_Emotional_Expressiveness'			30				NaN										NaN			NaN
							'S3_Expressiveness_of_Titles'			30				NaN										NaN			NaN
							'S3_Extending_or_Breaking_Boundaries'	30				NaN										NaN			NaN
							'S3_Fantasy'							30				NaN										NaN			NaN
							'S3_Fluency'							30				NaN										NaN			NaN
							'S3_Humor'								30				NaN										NaN			NaN
							'S3_Internal_Visualization'			30				NaN										NaN			NaN
							'S3_Movement_or_Action'				30				NaN										NaN			NaN
							'S3_Originality'						30				NaN										NaN			NaN
							'S3_Originality_Bonus'					30				'S3_Synthesis_of_Lines'				'>='		2
							'S3_Richness_of_Imagery'				30				NaN										NaN			NaN
							'S3_Storytelling_Articulateness'		30				NaN										NaN			NaN
							'S3_Synthesis_of_Lines'				15				'S3_Originality_Bonus'					'<='		1/2
							'S3_Unusual_Visualization'				30				NaN										NaN			NaN
						};
		
		nField	= size(ifoCheck,1);
	end
	
	bCheck			= false;
	cFieldCheck		= {};
	kActivityCheck	= [];
	
	for kF=1:nField
		x	= res.(ifoCheck{kF,1});
		
		bCheckCur	= ~IsInteger(x) || ~IsBetween(x,0,ifoCheck{kF,2});
		
		if ~bCheckCur && ~any(isnan(ifoCheck{kF,3})) && IsInteger(res.(ifoCheck{kF,3}))
		%comparison check
			switch ifoCheck{kF,4}
				case '<='
					bCheckCur	= x>ifoCheck{kF,5}.*res.(ifoCheck{kF,3});
				case '>='
					bCheckCur	= x<ifoCheck{kF,5}.*res.(ifoCheck{kF,3});
			end
		end
		
		if bCheckCur
			bCheck			= true;
			cFieldCheck		= [cFieldCheck; ifoCheck{kF}];
			kActivityCheck	= unique([kActivityCheck; str2num(ifoCheck{kF}(2))]);
		end
	end
end
%------------------------------------------------------------------------------%
function b = IsBetween(x,a,b)
	b	= x>=a & x<=b;
end
%------------------------------------------------------------------------------%
function b = IsInteger(x)
	b	= isnumeric(x) && fix(x)==x;
end
%------------------------------------------------------------------------------%
function bFinished = Score1(k,cEm)
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
		cField	= cellfun(@(n) regexprep(n,' ','_'),cName,'UniformOutput',false);
		
		bEm			= ismember(cField,cEm);
		cDefault	= cellfun(@(f) sScore.result(k).(f),cField,'UniformOutput',false);
		
		x			= DataEntry(cName,'title','Activity 1 Validation','default',cDefault,'output','struct','width',wDataEntry,'em',bEm);
		bFinished	= ~isempty(x);
		
		if bFinished
			sScore.result(k)	= StructMerge(sScore.result(k),x);
		end
	%close the image
		if ishandle(hIm)
			close(hIm);
		end
end
%------------------------------------------------------------------------------%
function bFinished = Score2(k,cEm)
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
		cField	= cellfun(@(n) regexprep(n,' ','_'),cName,'UniformOutput',false);
		
		bEm			= ismember(cField,cEm);
		cDefault	= cellfun(@(f) sScore.result(k).(f),cField,'UniformOutput',false);
		
		x			= DataEntry(cName,'title','Activity 2 Validation','default',cDefault,'output','struct','width',wDataEntry,'em',bEm);
		bFinished	= ~isempty(x);
		
		if bFinished
			sScore.result(k)	= StructMerge(sScore.result(k),x);
		end
	%close the image
		if ishandle(hIm)
			close(hIm);
		end
end
%------------------------------------------------------------------------------%
function bFinished = Score3(k,cEm)
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
		cField	= cellfun(@(n) regexprep(n,' ','_'),cName,'UniformOutput',false);
		
		bEm			= ismember(cField,cEm);
		cDefault	= cellfun(@(f) sScore.result(k).(f),cField,'UniformOutput',false);
		
		x			= DataEntry(cName,'title','Activity 3 Validation','default',cDefault,'output','struct','width',wDataEntry,'em',bEm);
		bFinished	= ~isempty(x);
		
		if bFinished
			sScore.result(k)	= StructMerge(sScore.result(k),x);
		end
	%close the image
		if ishandle(hIm)
			close(hIm);
		end
end
%------------------------------------------------------------------------------%

end
