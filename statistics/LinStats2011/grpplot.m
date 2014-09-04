function [h u] = grpplot( x, y, varargin)
% [h u ] = grpplot( x, y, varargin)
% plots x,y in sets or points that are defined by unique combinations of
% factor levels specified by varargin.
%
% The points on the group can be selected as a group and their attributes
% changed with the context menu. Another context menu is available to
% change which attributes are associated with a particular variable.  The
% options are ''markerfacecolor', 'marker', 'linestyle', 'linecolor',
% 'size'. 
% 
% usage
%     [h u] = grpplot( x, y, factor1, factor2, .... );
%     [h u] = grpplot( x, y, Vars(...) ); % also takes Vars object as
%     input, which is useful to specify the order of factor levels.
% h is a vector of handles to points that share unique factor levels
% u is a cell array of cellstr. the ith element contains a vector of levels for the ith factor
% thus the unique combination of factor levels for h(i) is u{1}(i),
% u{2}(i), ... u{n}(i).
%
% Example
%          load carbig MPG Acceleration Weight Displacement
%          X = [MPG Acceleration Weight Displacement];
%          i = ~any(isnan(X),2);  %find present values
%          X = zscore(X(i,:));
%          [coeff, score, latent] = princomp( X );
%          cylinders = Cylinders(i,:);
%          origin    = Origin(i,:);
%          [h u] = grpplot( score(:,1), score(:,2), cylinders, origin );
%          grp_themes( 'cylinders', 'color', [], 'size', unique(cylinders) ); % associate
%          % color and marker with cylinders
%          grp_themes( 2, 'marker',  [] ); % associate origin (referred to by position in optional inputlist to grpplot) with size
%          legh  = grp_legend( );
%          set(gca, 'pos', [ 0.13         0.11        0.775        0.815]);
%          set(legh,'location', 'northeastoutside');

% Copyright 2011 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
%
newplot;
if nargin < 3
    u = [];
    h = line( x, y, 'marker', 'd', 'linestyle', 'none', 'markersize', 5 );
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

for k = 1:length(i)
    a = j==k;
    h(:,k) = line( x(a,:), y(a,:), 'marker', '.', 'linestyle', 'none' );
end

grps.h = h;
grps.x = Vars( u{:}, 'anno', names );
p  = size(grps.x,2);
% attr matrix has the a row for each variable in x and has columns for
% entries in the matrix are 1 or zero (for on and off, respectively).
% A column can contain at most a  single 1.
%% 'markerfacecolor', 'marker', 'linestyle', 'linecolor', 'size'

if p >= 2
    grps.attr =  [1 0 0 1 0;
                       0 1 0 0 0;
                       zeros(p-2,5) ];
else
    grps.attr = [1 1 0 1 1; zeros(p-1,5)];
end

grps.attr_def = { colorfulcube(p) ,
    'osdv^<>ph',
    {'-', '-.', ':', '--'},
    .5*colorfulcube(p) };

userdata = { 'gscatter', x, y, grps };
set(gca, 'userdata', userdata );

createAttributeMenus(gca, grps.x);

if p >= 2
    grp_themes( 1, 'facecolor', [], 'linecolor', [] );
    grp_themes( 2, 'marker',[]);
else
    grp_themes( 1, 'facecolor', [], 'linecolor', [], 'marker', [], 'size', 5 );
end

end

