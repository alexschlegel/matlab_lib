function [cPathOut,kRemove] = FSLMELODICArtifactRemoval(cPathData,TR,varargin)
% FSLMELODICArtifactRemoval
% 
% Description:	manually remove artifacts from preprocessed fMRI data using FSL's
%				MELODIC tool.  Shows each component and asks whether the
%				component is good (default, y) or artifact (n).
% 
% Syntax:	[cPathOut,kRemove] = FSLMELODICArtifactRemoval(cPathData,TR,<options>)
% 
% In:
% 	cPathData	- a path or cell of paths to preprocessed fMRI data
%	TR			- the TR duration, in seconds, or an array of TR durations
%	<options>:
%		cores:		(1) the number of processor cores to use for ICA calculation
%		force_pre:	(false) true to force ICA calculation if results already
%					exist
%		force:		(true) true to force if output data already exist
% 
% Out:
% 	cPathOut	- a path/cell of paths to data with artifacts removed
%	kRemove		- an array/cell of array of the ICA components that were marked
%				  for removal
% 
% Updated: 2015-05-01
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%format the input
	opt	= ParseArgs(varargin,...
			'remove'	, true	, ...
			'cores'		, 1		, ...
			'force_pre'	, false	, ...
			'force'		, true	  ...
			);
	
	[cPathData,bNoCell]	= ForceCell(cPathData);
	[cPathData,TR]		= FillSingletonArrays(cPathData,TR);
	sData				= size(cPathData);
	nData				= numel(cPathData);
	kData				= (1:nData)';
	
	cDirICA		= cellfun(@(f) DirAppend(PathGetDir(f),[PathGetFilePre(f,'favor','nii.gz') '.ica']),cPathData,'UniformOutput',false);
	cPathARSpec	= cellfun(@(d) PathUnsplit(d,'artifact',''),cDirICA,'UniformOutput',false);
	cPathOut	= cellfun(@(f) PathAddSuffix(f,'-ar','favor','nii.gz'),cPathData,'UniformOutput',false);
	
	kRemove	= cell(sData);
%which ICAs to do?
	if opt.force_pre
		bICA	= true(nData,1);
		bMark	= true(nData,1);
	else
		bICA	= ~reshape(cellfun(@CheckICA,cDirICA),[],1);
		bMark	= bICA | ~reshape(FileExists(cPathARSpec),[],1);
	end
	
	kRemove(~bMark)	= cellfun(@(f) str2array(fget(f)),cPathARSpec(~bMark),'UniformOutput',false);
%which artifact removals to do?
	if opt.force
		bAR	= true(nData,1);
	else
		bAR	= bMark | ~reshape(FileExists(cPathOut),[],1);
	end
	
	if ~any(bAR)
		return;
	end
%keep track of which artifact removals to do
	bDoneMark	= ~bMark;
	bDoneAR		= ~bAR;
	bReadyMark	= bMark & ~bICA;
	bReadyAR	= bAR & ~bMark;
	
	bStartedMark	= false;
	bStartedAR		= false;
%create and start the artifact removal timers
	tMark	= timer(...
				'TimerFcn'		, @StepMark		, ...
				'Period'		, 0.1				, ...
				'StartDelay'	, 5					, ...
				'ExecutionMode'	, 'fixedSpacing'	, ...
				'BusyMode'		, 'queue'			  ...
				);
	tAR	= timer(...
		'TimerFcn'		, @StepAR			, ...
		'Period'		, 0.1				, ...
		'StartDelay'	, 5					, ...
		'ExecutionMode'	, 'fixedSpacing'	, ...
		'BusyMode'		, 'queue'			  ...
		);
	
	start(tMark);
	start(tAR);
%start ICA computation
	nCoreICA	= max(1,opt.cores-1);
	
	if any(bICA)
		MultiTask(@DoICA,{num2cell(kData(bICA))},...
			'description'	, 'Performing ICA'	, ...
			'cores'			, nCoreICA			  ...
			);
	end
%do the rest of the artifact marking
	stop(tMark);
	delete(tMark);
	
	while ~all(bDoneMark)
		StepMark;
	end
%do the rest of the artifact removals in parallel
	stop(tAR);
	delete(tAR);
	
	progress('action','end','name','ar_remove');
	
	if ~all(bDoneAR)
		MultiTask(@DoAR,{num2cell(kData(~bDoneAR))},...
			'description'	, 'removing artifacts'	, ...
			'cores'			, opt.cores				  ...
			);
	end
%format the output
	if bNoCell
		cPathOut	= cPathOut{1};
		kRemove		= kRemove{1};
	end

