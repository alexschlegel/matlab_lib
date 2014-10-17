function [g,sData] = GroupAssignRolling(strExperiment,varargin)
% GroupAssignRolling
% 
% Description:	assign subjects to groups on a rolling basis
% 
% Syntax:	[g,sData] = GroupAssignRolling(strExperiment,<options>)
% 
% In:
% 	strExperiment	- the experiment name
%	<options>:
%		groups:		(<2 or last>) either the number of groups, or a cell of
%					group names
%		subject:	(<next>) the number of the subject to assign
%		reset:		(false) true to reset the sequence
% 
% Out:
% 	g		- the group for the current subject
%	sData	- the assignment data
% 
% Updated: 2014-10-01
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%parse the inputs
	opt	= ParseArgs(varargin,...
			'groups'	, []	, ...
			'subject'	, []	, ...
			'reset'		, false	  ...
			);
	
	strExperiment	= str2fieldname(strExperiment);

strPathData	= PathAddSuffix(mfilename('fullpath'),'','mat');

%load the data for the current experiment
	if ~opt.reset && MATVarExists(strPathData,strExperiment)
		sData	= MATLoad(strPathData,strExperiment);
		
		%generate the assignments
		sData.subject	= unless(opt.subject,sData.subject+1);
	else
		%format the groups
			if isempty(opt.groups)
				error('Groups are unspecified.');
			elseif isscalar(opt.groups)
				opt.groups	= (1:opt.groups)';
			elseif ~iscell(opt.groups)
				error('Unknown groups format.');
			end
		
		%construct the data struct
			sData.groups	= opt.groups;
			sData.subject	= unless(opt.subject,1);
			sData.kseq		= 0;
			sData.assign	= [];
	end

%make any necessary group assignments
	nAssign	= numel(sData.assign);
	
	if nAssign < sData.subject
		sData.assign(nAssign+1:sData.subject)	= NaN;
	end
	
	for kS=nAssign+1:sData.subject
		sData	= MakeAssignment(sData,kS);
	end

%save the data
	MATSave(strPathData,strExperiment,sData);

%get the specified subject's group
	g	= sData.groups(sData.assign(sData.subject));
	if iscell(sData.groups)
		g	= g{1};
	end

%------------------------------------------------------------------------------%
function sData = GenerateSequence(sData)
	nGroup			= numel(sData.groups);
	sData.sequence	= randomize(1:nGroup);
	sData.kseq		= 1;
end
%------------------------------------------------------------------------------%
function sData = MakeAssignment(sData,kSubject)
	nGroup	= numel(sData.groups);
	
	if sData.kseq==0 || sData.kseq==nGroup
		sData		= GenerateSequence(sData);
	else
		sData.kseq	= sData.kseq + 1;
	end
	
	sData.assign(kSubject)	= sData.sequence(sData.kseq);
end
%------------------------------------------------------------------------------%

end
