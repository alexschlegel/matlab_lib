classdef Lstats
    %Lstats Linear Statistics y = Xb + e
    % n responses, q parameters (and q(i) parameters for ith factor)
    % Example
    %   load weather_sorted;
    %   s = Lstats( y, g1 );

% Copyright 2011 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
%    
    properties
        %TODO get rid of variables that aren't necessary (minimalize)
        dft;        % nobs - 1;
        dfr;        % rank(X) - 1;
        dfe;        % n - dfr - 1;
        sse;
        sst;
        ssr;
        
%         Q;          % from QR of X;
%         R;          % from QR of X;
        beta;       % q x n
        
        W;          % design matrix
        y;          % response vector(s);
        
        s2;         % 1 x k+1, the last element is the mse
        covb;       % asymptotic covariance matrix of beta
        se;
        
        version = 1.0;
    end
    
    properties (Dependent = true, SetAccess = private)
        % V;        % Variance matrix y ~ N(Xb,V);
        X;          % design matrix for fixed effects
        b;          % BLUE estimates for fixed effects
        r;          % residuals
        yhat;
    end
    
    methods
        function a = Lstats( y,varargin )
            % Lstats(Model);
            % Lstats(y, Dmat );
            % Lstats(y, X );
            if isa(y,'Model')
                [X y] = y.getAnalysisSet;
            elseif isa(varargin{1}, 'Dmat')
                X = varargin{1};
            else
                % make sure input arguments are in the right order
                if isa(y,'Dmat')
                    error('y = Xb, first argument is a response variable');
                end
                % Construct a Dmat object 
                V = varargin{1};  % Dmat(y,[])  constructs intercept only model
                if isempty(V)
                    X = Dmat( y, 'model', [] );
                else  % otherwise use all input arguments as Vars
                    if ~isa( V, 'Vars')
                        V = Vars( varargin{:} );
                    end
                    X = Dmat(V);
                end
            end
            
            if isempty(X)
                error('no model to fit');
            end
            if isempty(y);
                error('no response variable has been set');
            end
            a.W = X;
            a.y = y;
            a = solve( a );
        end
        function a = solve( a )
            % Solve a linear system of equations using a variety of methods
            % to ensure accurate results under a broad range of conditions.
            % Not usually called directly. 
            X = double(a.X);
            y = double(a.y);
            
            % if all y have large magnitude 
            % subtracting mean from response improves numerical
            % reliability of anova.
            % Only do this if the model has an intercept and not multiple
            % responses (performance issues)
            % hi - model has intercept
            hi = a.X.hasIntercept;
            u  = 0; % whether mean has been subtracted
            if hi 
                u0 = 0;
                if size(a.y,2) == 1
                    [rn mn mx] = range(y); %#ok<*ASGLU>
                    digs_r = floor(lre( mx, mn));  % leading constant digits
                    % look for truncation error
                    % this is when two numbers of equal magnitude
                    % are subtracted with a relatively small number remaining
                    % The remaining number has litte precision
                    % that has little precision left
                    %
                    % check whether this applies by testing the range
                    % of y. If the range is small compared to the mean
                    digs = floor(-log10(eps(class(y)))) - digs_r;
                    sig_cut = 10;  % Selected to pass all StRD tests
                    if any(digs < sig_cut)
                        u0 = quantize(mn,digs_r);
                        y = bsxfun(@minus, y, u0);
                        y = quantize(y, digs );
                        warning('Lstats:RemovingLeadingConstants', 'removing %d leading constant digits. residual good to %d digits\n', digs_r, digs);
                    end
                end
            
                % subtract mean
                u = mean(y);
                y = bsxfun(@minus,y,u);
                
                % one round of refinement (helpful for sst in SmLs07)
                u1 = mean(y);
                y = bsxfun(@minus,y,u1);
                u = u+u1+u0;
            end
            
            [nrows ncols] = size(X);
            
            if nrows < ncols
                error('Linstats:Lstats:RowDeficient', 'there are fewer observations than parameters');
            end
            
            % solve for b.
            %for filip qr is better than linsolve . svd is slightly better
            %overall (fewer tests with less than 10 digits accurate precision.
            [U S V] = svd(X,0);
            
            % rank based on svd.
            d = diag(S);
            q = sum( d > eps(d(1)));

            if ( q < ncols )
                warning('linstats:solve:SingularMatrix', ...
                    'singular matrix to working precision. Some parameters are not estimable');
            end;
            
            a.dft  = size(y,1)-hi;
            a.dfr  = q-hi;              % regression degrees of freedom
            a.dfe  = a.dft - a.dfr;    % error degrees of freedom

            Si = zeros(size(d));
            Si(1:q) = 1./d(1:q);
            Si = diag(Si);
            
            Vs = V*Si;
            yr = U'*y;   % reduced form of y by multiple eqn by U'
            b  = Vs*yr;
            yhat = X*b; 
            r = y - yhat;
            
            b1 = Vs*U'*r;
            b = b + b1;
            r = y - X*b;
            
            a.sst  = sum(y.^2);
            a.ssr  = sum(yr.^2); 
            a.ssr = min(a.sst, a.ssr);
            a.sse  = min(a.sst-a.ssr, sum(r.^2));
%             a.sse  = sum(r.^2);  % this is better in Pontius, Wampler1
            %             than sst - ssr;, but can't be used with fast qr
            %             method

            a.s2 = a.sse./a.dfe;
            
            %                [a.covb R] = linsolve(X'*X, eye(size(X,2)), struct('SYM', true ));
            %                 Ri = pinv(R, eps(min(diag(R))));
            
            a.covb = Vs*Vs';
            a.se  = sqrt(diag(a.covb)*a.s2);
            
            % add back the grand mean that was subtracted above
            b(1,:) = b(1,:) + u;
            
            a.beta = Pmat(b,a.X.q,[], a.X.cnames );
            if size(b,2) == 1
                a.beta.cnames = {'bhat'};
            end
            
        end
        function P = estimates( a, varargin )
            % parameter estimates for fixed effects.
            % For fixed effects categorical variables there is one less
            % parameter in the model than there are levels. The fixed effect parameters in mixed models
            % are best linear unbiased estimators and fixed models are least-squares estimates
            P = test( a, varargin{:} );
        end
        function P = expanded( a, varargin )
            % expanded parameter estimates
            % Shows estimates for all levels of categorical variables
            L = full(a.X.emat);
            P = test( a, L, varargin{:} );
            P.rnames = L.rnames;
            P.p = L.p;
        end
        function [y pi] = predict( a, X, varargin )
             % X is a Design matrix compatible with the Model.
            % if X is not provided 'predictions' are made on the
            % analysis set
            args = ArgParser(varargin{:});
            alpha = args.value('alpha', .05 );
            if nargin < 2
                X = a.W;
            end
            
            y = X*a.beta;
            
            if nargout > 1
%                 alpha = 0.05; % add parameter options P.Results.alpha;
                mse   = a.s2(end);
                vpred = (sum(X*(a.covb).*X, 2) + 1)*mse;
                spred = sqrt(vpred);
                pi    = spred*tinv( 1-alpha/2, a.dfe);
            end
            
        end
        function P = contrast( ls, term, L, varargin )
            % constrast (compare) parameter estimates of a given term.
            % Usage:
            %   P = contrast( ls, term, L )
            %   term is a scalar or vector refering to terms in the model
            %   if L is provided the columns refers to the expanded parameters for the terms being tested.
            %   each row of L will be a separate test.
            %   
            
            if nargin < 2 || isempty(term)
                % the first fixed term is usually the intercept.
                % default to using the next term if it is present
                f = find( ls.X.fi);
                term = f(min(2,length(f)));
            end;
            
            if ~all( ls.X.fi( term) )
                error( 'MStats:lscontrast:InvalidTerm', 'term must refer to a fixed term');
            end
            
            F = full(ls.X.emat);
            %             q = F.p(term);
            if  nargin < 3 || isempty(L)
                L = getContrastMatrix(ls,term);
            else
                if isscalar(L)
                    L = getContrastMatrix(ls,term,L);
                else
                    if islogical(L)
                        L = L+0;
                    end
                    rn = F.rnames( row2ind(F,term));
                    cn = coeff2eqn( L, rn, 1, 0 );
                    cn = regexprep( cn, '^-(\S+) \+ (\S+$)', '$2 - $1'); % change -x + y to y - x
                    LF = Pmat( zeros( size(L,1), size(F,1)), 0, F.p, cn, F.rnames );
                    LF{:,term} = L;
                    L = LF*F;
                end
            end;
            P = test(ls,L, varargin{:});
        end
        function P = fit(a)
            % fit.  Model fit is the joint test of all parameters
            % against the null model (if intercept present) or against y=0
%             H = eye( size(a.X,2));
%             k = regexpifind( a.X.cnames, 'intercept');
%             r = htest( a, H(~k,:) );
            
            r.F = (a.ssr/a.dfr)./(a.sse./a.dfe);
            r.pval = 1 - fcdf( r.F, a.dfr, a.dfe );
            n = length(r.F);
            dfr = repmat( a.dfr, 1, n ); %#ok<*PROP>
            dfe = repmat( a.dfe, 1, n ); %#ok<PROP>
            P = Pmat( {r.F dfr dfe  r.pval}, [], [], {'Model'}, {'F', 'dfr' 'dfe', 'Prob > F'} ); %#ok<PROP>
        end
        function P = anova(a, type)
            % ANOVA tests of each fixed effect term in the model
            % supports type I and type III (default) anova.
            
            % create tests
            X = a.X;        % fixed effects
            if nargin < 2 || type == 3;
                L = Pmat( eye(size(X,2)), X.q, X.q, [], []);
            else  % type = 1
                [~, U] = lu( X'*X );
                L = Pmat( U, X.q, X.q, [], []);
            end
            
            n = size(a.y,2);
            q = psize(X,2);
            
            F = zeros(q,n);
            pval = nan( q, n );
            dfe = nan(q,n);
            dfr = nan(q,n);
            for i = 1:q
                result = htest( a, L{i,:} );
                F(i,:) = result.F;
                pval(i,:) = result.pval;
                dfr(i,:) = result.dfr;
                dfe(i,:) = result.dfe;
            end
            P = Pmat( {F dfr dfe pval}, [], [], a.W.X.tnames, {'F', 'dfr' 'dfe', 'Prob > F'} );
        end
        function B = test(a, varargin)
            %test - univariate test of parameters
            % a = test( a, L, 'u', 0, 'alpha', .05, 'tail', 'both');
            %   L, each row of L specifies a combination of beta to test,
            %   i.e. L*beta, (default is to I). 
            %   'alpha', alpha  values for ci (default, .05);
            %   'tail', -1,0,1 for left, both, right tail (default 0)
            
            
            args = ArgParser(a, varargin{:});
            alpha = value( args, 'alpha', .05, @isscalar);
            tail  = value( args, 'tail', 0, @isscalar);
            L = value( args, 2, [], @(x) isa(x,'double') );
            
            a.s2 = a.sse./a.dfe;
            a.dfr = 1; % degrees of freedom for the test matrix (univariate)

            if isempty(L)
                L = eye(size(a.X,2));   % default is to test each parameter separately
                p = a.X.q;              % default is partitioned like design matrix
                rn = a.X.cnames;        % default is name of each parameter
            elseif isscalar(L)
                rn = a.X.cnames(L);
                p = a.X.q(L);
                L = ind2logical( L, size(a.beta,1))';
            elseif  isa( L, 'Pmat' )
                rn = L.rnames;
                p = L.p;
                L = double(L);
            else
                rn = [];                % unnamed contrasts
                p = 0;                  % unpartitioned
            end
            
            if size(L,2) ~= size(a.beta,1)
                error('Contrast matrix L must have one column for each fow of beta' );
            end
            
            b = double(a.beta);     % b is the original parametr estimates
            b = squeeze(permute(b,[1 3 2] ) );
            a.beta = L*b;           % a.beta is the new linear combination of estimates
            if ~isempty(L)
                % build linear combinations of coefficients
                % that will give the desired ls contrasts for each level
                a.covb = L*a.covb*L';
            end
            a.se  = sqrt(diag(a.covb)*a.s2);
            t   = a.beta./a.se;
            % Student T confidence intervals
            if tail == 0
                tcrit = tinv( 1 - alpha/2, a.dfe );
                pval = 2*tcdf( -abs(t), a.dfe );
            elseif tail > 0  % right sided
                tcrit = tinv( 1 - alpha, a.dfe );
                pval = tcdf( -t, a.dfe );
            elseif tail < 0   % left sided
                tcrit = tinv( 1 - alpha, a.dfe );
                pval = tcdf( t, a.dfe );
            end
            
            ci = tcrit.*a.se;
            c = horzcat( permute(a.beta, [1 3 2]), ...
                permute(a.se, [1 3 2]), ...
                permute(ci, [1 3 2]), ...
                permute(t, [1 3 2]), ...
                permute(pval, [1 3 2]));
            
            if tail < 0
                str = 'Prob < t';
            elseif tail > 0
                str = 'Prob > t';
            else
                str = 'Prob > |t|';
            end
            str_ci = sprintf( 'ci (%.2f%%)', 100*(1-alpha) );
            
            B = Pmat(c, p, 0, rn,  {'bhat' 'se' str_ci 't' str}) ;
            
        end
        function stats = htest( a, H )
            b  = double(a.beta{ a.W.fi,:}); % convert to double
            %             b = squeeze(permute( b, [1 3 2])); % reshape so that beta is 2d
            v = size(H,1);
            m = a.dfe;
            mse = a.sse./a.dfe;
            
%             This seems preferable to the long method below, but I have not yet tested models with multiple
%             factors. The problem stems from not accounting for the fact
%             that if a model without the other factors would have a
%             different parameter estimate
%             L = H*a.yr;         % yhat for selected linear combination, H
%             L = sum(L.*L);      % SSR;
%             ms = L./v;          % Mean squares
%             F = ms./mse;        % F;
            % the following seems a slower and less stable way of
            % procedding, but I have not yet tested models with multiple
            % factors. three way anova did not work as intended. so the
            % above approach, if viable, needs to be altered.
            Q = H*a.covb*H';
            if rank(Q)< size(Q,2)
                [U S V] = svd(Q);
                d = diag(S);
                Si = diag(1./d);
                L = V*Si*U';
            else
                L = linsolve(Q, eye(size(H,1)), struct('SYM', true, 'POSDEF', true ));
            end
            q = (H*b);
            F = sum(q'*L.*q',2)./v;
            F = F'./mse;
            
            stats.F = F;
            stats.dfr = v;
            stats.dfe = m;
            stats.pval = 1 - fcdf( F, v, m );
        end
        function P  = varcomp(a)
            vn =  {'residual'};
            s2     = a.s2;
            C = chol( a.covb*s2, 'lower');
            Xs = a.X*C;
            XsLL = Xs'/s2;
            n = a.dft+1;
            H = Mstats.d2LdV( eye(n)/s2, XsLL, {eye(n)}, a.r );
            Io = H/2;
            Iinv = 1./Io;
            se = sqrt( Iinv );
            ncrit = norminv(.975);
            lo = s2 - se.*ncrit;
            hi = s2 + se.*ncrit;
            P   = Pmat( [ s2 se lo hi], 0,0, vn, {'Var', 'Std Error', '95% Lower', '95% Upper' }  );
        end
        function display(a)
            disp(a);
        end;
        function b = Pmat( a,i,j, cn )
            if nargin < 2 || isempty(i)
                i = 1:psize(a.beta,1);
            end
            if nargin < 3 || isempty(j)
                j = 1;
            end
            b = a.beta{i,:,j};
            if nargin > 3;
                b.cnames = cn;
            elseif size(a.beta,2) == 1
                b.cnames = {'bhat'};
            end
        end
        function tbl = disp(a, varargin)
            p = inputParser;
            p.parse( varargin{:});
            tbl = a.Pmat(:,1);
            disp(tbl);
        end
        function r = get.r(a)
            r = a.y - a.yhat;
        end
        function yhat = get.yhat(a)
            yhat = double(a.X*a.b);  % needs to be a.X*b + a.Z*u for mixed models...
        end
        function w = get.W(a)
            w = a.W;
        end
        function X = get.X(a) % return fixed effects design matrix
            X = a.W.X;
        end
        function b = get.b(a)
            b = a.beta{a.W.fi,:};
        end
        function v = V(a)
            % Returns Variance matrix, V{y}
            % v = diag( repmat(a.s2(end), a.dft+1, 1 ));
            v = diag( ones(a.dft+1, 1 ));
        end
        

        function [L LF] = getContrastMatrix( ls, term, method )
            %getContrastMatrix helper function to return a contrast matrix for a
            %given term
            %
            %Contrasts are used to test whether whether linear combinations of coefficient
            %sum to zero. Each row of L would be a separate test
            %
            %Example
            %   L = getContrastMatrix( a, t, method )
            %       t is a scalar for the term to contrast. It is used ot
            %       get the number of parameters, p.
            %       method is a scalar indicating which type of contrast to build
            %       1 = all pairwise (default)
            %           compares each combinations of pairs of levels
            %       2 = adjacent pairs  compare each level i+1 - i
            %       3 = baseline        compare each level i to level 1
            %       4 = paired pairs    compare i+1 - i, where i = 1:2:end
            % returns L, a set of contrasts for the given term.
            %
            F = ls.X.Le;
            p = F.p(term);
            if p==1
                L = 1;
                return
            end
            if (nargin < 3 || method == 1)
                method = 1;
                t = nchoosek( 1:p, 2 );
            elseif method == 2 || method == 4
                t = zeros(p-1,2);
                t(:,1) = 1:p-1;
                t(:,2) = t(:,1) + 1;
            elseif method == 3
                t = zeros(p-1,2);
                t(:,1) = 1;
                t(:,2) = 2:p;
            end
            
            m = size(t,1);
            L = zeros( p, m);
            i = sub2ind( size(L),  t, [(1:m)' (1:m)'] );
            L(i(:,1)) = -1;
            L(i(:,2)) = 1;
            
            if method == 4;
                L(:,2:2:end) = [];
            end
            
            rn = F.rnames( row2ind(F,term));
            cn = coeff2eqn( L', rn );
            cn = regexprep( cn, '^-(\S+) \+ (\S+$)', '$2 - $1'); % change -x + y to y - x
            
            LF = Pmat( zeros( size(L,2), size(F,1)), 0, F.p, cn, F.rnames );
            LF(:,term) = L';
            L = LF*F;
        end
    end
end