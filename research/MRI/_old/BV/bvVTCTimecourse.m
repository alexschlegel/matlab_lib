function [cTimecourse,cVOIName] = bvVTCTimecourse(strDirRoot,cSession,cRun,cPathVOI,varargin)
% bvVTCTimecourse
% 
% Description:	return averaged timecourses for the specified sessions, runs,
%				and VOI(s)
% 
% Syntax:	[cTimecourse,cVOIName] = bvVTCTimecourse(strDirRoot,cSession,cRun,cPathVOI,<options>)
% 
% In:
%	strDirRoot	- path to the root study directory
%	cSession	- a cell of session names
%	cRun		- a cell of array of run numbers, one for each session
%	cPathVOI	- a cell of paths to VOIs, one for each session (specify a
%				  single VOI path for each session, although any given VOI may
%				  contain multiple clusters
%	<options>:
%		'vtcsuffix':	('_SCCA_3DMCT_THPGLMF2c') the VTC file suffix
% 
% Out:
% 	cTimecourse	- an nSession length cell of nTimepoint x nRun x nVOI arrays of
%				  average timecourses for each run and VOI cluster
%	cVOIName	- a cell of the VOI cluster name associated with each timecourse
%
% Assumptions:	assumes VOIs contain the same clusters
% 
% Updated:	2009-08-17
% Copyright 2009 Alex Schlegel (alex@roguecheddar.com).  All Rights Reserved.
opt	= ParseArgs(varargin,...
		'vtcsuffix'	, '_SCCA_3DMCT_THPGLMF2c'	  ...
		);

%make sure we have cells
	[cSession,cRun,cPathVOI]	= ForceCell(cSession,cRun,cPathVOI);

%process each session
	nSession	= numel(cSession);
	cTimecourse	= cell(nSession,1);

	for kS=1:nSession
		n	= status(['Reading timecourses for session: ' cSession{kS}]);
		
		strSession	= cSession{kS};
		
		%load the VOI
			status(['Loading VOI: ' PathGetFileName(cPathVOI{kS})],n+1);
			voi				= BVQXfile(cPathVOI{kS});
			nVOI			= numel(voi.VOI);
			cVOIName		= VOIClusterNames(voi);
		%process each run
			kRun			= cRun{kS};
			nRun			= numel(kRun);
			cPathVTC		= GetPathVTC(strDirRoot,strSession,kRun,'vtcsuffix',opt.vtcsuffix);
			
			cTimecourse{kS}	= nan(0,nRun,nVOI);
			for kR=1:nRun
				status(['Run: ' StringFill(kRun(kR),2)],n+1);
				
				%load the VTC
					vtc			= BVQXfile(cPathVTC{kR});
				%get each VOI timecourse
					for kV=1:nVOI
						%get the VOI coordinates
							%convert the VOI to VTC coordinates
								pVOI	= bvCoordConvert('tal','vtc',voi.VOI(kV).Voxels,'vtc',vtc);
							%get the unique positions
								pVOI	= unique(pVOI,'rows');
							%convert to single indices
								sVTC	= size(vtc.VTCData);
								nT		= sVTC(1);
								sXYZ	= sVTC(2:4);
								kPVOI	= sub2ind(sXYZ,pVOI(:,1),pVOI(:,2),pVOI(:,3));
						%get the average VOI timecourse
							%reshape to nT x nVoxels
								vtcData	= reshape(vtc.VTCData,nT,[]);
							%get all timecourses
								vtcData	= vtcData(:,kPVOI);
							%average and place in the array
								cTimecourse{kS}(1:nT,kR,kV)	= mean(vtcData,2);;
					end
				%clear the VTC
					vtc.ClearObject;
			end
		%clear the VOI
			voi.ClearObject;
	end

%------------------------------------------------------------------------------%
function cVOIName	= VOIClusterNames(voi)
%get the cluster names of a VOI
	nVOI		= numel(voi.VOI);
	cVOIName	= cell(nVOI,1);
	for kVOI=1:nVOI
		cVOIName{kVOI}	= voi.VOI(kVOI).Name;
	end
%------------------------------------------------------------------------------%
