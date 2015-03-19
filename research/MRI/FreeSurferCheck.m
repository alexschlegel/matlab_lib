function [bSuccess,bRerun] = FreeSurferCheck(cDirFreeSurfer,kStage,varargin)
% FreeSurferCheck
% 
% Description:	check a recon-all stage of the freesurfer reconstruction pipline
% 
% Syntax:	[bSuccess,bRerun] = FreeSurferCheck(cDirFreeSurfer,kStage,<options>)
% 
% In:
% 	cDirFreeSurfer	- the freesurfer directory or cell of freesurfer directories
%					  to check
%	kStage			- the stage to check
%	<options>:
%		check:	(true) true to actually perform the check, false to just pretend
%				that we did
% 
% Out:
% 	bSuccess	- a logical array indicating which directories were successfully
%				  checked
%	bRerun		- a logical array indicating which directories should be rerun
%				  in the specified stage
% 
% Updated: 2015-03-16
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'check'	, true	  ...
		);

cDirFreeSurfer	= ForceCell(cDirFreeSurfer);
cDirFreeSurfer	= cellfun(@AddSlash,cDirFreeSurfer,'UniformOutput',false);

if opt.check
	switch kStage
		case 1
			[bSuccess,bRerun]	= cellfunprogress(@CheckStage1,cDirFreeSurfer,'label','Checking freesurfer stage 1');
		case 2
			[bSuccess,bRerun]	= cellfunprogress(@CheckStage2,cDirFreeSurfer,'label','Checking freesurfer stage 2');
		otherwise
			error('There is nothing to check for the specified stage.');
	end
else
	sz			= size(cDirFreeSurfer);
	bSuccess	= true(sz);
	bRerun		= false(sz);
end

bSuccess(bSuccess)	= cellfun(@(d) fput('1',PathUnsplit(d,['stage' num2str(kStage) 'checked'],'')),cDirFreeSurfer(bSuccess));


%------------------------------------------------------------------------------%
function [bSuccess,bRerun] = CheckStage1(strDirFreeSurfer)
	strDirUp	= DirSub(strDirFreeSurfer,1,-1);
	strSubject	= DirSub(strDirFreeSurfer,0,0);
	
	[bSuccess,bRerun]	= deal(false);
	
	disp(['Checking freesurfer stage 1 for ' strDirFreeSurfer]); 
	
	disp('   Check the Talairach transformation');
	if ~CallProcess('freesurferscript',{strDirUp 'tkregister2' '--mgz' '--s' strSubject '--fstal'});
		disp('   Check the results of skull stripping and normalization.  Add control points if necessary.');
		bSuccess	= ~CallProcess('freesurferscript',{strDirUp 'tkmedit' strSubject 'brainmask.mgz' '-aux' 'T1.mgz' '-tcl' '~/scripts/makesize3.tcl'});
	end
	
	disp(['   ' conditional(bSuccess,'Success','Failure') '!']);
end
%------------------------------------------------------------------------------%
function [bSuccess,bRerun] = CheckStage2(strDirFreeSurfer)
	strDirUp	= DirSub(strDirFreeSurfer,1,-1);
	strSubject	= DirSub(strDirFreeSurfer,0,0);
	
	[bSuccess,bRerun]	= deal(false);
	
	disp(['Checking freesurfer stage 2 for ' strDirFreeSurfer]);
	
	disp('   Check the white matter (yellow line) and gray matter (red line) boundaries.');
	if ~CallProcess('freesurferscript',{strDirUp 'tkmedit' strSubject 'brainmask.mgz' 'lh.white' '-aux' 'wm.mgz' '-aux-surface' 'rh.white'})
		disp('   Check the left hemisphere white/gray boundary surface');
		if ~CallProcess('freesurferscript',{strDirUp 'tksurfer' strSubject 'lh white'})
			disp('   Check the left hemisphere pial surface');
			if ~CallProcess('freesurferscript',{strDirUp 'tksurfer' strSubject 'lh pial'})
				disp('   Check the right hemisphere white/gray boundary surface');
				if ~CallProcess('freesurferscript',{strDirUp 'tksurfer' strSubject 'rh white'})
					disp('   Check the left hemisphere white/gray boundary surface');
					bSuccess	=  ~CallProcess('freesurferscript',{strDirUp 'tksurfer' strSubject 'rh pial'})
				end
			end
		end
	end
	
	if bSuccess
		disp('   Success!');
		
		bRerun	= isequal(ask('   Were edits made?','dialog',false,'choice',{'y','n'}),'y');
	else
		disp('   Failure!');
	end
end
%------------------------------------------------------------------------------%

end
