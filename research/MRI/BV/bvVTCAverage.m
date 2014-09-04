function varargout = bvVTCAverage(strDirBase,strSession,kRun,varargin)
% bvVTCAverage
% 
% Description:	average a set of VTCs
% 
% Syntax:	[vtc] = bvVTCAverage(strDirBase,strSession,kRun,[kRunInv]=[],<options>)
% 
% In:
%	strDirBase	- base study directory
%	strSession	- the session code
%	kRun		- an array of run numbers in which the stimuli were presented
%				  normally (e.g. CW wedges or expanding rings)
%	[kRunInv]	- an array of run number in which the stimuli were presented
%				  inversely (e.g. CCW wedges or contracting rings)
%	<options>:
%		'outpath':		(<don't save>) path to which to save the averaged VTC
%		'vtcsuffix':	('_SCCA_3DMCT_THPGLMF2c') VTC file names should be
%						formatted as <strSession>_<run><vtcsuffix>.vtc
%		'fixhrf':		(<true if inverse runs exist, false otherwise>) true
%						to shift timecourses left by an estimation of the HRF
%						delay before reversing/averaging
%		'tr':			([]) temporal resolution of the functional scans, in ms. 
%						must be specified if 'fixhrf' is true
%		'nblankpre':	([]) number of blank volumes collected before the
%						stimuli were shown.  must be specified if 'fixhrf' is
%						true or 'nblankkeep' is specified
%		'nblankpost':	(<'nblankpre'>) number of blank volumes collected after
%						the stimuli were shown.
%		'nblankkeep':	(<all>) number of pre/post-blank volumes to keep
% 
% Out:
% 	vtc	- the average of the specified VTCs, in which all VTCs have been shifted
%		  left by HRF volumes and reversed VTC timecourses have been reversed,
%		  if specified
% 
% Updated:	2010-04-17
% Copyright 2010 Alex Schlegel (alex@roguecheddar.com).  All Rights Reserved.

%parse optional arguments
	[kRunInv,opt]	= ParseArgsOpt(varargin,[], ...
						'outpath'		, []						, ...
						'vtcsuffix'		, '_SCCA_3DMCT_THPGLMF2c'	, ...
						'fixhrf'		, []						, ...
						'tr'			, []						, ...
						'nblankpre'		, []						, ...
						'nblankpost'	, []						, ...
						'nblankkeep'	, []						  ...
						);
	if isempty(opt.fixhrf)
		opt.fixhrf	= ~isempty(kRunInv);
	end
	if opt.fixhrf
		if isempty(opt.tr)
			error('If ''fixhrf'' option is true, ''tr'' option must be specified');
		end
	end
	bDoBlanks	= opt.fixhrf || ~isempty(opt.nblankkeep);
	if bDoBlanks && (isempty(opt.nblankpre) || isempty(opt.nblankpost))
		error('If ''fixhrf'' option is true or ''nblankkeep'' option is specified, then ''nblankpre'' and ''nblankpost'' options must also be specified.');
	end

%check to make sure we have at least one pre- and post-stimulus blank volume
	if bDoBlanks && (opt.nblankpre<1 || opt.nblankpost<1)
		error('bvVTCAverage:InvalidNumberOfBlankVolumes','There must be at least one pre-stimulus and one post-stimulus blank volume.');
	end
%get the number of pre/post blanks to keep
	if bDoBlanks
		if opt.fixhrf
			dHRF	= GetDelayHRF(opt.tr);
			
			%make sure at least dHRF post-blanks were collected
				if opt.nblankpost-dHRF<0
					error('bvVTCAverage:TooFewPostBlankVolumes','The number of post-stimulus blank volumes collected is less than the HRF delay.');
				end
		else
			dHRF	= 0;
		end
		
		nKeep	= min([opt.nblankkeep opt.nblankpre opt.nblankpost-dHRF]);
		
		nDeletePre	= opt.nblankpre - nKeep;
		if opt.fixhrf
			nDeletePost	= opt.nblankpost - nKeep - dHRF;
		else
			nDeletePost	= opt.nblankpost - nKeep;
		end
	end

strDirFunctional	= GetDirFunctional(strDirBase,strSession);

nRunNorm	= numel(kRun);
nRunInv		= numel(kRunInv);

kRun	= [reshape(kRun,1,[]) reshape(kRunInv,1,[])];
nRun	= numel(kRun);

bInv	= [false(nRunNorm,1); true(nRunInv,1)];

vtc	= cell(1,nRun);
%process each VTC
	status(['Averaging VTCs for session ' strSession]);
	progress(nRun,'label','VTC');
	
	cDirRun	= GetDirRun(strDirBase,strSession,kRun,'cell_output',true);
	
	for k=1:nRun
		%path to VTC file
			strRun		= StringFill(kRun(k),2);
			strPathVTC	= [cDirRun{k} strSession '_' strRun opt.vtcsuffix '.vtc'];
			
		%load the VTC
			vtc{k}	= BVQXfile(strPathVTC);
			
		%account for the HRF
			if opt.fixhrf
				vtc{k}	= FixHRF(vtc{k},opt.tr);
			end
		
		%remove extra blank periods
			if bDoBlanks
				vtc{k}.VTCData	= vtc{k}.VTCData(nDeletePre+1:end-nDeletePost,:,:,:);
			end
			
		%reverse timecourse if stimulus was inverse
			if bInv(k)
				vtc{k}.VTCData	= vtc{k}.VTCData(end:-1:1,:,:,:);
			end
		
		progress;
	end

%average the VTCs
	for k=2:nRun
		vtc{1}.VTCData	= vtc{1}.VTCData + vtc{k}.VTCData;
	end
	vtc{1}.VTCData	= vtc{1}.VTCData ./ nRun;
	
%bless vtcAvg
	vtc{1}	= bless(vtc{1});
	
%release memory
	for k=2:nRun
		vtc{k}	= vtc{k}.ClearObject;
	end

%save the average VTC
	if ~isempty(opt.outpath)
		vtc{1}.SaveAs(opt.outpath);
	end
%output the average VTC
	if nargout>0
		varargout{1}	= vtc{1};
	end


%------------------------------------------------------------------------------%
function vtc = FixHRF(vtc,TR)
	HRF			= GetDelayHRF(TR);
	vtc.VTCData	= vtc.VTCData(HRF+1:end,:,:,:);
%------------------------------------------------------------------------------%
function d = GetDelayHRF(TR)
	d	= round(4500/TR);
%------------------------------------------------------------------------------%
