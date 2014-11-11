function event2attrib(event,durRun,strPathOut,varargin)
% event2attrib
% 
% Description:	convert an event array to an attributes file
% 
% Syntax:	event2attrib(event,durRun,strPathOut,[nCondition]=<auto>,<options>)
% 
% In:
%	event			- an nEvent x 3 array specifying the condition number, time,
%					  and duration of each event, or a cell of such
%	durRun			- the run duration, or an array of durations
%	strPathOut		- the output attribute file path
%	[nCondition]	- the number of conditions
%	<options>:
%		label:	(<numbers>) a cell of strings specifying the label for each
%				condition
% 
% Updated: 2012-08-18
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
[nCondition,opt]	= ParseArgs(varargin,[],...
						'label'	, []	  ...
						);

if isempty(opt.label)
	nCondition	= unless(nCondition,max(event(:,1)));n
	
	opt.label	= arrayfun(@num2str,(1:nCondition)','UniformOutput',false);
else
	nCondition	= unless(nCondition,numel(opt.label));
end

event						= ForceCell(event);
[event,durRun,nCondition]	= FillSingletonArrays(event,durRun,nCondition);

%get the EVs
	ev = cellfun(@event2ev,event,num2cell(durRun),num2cell(nCondition),'UniformOutput',false);
%the runs
	nRun	= numel(ev);
	cRun	= arrayfun(@(k) repmat(k,[size(ev{k},1) 1]),(1:nRun)','UniformOutput',false);
%concatenate
	ev	= cat(1,ev{:});
	run	= num2cell(cat(1,cRun{:}));
	
	nTR	= size(ev,1);
%get a label for each TR
	cLabel	= ['0'; reshape(opt.label,[],1)];
	
	kLabelTR	= arrayfun(@(k) unless(find(ev(k,:))+1,1),(1:nTR)');
	cLabelTR	= cLabel(kLabelTR);
%construct each line
	cLine		= cellfun(@(L,r) [L 9 num2str(r)],cLabelTR,run,'UniformOutput',false);
	strAttrib	= join(cLine,10);
%save
	fput(strAttrib,strPathOut);
	