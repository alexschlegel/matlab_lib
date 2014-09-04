function [h u] = grperrorbar( x, y, ci, varargin)
%
% 
% [h u ] = grpplot( x, y, varargin)
% h is a vector of handles to all points of smallest group
% u is a matrix of how the handles are grouped. There are k columns, one
% for each factor. use each column in a call to line_themes to set the
% properties for each level of that fator
% varargin may also be a Vars object

% Copyright 2011 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
%
newplot;
if nargin < 4
    u = [];
    h = errorbar(x,y,ci, 'o','markerfacecolor', 'g');
    return;
end

names = cell(length(varargin),1);
for i = 1:length(names);
    nm = inputname(2+i);
    if isempty(nm)
        nm = sprintf( 'x%d', i');
    end
    names{i} = nm;
end
if isa(varargin{1}, 'Vars')
    v = varargin{1};
    ai = v.x;
    an = getLevelNames(v);
    names = cellstr( v.anno(:,1));
else
    [ai an] = grp2ind( varargin{:} );
end

[u i j] = unique(ai,'rows');
if size(ai,1) ~= size(x,1)
    error('linstats:grpplot:IncompatibleSize', 'grouping variables are not the same size as the x');
end
if size(ai,2) == 1
    an = {an};
end

u = ind2grp( u, an{:} );

if size(x,1) ~= size(y,1)
    error( 'linstats:grpplot:InvalidArguments', 'Vectors must be the same lengths');
end


% this isn't quite right. Staggering the error bars along the x-axis 
% must take into account the number of groups at each point along the
% x-axis. Otherwise, as in the case of immune_cell_profile, there may be 10
% groups, but only one group per point on the x-axis
% set stagger true if there are multiple points for a given x will be displayed in 
% different groups. 
% use jitter(...'stagger', 'grp');
xstagger = crosstab( x, j );
stagger = any( sum(xstagger, 2) > 1 );
stagger = false;

hold on;
b = (length(i)-1)/2;
bmp = (-b:b)*(.07*b);

for k = 1:length(i)
    if stagger 
        h(:,k) = errorbar( x(j==k,:)+bmp(k), y(j==k,:), ci(j==k,:), 'marker', '.' );
    else
        h(:,k) = errorbar( x(j==k,:), y(j==k,:), ci(j==k,:), 'marker', '.' );
    end
end

%%

grps.h = h;
grps.x = Vars( u{:} );
p  = size(grps.x,2);
% attr matrix has the a row for each variable in x and has columns for
% entries in the matrix are 1 or zero (for on and off, respectively).
% A column can contain at most a  single 1.
%% 'markerfacecolor', 'shape', 'linestyle', 'linecolor', 'size'

if p >= 2
    grps.attr =  [1 0 0 1 0;
                       0 1 0 0 0;
                       zeros(5-p,5) ];
else
    grps.attr = [ones(1,5); zeros(p-1,5)];
end

grps.attr_def = { colorfulcube(p) ,
    'osdv^<>ph',
    {'-', '-.', ':', '--'},
    .5*colorfulcube(p) };

userdata = { 'gscatter', x, y, grps };
set(gca, 'userdata', userdata );

createAttributeMenus(gca, grps.x)


