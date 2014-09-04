function [x e] = jitter( x, varargin )
% JITTER adds jitter to the values in x to improve display
%
% used as a visualization aid when plot is cluttered due to many similar
% values of y at a discrete points in x
%
% xp = jitter(x,range)
% x is a m x 1 vector of doubles
% range is a scalar. noise will be in the interval [0,range]
%
% [xp e] = jitter(x,range, 'stem', y, 'tol', tol)
% adds jitter based on binning y into bins with spacing equal to tol
% the resulting jitter will separate values of y that are in the same bin
% uniformly along the x axis within the given range and centered on x.
% This is usefull if both x and y are discrete
%
% [xp e] = jitter(x,range, 'stem', y, 'nbins', n)
% adds jitter based on binning y into bins with spacing equal to tol
% the resulting jitter will separate values of y that are in the same bin
% uniformly along the x axis within the given range and centered on x. If
% neither bins or tol is specified then 100 equally spaced bins are used.
% If both are present, tol is used to generate bins
%
% [xp e] = jitter(x,range, 'stagger', grp, 'bmpsz', bmpsz);
%  plots x values slightly shifted based on the grp level . The shift size
%  depends on bmpsz
%
% load carbig MPG Origin Cylinders;
% Origin = cellstr(Origin);
% k = ~isnan(MPG);
% figure('pos', [63 40 903 601])
% subplot(2,2,1)
% grpplot( Cylinders(k), MPG(k), Origin(k));
% set(gca,'xlim', [2.5 8.5] );
% xlabel('Cylinders'); ylabel( 'MPG');
% title('without jitter')
% subplot(2,2,2)
% grpplot( jitter( Cylinders(k), .5), MPG(k), Origin(k));
% title('with jitter');
% xlabel('Cylinders'); ylabel( 'MPG');
% set(gca,'xlim', [2.5 8.5] );
% subplot(2,2,3)
%grpplot( jitter(Cylinders(k), .5, 'stem', MPG(k), 'nbins', 20), ...
%             MPG(k), Origin(k) );
% title('with stem jitter');
% xlabel('Cylinders'); ylabel( 'MPG');
% set(gca,'xlim', [2.5 8.5] );
% subplot(2,2,4);
% grpplot( jitter( Cylinders(k),.5, 'stagger', Origin(k), 'bmpsz', 1), ...
%             MPG(k), Origin(k));
% title('with stagger jitter');
% xlabel('Cylinders'); ylabel( 'MPG');
% set(gca,'xlim', [2.5 8.5] );

% Copyright 2011 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
%

% Rev73: Added support for stem plots

p = inputParser;
p.addRequired( 'x', @(x) isnumeric(x) || islogical(x) );
p.addOptional( 'range', .1,  @(x) isnumeric(x) && isscalar(x));
p.addParamValue( 'stem', [], @(y) isnumeric(y) && isvector(y) && length(y)==length(x) );
p.addParamValue( 'tol', [], @(y) isnumeric(y) && isscalar(y) );
p.addParamValue( 'nbins', 100 , @(y) isnumeric(y) && isscalar(y) );
p.addParamValue( 'stagger',[] );
p.addParamValue( 'bmpsz', .07 );
p.parse( x, varargin{:} );

args = p.Results;

if ~isempty( args.stem)
    [gi gn] = grp2ind( x );
    for k = 1:length(gn)
        j = gi == k;
        y = args.stem(j);
        t = args.tol;
        [d a b] = range(y);
        if ~isempty(t)
            bins = a:t:b+t;
        else
            bins = linspace( a, b, args.nbins );
        end;

        bins = bins(:);
        %     bins(end) = Inf;

        [fx xx] = histc( y, bins );

        [m n]       = size(xx);
        [sx order]  = sort(xx);

        ties  = [ diff( sx ) == 0; zeros(1,n) ];    % boolean matrix of ties of ith feature and ith+1 feature
        if sum(ties) == 0
            continue;
        end;
        d     = [ ties(1,:); diff(ties) ];          % state of matches

        [a p] = find(d==1);             % begin match
        [b q] = find(d==-1);            % end match;
        N  = sub2ind( size(d), b, q ) - sub2ind( size(d), a, p ) + 1; % number tied

        % NOTE
        % the above section works for any number of columsn
        % the following works only for a vector
        e = zeros( size(xx,1),1);
        % scale N to the range and divide by two (1/2 on each side of the stem)
        bmpsz = 2*args.range/max(N);
        for i = 1:length(a)
            c = (N(i)-1)/2;
            bmp = (-c:c)*(bmpsz*c);
            if bmp(end) > args.range % shrink if needed
                bmp = args.range.*bmp./bmp(end);
            end
            e(a(i):b(i)) = bmp;
        end
%         e = e*args.range/(max(N)*2); % I think I moved this in the loop
        e(order) = e;
        x(j) = x(j) + e;
    end
elseif ~isempty(args.stagger);
    g = args.stagger;
    [a ignore j] = unique(g);
    bmpsz = args.bmpsz;
    b = (length(a)-1)/2;
    bmp = (-b:b)*(bmpsz*b);
    if range(bmp) > args.range
        bmp = bmp.*args.range/range(bmp);
    end
    for i = 1:length(a);
        x(j==i) = x(j==i) + bmp(i);
    end
else
    e = rand( size(args.x))*args.range - args.range/2;
    x = x + e;
end




