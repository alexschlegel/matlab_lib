function p_Map(inp,strButton,butGood,butBad)
% p_Map
% 
% Description:	map a button based on a nested definition
% 
% Syntax:	p_Map(inp,strButton,sDef)
% 
% In:
% 	inp			- the Input object
%	strButton	- the button name
%	butGood		- a nested cell defining the good buttons in the set (see
%				  PTB.Device.Input.Set)
%	butBad		- a nested cell defining the bad buttons in the set
% 
% Updated: 2011-12-21
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global PTBIFO;

%store the original definition
	PTBIFO.input.(inp.type).button.(strButton).def.good	= butGood;
	PTBIFO.input.(inp.type).button.(strButton).def.bad	= butBad;
%store the sub-buttons involved with the new button
	cButton	= append(cellnestmembers(butGood),cellnestmembers(butBad));
	bChar	= cellfun(@ischar,cButton);
	cButton	= cButton(bChar);
	nButton	= numel(cButton);
	
	PTBIFO.input.(inp.type).button.(strButton).dependency	= cButton;
	
	for kB=1:nButton
		PTBIFO.input.(inp.type).button.(cButton{kB}).dependents{end+1}	= strButton;
	end
%expand button names to indices
	butGood	= cellnestfun(@(x) inp.Get(x),butGood);
	butBad	= cellnestfun(@(x) inp.Get(x),butBad);
%simplify the expressions
	butGood	= CellLogicSimplify(butGood);
	butBad	= CellLogicSimplify(butBad);
%arrayify and make sure we don't have subsets of good buttons in the bad buttons
	butGood	= cellfun(@cell2mat,butGood,'UniformOutput',false);
	butBad	= cellfun(@cell2mat,butBad,'UniformOutput',false);
	
	bBadRemove			= cellfun(@(b) any(cellfun(@(g) isempty(setdiff(b,g)),butGood)),butBad);
	butBad(bBadRemove)	= [];
	
	PTBIFO.input.(inp.type).button.(strButton).good	= butGood;
	PTBIFO.input.(inp.type).button.(strButton).bad	= butBad;
%remap super-buttons
	if ~isfield(PTBIFO.input.(inp.type).button.(strButton),'dependents')
		PTBIFO.input.(inp.type).button.(strButton).dependents	= {};
	end
	
	p_RemapDependents(inp,strButton);

