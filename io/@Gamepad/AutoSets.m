function obj = AutoSets(obj)
% AutoSets
%
% Description: adds built in buttons and button sets automatically to the
%              obj.btnSets struct
%
% Syntax = obj = obj.AutoSets;  
%
% Updated: 2011-12-05
% Scottie Alexander
% Alex Schlegel

%map individual buttons
	cButton	= obj.buttons.domain;
	nButton	= numel(cButton);
	for kB=1:nButton
		obj	= obj.AddSet(cButton{kB},{{cButton{kB}}});
	end
%map all or none
	cAll	= reshape(cellfun(@(x) {x},obj.buttons.domain,'UniformOutput',false),[],1);
	
	obj	= obj.AddSet('any',cAll,false);
	obj	= obj.AddSet('none',[],true);
	
end
