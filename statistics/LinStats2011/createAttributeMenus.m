function createAttributeMenus( v,x )
% createAttributeMenus private function called by grperrorplot and
% grplot.


% Copyright 2011 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
%
if  isempty(get(v,'UIContextMenu')) || ~ishandle( get(v, 'UIContextMenu') )
    amenu = uicontextmenu;
    set(amenu,'tag', 'AttributeContextMenu');
    bmenu = uimenu( amenu, 'label', 'fill color' );
    createGroupMenus(bmenu, x, @fillgrp );
    bmenu = uimenu( amenu, 'label', 'marker' );
    createGroupMenus(bmenu,  x,  @markergrp );
    bmenu = uimenu( amenu, 'label', 'line style');
    createGroupMenus(bmenu, x, @linestylegrp );
    bmenu = uimenu( amenu, 'label', 'line color');
    createGroupMenus(bmenu, x, @linecolorgrp );
    bmenu = uimenu( amenu, 'label', 'size');
    createGroupMenus(bmenu, x, @sizegrp );
    bmenu = uimenu( amenu, 'label', 'legend','callback', @mlegend);
    set(v, 'UIContextMenu', amenu);
end

end

function createGroupMenus( amenu, v, cb )

n = cellstr(v.anno(:,1));
for i = 1:size(v,2)
    uimenu( amenu, 'label', n{i}, 'callback', cb );
end
end

function mlegend(h,e)
a = get(gca, 'userdata');
%
checked = strcmpi( get(h,'Checked'), 'on');
%
if checked
    legend( gca, 'off');
    set(h, 'Checked', 'off');
else
    grp_legend( );
    set(h,'Checked', 'on');
end
end

%% MARKERFACECOLOR (column 1 of attr matrix)
function h = fillgrp(hObject, eventdata)
checked = strcmpi( get(hObject,'Checked'), 'on');
a = get(gca, 'userdata');
if checked % turn it off - no more fill groups
    % clear all checks
    set( a{4}.h, 'markerfacecolor', 'none'); % update plot appearance
    clearAttr( hObject, 1,a  );  % update menus and data
else % turn it on
    pos = get(hObject,'pos');
    grp_themes( pos, 'facecolor',[], 'add');
    setRadioCheck( hObject );  % update menus and data
end
end


%% marker (column 2 of attr matrix)
function h = markergrp(hObject, eventdata)
checked = strcmpi( get(hObject,'Checked'), 'on');
a = get(gca, 'userdata');
if checked % turn it off - no more fill groups
    % clear all checks
    set( a{4}.h, 'marker', '.');
    clearAttr( hObject, 2,a  );  % update menus and data
else % turn it on
    pos = get(hObject,'pos');
    grp_themes( pos, 'marker',[], 'add');
    setRadioCheck( hObject );  % update menus and data
end
end

%% LINESTYLE (column 3 of attr matrix)
function h = linestylegrp(hObject, eventdata)

a = get(gca, 'userdata');
checked = strcmpi( get(hObject,'Checked'), 'on');
if checked % turn it off - no more fill groups
    % clear all checks
    set( a{4}.h, 'linestyle', 'none');
    clearAttr( hObject, 3,a  );  % update menus and data
else % turn it on
    pos = get(hObject,'pos');
    grp_themes(pos, 'linestyle',[], 'add' );
    setRadioCheck( hObject );  % update menus and data
end
end

%% LINECOLOR (column 4 of attr matrix)
function h = linecolorgrp(hObject, eventdata)

a = get(gca, 'userdata');
checked = strcmpi( get(hObject,'Checked'), 'on');
if checked % turn it off - no more fill groups
    % clear all checks
    set( a{4}.h, 'color', 'b');
    clearAttr( hObject, 4,a  );  % update menus and data
else % turn it on
    pos = get(hObject,'pos');
    grp_themes( pos, 'linecolor',[], 'add' );
    setRadioCheck( hObject );  % update menus and data
end
end

%% SIZE (column 5 of attr matrix)
function h = sizegrp(hObject, eventdata)
a = get(gca, 'userdata');
checked = strcmpi( get(hObject,'Checked'), 'on');
if checked % turn it off - no more fill groups
    % clear all checks
    set( a{4}.h, 'markersize', 5);
    clearAttr( hObject, 5,a  );  % update menus and data
else % turn it on
    pos = get(hObject,'pos');
    grp_themes( pos, 'size', [], 'add' );
    setRadioCheck( hObject );  % update menus and data
end
end

function attr = clearAttr(hObject, attri, a)
attr = a{4}.attr;  % get attribute matrix
attr( :, attri) = 0;  % set column to 0 (turn off) for the ith attribute
a{4}.attr = attr;    % set attribute matrix
set(gca,'userdata', a ); % save matrix
clearSibChecks( hObject ); % update interface
end

function setAttr(hObject,attri, a, vari)
attr = clearAttr(hObject,attri, a);  % clears this attribute from all variables and updates menus
attr( vari, attri ) = 1;                  % add this attribute
a{4}.attr = attr;
set(gca,'userdata', a );
set(hObject,'Checked', 'on');
end

function clearSibChecks(hObject)
h = findobj( get(hObject, 'parent') );
set(h,'Checked', 'off');
end

function setRadioCheck( hObject )
% RadioCheck is a checkmark than can only be on for one button in the group
clearSibChecks(hObject);
set(hObject,'Checked', 'on');
end




