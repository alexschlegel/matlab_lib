function leg_h = grp_legend(h,u,attr)
%ax = grp_legend creates a legend for plot created with grpplot
%


% Copyright 2011 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
%

% attr is a matrix of 1s and 0s that indicates which variables are
% associated with which attributes. 
%% 'markerfacecolor', 'shape', 'linestyle', 'linecolor', 'size'

% extract data from userdata stored by grpplot;
if nargin == 0
    ud = get(gca,'userdata');
    grp = ud{4};
    h = grp.h;
    ln = getLevelNames(grp.x, true(1,size(grp.x,2)) );
    u =    ind2grp( grp.x.x, ln{:})';
    attr = grp.attr;
elseif nargin < 3
    q = length(u);
    attr = blkdiag( eye(q), zeros(5-q));
end

%% number of elements in legend
p = zeros(3,1);
for i = 1:length(u);
    p(i) = length(unique(u{i}));
end;

ap = ArgParser;
% default attribute structure for properties of the group that aren't
% mirrored
attrss.markerfacecolor = [0 0 1];
attrss.color = [ 0 0 .5];
attrss.linestyle = 'none';
attrss.marker  = 'o' ;
attrss.size  = 5 ;

mfc = cell2mat(get( h, 'markerfacecolor' ));
msh = get( h, 'marker' );
ls  = get( h, 'linestyle' );
lc  = cell2mat(get( h, 'color' ));
msz = cell2mat(get( h, 'markersize' ));

n =length(u);
grp_h = cell(n,1);
leg_text = cell(n,1);
hlink =cell(n,1);
% loop through each variable 
for vari = 1:length(u)
    
    % av is a vector indicating which attributes of the group should be
    % mimicked in the legend
    av = attr(vari,:);
    [un uloc] = unique( u{vari} );
    p = length(un);
    
%     loop through each member of the group and collect each of the desired
    ph = zeros(p,1);
    hl = {};
    for i = 1:p
        %     attributes into a structure.
        proplist = {'markerfacecolor', 'marker', 'linestyle', 'color', 'markersize'}; 
        attrs = attrss;  % default structure
        k = uloc(i);
        if av(1)
            attrs.markerfacecolor = mfc(k,:);
        end
        if av(2)  % mirror marker shape
            attrs.marker = msh{k};
        else % 
            if av(1) || av(4) % if we are using colors make a square 
                attrs.marker = 's';
            elseif av(5) % if we are using size make a circle
                attrs.marker = 'o';
            end
        end
        if av(3)
            attrs.linestyle = ls{k};
        elseif av(2)  % if we are no tracking linestyles but are tracking shape use '-'
            attrs.linestyle = '-';
        end
        if av(4)
            attrs.color = lc(k,:);
        elseif av(1) % not tracking line color but are tracking facecolor
            attrs.color = mfc(k,:); % mirror facecolor
        end
        if av(5)
            attrs.size = msz(k);
        end

         ph(i)  = line( 0, 0, 'marker', attrs.marker, ...
                                    'markerfacecolor',  attrs.markerfacecolor, ...
                                    'color', attrs.color, ...
                                    'linestyle', attrs.linestyle, ....
                                    'markersize', attrs.size );
          hl{i} = linkprop(  [ph(i), h(k)],proplist(logical(av)) );
    end
    grp_h{vari} = ph;
    leg_text{vari} = un;
    hlink{vari} = cat(1,hl{:});
end
hlink = cat(1,hlink{:});
s = get(gca,'userdata');
grp = s{4};
if isfield(grp, 'hlink');
    try
        delete(grp.hlink);
    catch
    end;
end
grp.hlink = hlink;
s{4} = grp;
set(gca,'userdata', s);

%% create legend
grp_h = cat(1,grp_h{:});
leg_text = cat(1,leg_text{:});
leg_h = legend( grp_h, leg_text,'interpreter', get(0,'defaulttextinterpreter')  );
set( grp_h, 'visible', 'off');