%------------------------------------------------------------------------------%
function bDone = CheckICA(strDirICA)
	bDone	= false;
	
	if isdir(strDirICA)
	%ICA directory exists
		strPathMM	= PathUnsplit(strDirICA,'melodic_mix','');
		
		if FileExists(strPathMM)
		%melodic mix file exists
			ica		= str2array(fget(strPathMM));
			nComp	= size(ica,2);
			
			strPathCompCheck	= PathUnsplit(DirAppend(strDirICA,'report'),['IC_' num2str(nComp) '_prob'],'png');
			bDone				= FileExists(strPathCompCheck);
		end
	end
end
%------------------------------------------------------------------------------%
function DoICA(kData)
	CallProcess('melodic',{'-i' cPathData{kData} '-o' cDirICA{kData} '--nobet','--report',['--tr=' num2str(TR(kData))]});
end
%------------------------------------------------------------------------------%
function StepMark(varargin)
	kDoMark	= find(bReadyMark,1);
	
	if ~isempty(kDoMark)
		bReadyMark(kDoMark)	= false;
		
		if ~bStartedMark
		%first call
			bStartedMark	= true;
			
			progress('action','init','total',sum(bMark),'name','ar_mark','label','marking artifacts');
		end
		
		DoMark(kDoMark);
		bDoneMark(kDoMark)	= true;
		bReadyAR(kDoMark)	= true;
		progress('name','ar_mark');
	end
end
%------------------------------------------------------------------------------%
function DoMark(kData)
	strDirReport	= DirAppend(cDirICA{kData},'report');
	strPathMM		= PathUnsplit(cDirICA{kData},'melodic_mix','');
	
	nComp	= size(str2array(fget(strPathMM)),2);
	
	status(['Marking artifacts for ' cDirICA{kData}]);
	
	strNC	= num2str(nComp);
	for kC=1:nComp
		strC	= num2str(kC);
		
		status(['component ' strC '/' strNC],'noffset',1);
		
		%load the report images
			strPathICA_Map	= PathUnsplit(strDirReport,['IC_' strC '_thresh'],'png');
			strPathICA_T	= PathUnsplit(strDirReport,['t' strC],'png');
			strPathICA_F	= PathUnsplit(strDirReport,['f' strC],'png');
			
			imMap		= imread(strPathICA_Map);
			[imT,mapT]	= imread(strPathICA_T);
			[imF,mapF]	= imread(strPathICA_F);
			
			imT	= ind2rgb(imT,mapT);
			imF	= ind2rgb(imF,mapF);
		%stack the plot windows
			wT	= size(imT,2);
			wF	= size(imF,2);
			
			if wT<wF
				imT(:,wT+1:wF,:)	= 1;
			elseif wF<wT
				imF(:,wF+1:wT,:)	= 1;
			end
			
			imP	= [imT; imF];
		%show each image
			warning('off','Images:initSize:adjustingMag');
			
			pMon	= get(0,'MonitorPositions');
			
			hFMap		= figure;
			hMap		= imshow(imMap,'Border','tight');
			pMap		= get(hFMap,'Position');
			pMap(1:2)	= [0 pMon(1,4)-pMap(4)];
			set(hFMap,'Position',pMap,'Toolbar','none','Menubar','none');
			
			hFP		= figure;
			hP		= imshow(imP,'Border','tight');
			pP		= get(hFP,'Position');
			pP(1:2)	= [pMon(1,3)-pP(3) 0];
			set(hFP,'Position',pP,'Toolbar','none','Menubar','none');
		%ask for yes/no
			res	= ask('Artifact?','dialog',false,'choice',{'n','y'});
			if isequal(res,'y')
				kRemove{kData}	= [kRemove{kData}; kC];
			end
		%close the figures
			close(hFMap);
			close(hFP);
	end
	
	%save the components to remove
		fput(array2str(kRemove{kData}),cPathARSpec{kData});
end
%------------------------------------------------------------------------------%
function StepAR(tmr,f)
	kDoAR	= find(bReadyAR,1);
	
	if ~isempty(kDoAR)
		bReadyAR(kDoAR)	= false;
		
		if ~bStartedAR
		%first call
			bStartedAR	= true;
			
			progress('action','init','total',sum(bAR),'name','ar_remove','label','removing artifacts');
		end
		
		DoAR(kDoAR);
		bDoneAR(kDoAR)	= true;
		progress('name','ar_remove');
	end
end
%------------------------------------------------------------------------------%
function DoAR(kData)
	strPathMM	= PathUnsplit(cDirICA{kData},'melodic_mix','');
	
	status(['Removing artifacts for ' cDirICA{kData}]);
	
	FSLRegFilt(cPathData{kData},strPathMM,kRemove{kData},'output',cPathOut{kData},'silent',true);
end
%------------------------------------------------------------------------------%

end
