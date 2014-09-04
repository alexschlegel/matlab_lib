function [ph lh] = grp_themes(varname,varargin)
%grp_themes adds visual distinction to levels within groups of points, used
%with grpplot
%
%
%usage:
% grp_themes is called with name-value pairs for 5 different plot
% attributes: marker, linestyle, facecolor, linecolor and markersize. 
% If an attribute is specified, the value determines
% the attributes for each group. if there are fewer values than groups the
% attributes get reused (starting from 1).  If the value is empty, then a
% default list of values gets used. Each call to grp_themes replaces
% existing attributes. For example, if levels of a group were distinguished
% by color and grp_themes is called specifying marker, then the levels will
% no longer be distinguished based on color
% 
%[ph lh] = grp_themes(v, 'property', 'propertylist', 'property2', 'plist2', ... )
%
% If a property is specified the appearance of plotted points associated with grp will be
% updated
%  property (if listed and propertylist is empty)
%   'marker',     % defaults to 'osdv^<>ph'
%   'linestyle',    % defaults to {'-', '-.', ':', '--'}
%   'facecolor',   % defaults to colorfulcube(p), where p is number of
%   groups in g
%   'linecolor',     % defaults to .5*facecolor
%   'markersize', % 3:3:3*p, where p is the number of groups
%   'color', % shortcut to set both linecolor and facecolor. Use without
%   facecolor or linecolor options
%   'others', % get ignored, might want to upgrade function to pass to set(h,...) directly
%
% If a property is not specified the appearance of plotted points associated with grp will be
% updated as follows
%  property (if listed and propertylist is empty)
%   'marker',     % defaults to '.'
%   'linestyle',   % defaults to 'none'
%   'facecolor',  % defaults to 'none'
%   'linecolor',  % defaults to  'b'
%   'size',   % defaults to 3
%
% Switches
%       'add' - The specified properties are added an existing group. Default is to replace
%
% Options - not implemented
%       'remove' 'property' -removes a theme from an existing group and
%       makes all levels of the group take on a 'null' value 
%
% Examples
%          load carbig MPG Acceleration Weight Displacement
%          X = [MPG Acceleration Weight Displacement];
%          i = ~any(isnan(X),2);  %find present values
%          X = zscore(X(i,:));
%          [coeff, score, latent] = princomp( X );
%          cylinders = Cylinders(i,:);
%          origin    = Origin(i,:);
%          [h u] = grpplot( score(:,1), score(:,2), cylinders, origin );
%          grp_themes( 'cylinders', 'color', [], 'size', [] ); % associate
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

s = get(gca,'userdata');
v = s{4};
h = v.h;
ri = col2ind(v.x, varname);
u = v.x(:,ri);
attr = v.attr;
av_cur = attr(ri,:);

gn = getLevelNames(u,1);
gj  = u.x;
p = length(gn);

ap = ArgParser(varargin{:});
addTheme = ap.isSet('add');

[facecolor e] = ap.value('facecolor' ); % find value

if e && isempty(facecolor) % if user specified [] use preselected colors
    facecolor = colorfulcube(p);  % if it is empty use default
elseif ~e
    facecolor = 'none';
end

[marker e] = ap.value( 'marker');
if e && isempty(marker)
    marker =  'osdv^<>ph'; 
elseif ~e
    marker = '.';
end

[linestyle e]  = ap.value('linestyle');
if e && isempty(linestyle)
    linestyle = {'-', '-.', ':', '--'}; 
elseif ~e
    linestyle = {'none'}; 
end;


[linecolor e] = ap.value( 'linecolor' );
if e && isempty(linecolor)
    linecolor = .5*colorfulcube(p);
elseif ~e
    linecolor = [0 0 1]; 
end

[msize e] = ap.value( 'size'  );
if e && isempty(msize)
    msize = 3:3:(3*p);
elseif ~e
    msize = 5;
    if marker == '.' 
        msize = 3;
    end
end

[color e] = ap.value( 'color');
if e 
    if isempty(color)
        facecolor = colorfulcube(p);
        linecolor = .5*colorfulcube(p);
    else
        facecolor = color;
        linecolor = .5*color;
    end
end

maxfc = size(facecolor,1);
maxm = length(marker);
if ischar(linestyle)
    linestyle = {linestyle};
end
maxls = length(linestyle);
maxlc = size(linecolor,1);
maxsz = length(msize);
av_new = [ap.isSet('facecolor')|| ap.isSet('color');
         ap.isSet('marker') ;
         ap.isSet('linestyle');
         ap.isSet('linecolor') || ap.isSet('color');
         ap.isSet('size')]';
     
% update new attributes (and use null values for any currently set)
if addTheme
    av_update = av_new;
else
    av_update = av_new | av_cur;     
end

     for i = 1:p
         hh = h(gj==i);
         if av_update(1)
             set( hh, 'markerfacecolor', facecolor( 1+mod(i-1, maxfc),:));
         end
         if av_update(2)
             set( hh, 'marker', marker( 1+mod(i-1,maxm)));
         end
         if av_update(3)
             set( hh, 'linestyle', linestyle{ 1+mod(i-1,maxls)});
         end
         
         if av_update(4)
             set( hh, 'color', linecolor( 1+mod(i-1,maxlc),:));
         end
         
         if av_update(5)
             set( hh, 'markersize', msize( 1+mod(i-1,maxsz)));
         end
     end


attr(:,av_new) = 0;  % turn off referenes to new attributes
if addTheme
    attr(ri,:) = av_new|av_cur;  % set references only for this variable
else
    attr(ri,:) = av_new;
end


v.attr = attr;
s{4} = v;
set(gca,'userdata', s );

if ~isequal(av_new, av_cur )
    legh = legend;
    loc = get(legh,'location');
    if legh
        legh = grp_legend;  %remake legend
        set(legh, 'loc', loc);
    end
end


