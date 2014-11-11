function [cm,cNameLabel,fc,fo,tl,cName1,cName2] = FSLConnectivity(cDirSubject,cNameLabel,varargin)
% FSLConnectivity
% 
% Description:	compute the connectivity between areas for which pairwise tracts
%				have been calculated using FSLROITractFS with default output
%				file paths
% 
% Syntax:	[cm,cNameLabel,fc,fo,tl,cName1,cName2] = FSLConnectivity(cDirSubject,cNameLabel,<options>)
% 
% In:
% 	cDirSubject	- the path/cell of paths to subject's DTI directories on which
%				  FSLROITractFS has already been called using the default output
%				  file paths
%	cNameLabel	- a cell of label names used in FSLROITractFS (or the result of
%				  a previous call to FSLConnectivity)
%	<options>:
%		hemisphere:		('both') 'lh', 'rh', or 'both' to specify hemisphere(s)
%						for which tracts were saved
%		bilateral:		(true) true if tracts were created for interhemispheric
%						connections
%		nsample:		(5000) the nsample option passed to FSLROITractFS
%		lengthcorrect:	(false) true to multiply waytotals by the corresponding
%						tract lengths
%		prctile:		(0) throw out the top and bottom <prctile> fraction of
%						values when normalizing the connectivities
%		fc:				(<calculate>) the fConnect to use (from a previous call
%						to FSLConnectivity).  overrides <forceprep>.
%		fo:				(<calculate>) the fOverlap to use (from a previous call
%						to FSLConnectivity).  overrides <forceprep>.
%		tl:				(<calculate>) the tl to use (from a previous call to
%						FSLConnectivity).  overrides <forceprep>.
%		cname1:			(<calculate>) the cname1 output from a previous call to
%						FSLConnectivity
%		cname2:			(<calculate>) the cname2 output from a previous call to
%						FSLConnectivity
%		forceprep:		(false) true to force recalculation of mask positions and
%						tract lengths even if they have previously been
%						calculated
%		silent:			(false) true to suppress status messages
% 
% Out:
%	cm			- the connectivity matrix
%	cNameLabel	- the processed label names
%	fc			- the fConnect from the call to FSLTractConnectivity
%	fo			- the fOverlap from the call to FSLTractConnectivity
%	cName1		- an nTract x 1 cell of names of the first label in each tract
%	cName2		- an nTract x 1 cell of names of the second label in each tract,
%				  or [] if the tract is from a single mask
% 
% Updated: 2011-03-27
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgs(varargin,...
		'hemisphere'	, 'both'	, ...
		'bilateral'		, true		, ...
		'nsample'		, 5000		, ...
		'lengthcorrect'	, false		, ...
		'prctile'		, 0			, ...
		'fc'			, []		, ...
		'fo'			, []		, ...
		'tl'			, []		, ...
		'cname1'		, []		, ...
		'cname2'		, []		, ...
		'forceprep'		, false		, ...
		'silent'		, false		  ...
		);

if isempty(opt.fc) | isempty(opt.fo) | isempty(opt.tl) | isempty(opt.cname1) | isempty(opt.cname2)
	[bDone,cName1,cName2,cNameLabel,f,tl]	= FSLROITractFSInfo(cDirSubject,cNameLabel,'connectivity',...
												'nsample'		, opt.nsample		, ...
												'force'			, opt.forceprep		, ...
												'silent'		, opt.silent		  ...
												);
	fc	= f{1};
	fo	= f{2};
else
	fc		= opt.fc;
	fo		= opt.fo;
	tl		= opt.tl;
	cName1	= opt.cname1;
	cName2	= opt.cname2;
end

%keep only tracts
	bTract	= ~cellfun(@isempty,cName2);
%connectivity index
	c	= fc(bTract,:).*tl(bTract,:);
	c	= nanmean(c,2);
	c	= normalize(c,'prctile',opt.prctile);
	c	= c(bTract,:);
%normalize again
	%c	= normalize(c);
%fill the stat matrix
	[b,kLabel1]	= ismember(cName1(bTract),cNameLabel);
	[b,kLabel2]	= ismember(cName2(bTract),cNameLabel);
	
	nLabel		= numel(cNameLabel);
	kStat		= sub2ind([nLabel nLabel],kLabel1,kLabel2);
	
	cm			= NaN(nLabel);
	cm(kStat)	= c;
