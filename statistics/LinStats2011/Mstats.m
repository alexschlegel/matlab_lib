classdef Mstats < Lstats
    %Mstats Linear Statistics y = Xb + Zu  + e
    % n responses, q parameters (and q(i) parameters for ith factor)
    % usage:
    %   Mstats( Model );
    %   Mstats( Dmat, y);
    % Mstats removes missing variables from Models otherwise ignores them
    % (ie. produces error messages etc)
    
% Copyright 2011 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
%
    
    properties
        covbadj;    % K&H adjusted asymptotic covariance matrix of parameter estimates
        Lambda;     % K&R F adjustement factor;
        P;          % intermediate calculation from K&H used in K&R
        Iinv;       % inverse of Information Matrix;
    end
    
    properties (Dependent = true, SetAccess = private)
        G;
        Z;
        u;          % BLUP estimates for random effects
    end
    
    methods
        function a = Mstats(varargin )
            a = a@Lstats(varargin{:});
            if isstruct(varargin{1})
                v = varargin{1};
                a.covbadj = v.covbadj;
                a.Lambda = v.Lambda;
                a.P = v.P;
                a.Io = v.Io;
                a.Iinv = v.Iinv;
            end
            
        end
        function [a output] = solve( a,varargin )
            
            W = a.W;
            if ~ismixed( W )
                me = MException('linstats:Mstats:WrongModelType', 'the model has no random terms');
                throw(me);
            end
            
            k = W.fi;
            X = a.X;
            Z = a.Z;
            y = a.y;
            if size(y,2) > 1
                error('linstats:Mstats:InvalidArgument', 'single response supported for mixed models');
            end
            a.dft = size(y,1)-1;
            % reserve space for parameter estimates and predictions
            a.beta = Pmat( nan( 1, size(W,2) ), [], W.q, {'Estimate'}, W.cnames   )';
            % estimate variance components
            [a.s2 Io output] = Mstats.varest(X,Z,y,varargin{:}); %TODO get grad and Hessian from last round (see help fminunc)
            [L p]       = chol( Io );
            failed = false; % failed to converge to viable solution
            if p ~= 0  % this means varest failed to converge on a feasible solution. try fminsearch
                s20 = zeros(size(a.s2));  % try alternate starting point?
                s20(end) = .1;
                [a.s2 Io output] = Mstats.varest(X,Z,y,s20); %TODO get grad and Hessian from last round (see help fminunc)
                
                [L p]       = chol( Io );
                if p ~= 0  % this means varest failed to converge on a feasible solution. try fminsearch
                    failed = true;
                end
            end
            a.Iinv  = L\(L'\eye(size(L))); % inv(Io)
            
            
            
            %% compute covariance matrix for estimates
            V = a.V;
            %             [R ~]   = chol(V);     % R'*R = v;
            %             XL   = X'/R;
            A    = X'*(V\X);  % = XL*XL';    % X'*inv(V)*X;
            covb   =pinv(A); % =  XL'\(XL\eye(size(XL,1))); % inv(A);  % TODO: was available in reml
            a.covb = covb;          % uncorrected covariance of estimates
            %% BLUE Estimates
            % For balanced data estimates of XB for OLSE, GLSE, MLE, and BLUE
            % are the same. To get a unique estimate of B, X needs to be full
            % rank.
            b    = covb*X'*(V\y); % = ((covb*XL)/R')*y;  %covb*X'*inv(V)*y
            e    = y -X*b;      % residuals after fitting fixed effects
            % save results
            a.beta{ k,: } = b;
            
            %% (BLUP) Predictions
            % The only dependence of BLUP on the fixed effects is in the estimate of
            % XB, which is the same regradless of whether there is a unique solution to B)
            u    = a.G*Z'*(V\e); % = a.G*(Z'/R)/R'*e;  % a.G*Z'*inv(V)*e;
            a.beta{~k,:} = u;
            
            if failed
                warning( 'linstats:Mstats:OptimizationFailed', 'fminunc failed. All further calculations based on Hessian will give errors');
                return;
            end
            
            %% compute corrections
            a = a.kackar_harville;
            
            %% SE for fixed effects update this
            %           a.se(k) = sqrt( diag( a.covb )); % this is tested to be equal
            %
        end;
        function P = test(a, varargin)
            %test - univariate test of parameters
            % a = lstest( a, L, 'u', 0, 'alpha', .05, 'tail', 'both');
            %   L, each row of L specifies a combination of beta to test,
            %   i.e. L*beta, (default is to I). Each
            %   'alpha', alpha  values for ci (default, .05);
            %   'tail', -1,0,1 for left, both, right tail (default 0)
            %   'u' a constant vector to test (L*beta - u);
            
            
            args = inputParser;
            
            args.addOptional( 'L', [], @(x) isa(x,'double') );
            args.addParamValue( 'alpha', .05, @isscalar);
            args.addParamValue( 'tail', 0, @isscalar);
            args.addParamValue( 'adj', [] );
            args.parse(varargin{:});
            
            L = args.Results.L;
            tail = args.Results.tail;
            alpha = args.Results.alpha;
            
            sse = a.sse;
            a.s2 = sse./a.dfe;
            a.dfr = 1; % degrees of freedom for the test matrix (univariate)
            p = [];   rn = []; % partitioning and names of results default to nulll
            if nargin < 2 || isempty(L)
                L = Pmat( eye( size(a.X,2)), a.X.q, 0, a.X.cnames, []);
                p = L.p;
                rn = L.rnames;
            elseif isscalar(L)
                L = Pmat( ind2logical( L, size(a.beta,1))', a.X.q(L), 0, a.X.cnames(L) );
                rn = L.rnames;
                p = L.p;
            end
            
            q = size(L,1);
            R = zeros(q,3);
            Ld = double(L);
            for i = 1:size(Ld,1)
                result = a.htest( Ld(i,:) );
                R(i,:) = [result.F result.dfe result.pval ];
            end
            
            b = double(a.beta{a.W.fi,:});
            b = squeeze(permute(b,[1 3 2]));
            b = L*b;

            se = sqrt(diag(Ld*a.covbadj*Ld'));            
            t   = b./se;
            % Student T confidence intervals
            dfe = R(:,2);
            if tail == 0
                tcrit = tinv( 1 - alpha/2, dfe );
                pval = 2*tcdf( -abs(t), dfe );
            elseif tail > 0  % right sided
                tcrit = tinv( 1 - alpha, dfe );
                pval = tcdf( -t, dfe );
            elseif tail < 0   % left sided
                tcrit = tinv( 1 - alpha, dfe );
                pval = tcdf( t, dfe );
            end
            
            ci = tcrit.*se;

            if tail < 0
                str = 'Prob < t';
            elseif tail > 0
                str = 'Prob > t';
            else
                str = 'Prob > |t|';
            end
            str_ci = sprintf( 'ci (%.2f%%)', 100*(1-alpha) );
            
            cn  = {'estimate' 'se' str_ci 't' 'df', str};
            P = Pmat( [double(b) se ci t dfe, pval],p, 0,rn, cn );            
            
        end
        function P = test_old(a, L, varargin)
            %lstest tests sets of individual linear combination of fixed parameters
            %options
            %usage:
            %    lstest( a ) or a.lstest % tests all fixed effects parameters
            %    lstest( a, L); % or a.lstest(L) % v tests of the v x p matrix, L
            %    lstest( a, l); % or a.lstest(l) % single test of the lth parameter
            
            a.dfr = 1; % degrees of freedom for the test matrix (univariate)
            p = [];   rn = []; % partitioning and names of results default to nulll
            if nargin < 2 || isempty(L)
                L = Pmat( eye( size(a.X,2)),0, 0, a.X.cnames, []);
                p = a.X.q;
                rn = L.rnames;
            elseif isscalar(L)
                L = Pmat( ind2logical( L, size(a.beta,1))', 0, 0, a.X.cnames(L) );
                rn = L.rnames;
                p = a.X.q(L);
            elseif isa(L,'Pmat');
                rn = L.rnames;
            end
            
            b = double(a.beta{a.W.fi,:});
            b = squeeze(permute(b,[1 3 2]));
            b = L*b;
            
            q = size(L,1);
            R = zeros(q,3);
            Ld = double(L);
            for i = 1:size(Ld,1)
                result = a.htest( Ld(i,:) );
                R(i,:) = [result.F result.dfe result.pval ];
            end
            se = sqrt(diag(Ld*a.covbadj*Ld'));
            P = Pmat( [double(b) se R],p, 0,rn, {'Estimate' 'se' 'F', 'df', 'prob>F'} );
        end
        function P = fit(a)
            % fit.  Model fit is the joint test of all parameters
            % (excluding intercept if present)
            H = eye( size(a.X,2));
            k = regexpifind( a.X.cnames, 'intercept');
            r = htest( a, H(~k,:) );
            n = length(r.F);
            dfr = repmat( r.dfr, 1, n ); %#ok<*PROP>
            dfe = repmat( r.dfe, 1, n ); %#ok<PROP>
            P = Pmat( {r.F dfr dfe  r.pval}, [], [], {'Model'}, {'F', 'dfr' 'dfe', 'Prob > F'} ); %#ok<PROP>
        end
        function stats = htest(ls, H)
            % HTEST hypothesis test of fixed efffects parameters
            % uses kenward_rogers correction for small sample size
            b  = ls.beta{ls.W.fi};
            v = size(H,1);
            A1 = 0;
            A2 = 0;
            
            phi = ls.covb;
            Q = H*phi*H';
            [L p] = chol(Q);
            if p==0
                theta = H'*(L\(L'\eye(size(L,1)) ))*H;
            else
                warning('linstats:Mstats:NonPositiveHMatrix', 'Q is non-positive, using pseudo inverse - MJB does not know if this is reasonable');
                theta = svdinv(Q);
            end
            tp = theta*phi;
            
            P = ls.P;
            r = length(P);
            TPP = cell(r,1);
            for i = 1:r
                TPP{i} = tp*P{i}*phi;
            end
            
            W = ls.Iinv;
            for i = 1:r
                for j = 1:r
                    A1 = A1 + W(i,j)*trace( TPP{i})*trace( TPP{j} );
                    A2 = A2 + W(i,j)*trace( TPP{i}*TPP{j} );
                end
            end
            
            g = ((v + 1)*A1 - (v+4)*A2)/((v+2)*A2);
            
            cden = 3*v + 2*(1-g);
            c1 = g/cden;
            c2 = (v-g)/cden;
            c3 = (v + 2 - g)/cden;
            
            B  = (1/(2*v))*( A1 + 6*A2);
            
            Vf = (2/v)*(  (1 + c1*B)/( (1-c2*B).^2*(1-c3*B)) );
            Ef  = 1./(1 - A2/v);
            
            rho = Vf/(2*(Ef.^2));
            
            m   = 4 + (v+2)/(v*rho-1);
            lambda = m/(Ef*(m-2));
            
            p2 = ls.covbadj;
            R = H*p2*H';
            [L p] = chol( R );
            
            if p==0
                Rinv = (L\(L'\eye(size(L,1)) ));
            else
                Rinv = svdinv( R);
            end
            Q = (H*b);
            theta = Q'*Rinv*Q;
            
            F = theta/v;
            Fadj = lambda*F;
            pval = 1 - fcdf( Fadj, v, m );
            
            stats.F = Fadj;
            %             stats.Fadj = Fadj;
            stats.dfr = v;
            stats.dfe = m;
            %             stats.Ef  = Ef;
            %             stats.Vf  = Vf;
            %             stats.rho = rho;
            %             stats.lambda = lambda;
            stats.pval = pval;
            
        end
        function P  = varcomp(a)
            tn = a.Z.tnames;
            vn = vertcat(tn{:}, {'residual', 'total'}' );
            s2     = [a.s2;sum(a.s2)];
            ratio  =  s2./a.s2(end);
            pct    = 100*s2./s2(end);
            se = sqrt( diag( a.Iinv ) );
            se(end+1) = sqrt( sum(a.Iinv(:)));  % TODO: double check this
            ncrit = norminv(.975);
            lo = s2 - se.*ncrit;
            hi = s2 + se.*ncrit;
            P   = Pmat( [ s2 ratio se lo hi pct], 0,0, vn, {'Var', 'Var Ratio', 'Std Error', '95% Lower', '95% Upper' 'Pct Total'}  );
        end
        function display(a)
            disp(a);
        end;
        function tbl = disp(a, varargin)
            p = inputParser;
            p.parse( varargin{:});
            tbl = a.beta(:,:,1);
            disp(tbl);
        end
        function v = V(a, s2)
            if nargin <2
                s2 = a.s2;
            end
            n = a.dft+1;
            R = spdiags( repmat(s2(end), n, 1), 0, n, n);
            Z = a.W.Z;
            v = R + Z*a.G*Z';
        end
        function g = get.G(a)
            g = blkrepmat( 'I', a.s2(1:end-1), a.W.Z.q );
        end
        function Z = get.Z(a) % return random effects design matrix
            Z = a.W.Z;
        end
        function u = get.u(a)
            u = a.beta{~a.W.fi,:};
        end
%         function varargout = subsref(a,s )
%             %FIXME this is verbatim from Lstats. Use case is probably
%             %different here.
%             %   2) covb only applys to fixed effects estimates
%             switch s(1).type
%                 case '()'
%                     i = s(1).subs{1}; i = ind2logical( i, psize(a.beta,1));
%                     j = s(1).subs{2};
%                     
%                     b = a;
%                     b.beta = a.beta(i,j);
%                     
%                     f = a.W.fi; % index fixed terms within W
%                     g = f&i;          % requested fixed terms within W
%                     h = g(f);         % requested fixed tersm within X
%                     
%                     b.covb = a.covb(h,h);
%                     b.covbadj = a.covbadj(h,h);
%                     b.Lambda = a.Lambda(h,h);
%                     b.W    = a.W(:,i); % terms from W;
%                     
%                     g = ~f&i;         % requested random terms within W
%                     h = g(~f);        % requested random tersm within Z
%                     b.s2 = [a.s2(h) a.s2(end)]; % requested VCs
%                     b.P  = [a.P(h) a.P(end)];
%                     % TODO I don't know what to do with Io and Iinv
%                     % maybe easiest to call kackar_harvil again
%                     % but I don't know how useful that is, or
%                     % how useful subsref is for mixed models
%                     varargout{1} = b;
%                 case '.'
%                     if length(s)==1
%                         varargout{1} = a.(s(1).subs);
%                     else
%                         a = a.(s(1).subs);
%                         [varargout{1:nargout}] = subsref( a, s(2:end));
%                     end
%             end
%         end
        function B = saveobj(a)
            B = a;
        end
        function ls = kackar_harville(ls)
            % kackar and harville adjustment to covb. Calculates the required
            % Lambda and intermediate P values. the adjusted covb  is covb + 2*covb*Lambda*covb
            %
            V = ls.V;
            phi = ls.covb;
            X = ls.W.X; Z = ls.W.Z;
            r = length(Z.q)+1;
            
            P = cell(r,1);
            dinvV = ls.dinvVr(Z, V);
            for i = 1:r
                P{i} = X'*dinvV{i}*X; %#ok<*PROP>
            end
            ls.P = P;
            
            Q = cell(r);
            for i = 1:r
                for j = 1:r
                    Q{i,j} = X'*dinvV{i}*V*dinvV{j}*X;
                end
            end
            
            %             %% W based on Expected Information
            %             % The Expected information matrix is computed using an unadjusted estimate of
            %             % V(beta)
            %             Ie = nan(r);
            %             for i = 1:r
            %                 for j = 1:r
            %                     Ie(i,j) = (trace( dinvV{i}*V*dinvV{j}*V ) - ...
            %                         trace( 2*phi*Q{i,j} - phi*P{i}*phi*P{j} ))/2;
            %                 end
            %             end
            %
            %             L  = chol( Ie );
            %             W  = L\(L'\eye(size(L)));
            %             We = W;
            
            %% W based on Observed Information
            W = ls.Iinv;
            % disp( norm( Ie - Io )  ); for debug
            
            %% W based on Average Inormation
            
            % L = chol( (Io + Ie)/2);
            % W  = L\(L'\eye(size(L)));
            
            
            %% compute adjusted phi
            Lambda = 0;
            for i = 1:r
                for j = 1:r
                    Lambda = Lambda + W(i,j)*(Q{i,j} - P{i}*phi*P{j});
                    %         disp(P{i}*phi*P{j})  % for debug
                end
            end
            ls.Lambda = Lambda;
            ls.covbadj = ls.covb + 2*ls.covb*ls.Lambda*ls.covb;
            
        end
        function [neg2LogL dLogL d2LogL] = logl( a, s2 )
            % logl returns the 2*negative log likelihood of a fit to y.
            % usage
            %    neg2LogL = logl( a );
            %    neg2LogL = logl( a, s2); % evaluate likelihood at given variance
            %    estimates
            
            if nargin < 2
                s2 = a.s2;
            end
            
            [neg2LogL dLogL d2LogL] = Mstats.reml( s2, a.X, a.Z, a.Z.q, a.y );
        end
    end
    methods (Static)
        function L = getcontrasts( p, method )
            %         1 = all pairwise (default)
            %             compares each combinations of pairs of levels
            %         2 = adjacent pairs  compare each level i+1 - i
            %         3 = baseline        compare each level i to level 1
            %         4 = paired pairs    compare i+1 - i, where i = 1:2:end
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
            L = L';
        end
        function dinvV = dinvVr( Z, V )
            %             L = chol(V);
            %             invV = L\(L'\eye(size(V,1)));
            invV = V\eye(size(V));
            
            q = Z.q;
            r = length(q);
            dinvV = cell(r+1,1);
            for i = 1:r
                s     = zeros(size(q));
                s(i)  = 1;
                dGr   = sparse(blkrepmat('I', s, q ));
                dinvV{i} = -invV*Z*dGr*Z'*invV;
            end
            
            dinvV{end} = -invV*invV;
        end
        function [s2 Io output flag grad] = varest( X, Z, y, s20, options)
            % VAREST returns estimates of variance components using an
            % unconstrained minimization of the -REML
            %
            % USAGE
            %   [s2 Io output flag grad] = do_varest( X, Z, y, s20, options);
            %
            % OPTIONS
            %       This is the options accecpted by fminunc. Some options are
            %       overridden by this function (hession, gradobj and largescale'
            %       others can be changed where they make sense
            %       See OPTIMSET for more details.
            % returns S2 is a vector of varirance components computed to satisify
            % the
            % restricted esetimated maximum likelihood (REML).
            %       y = Xb + Zu + e
            % X are the fixed effects design matrix. b is a vector of parameters
            % Z is a desgin  matrix for the r random effects. e is a random
            % error term. The ith random effect is estimated to come from N(u(i), s2(i)).
            % This algorithm assumes that the random effects are independent.
            %
            %
            % NOTES
            %   There are differences (usually small) between these results and those
            %   of JMP.
            
            
            % Reference:
            %   Searl, Casella and McCulloch. Variance Components, 1992
            %   Gilmour, Thompson, Cullis. "Average information REML: An efficient
            %   algorithm for variance parameter estimation in linear mixed models,"
            %   biometrics (1995), 51:1440-1450.
            %   Lamotte "Direct derivation of REML equations (or similar title).   very good
            
            
            if nargin < 3,
                error('linstats:solvem:InvalidArgument', 'must have at least 1 input arguments');
            end;
            
            if nargin < 5 %TODO change this to use inputParser and then let the users input overrid all of the optional paramters
                options = optimset( optimset('fminunc'),...
                    'DerivativeCheck', 'off', ...
                    'display', 'off', ...
                    'MaxFunEvals', 1000, ...
                    'NoStopIfFlatInfeas', 'off', ...
                    'TolX', 1e-6, ...
                    'TolFun', 1e-10 );
                % 'PrecondBandWidth',inf );
                
            end
            
            options = optimset(options, 'LargeScale', 'on', 'gradobj', 'on', ....
                'Hessian', 'on');
            
            
            % use initial estimates if provided
            if nargin > 3 && ~isempty(s20)
                s2 = s20;
            else  % make guess on initial estimates
                s2 = Mstats.minque( X, Z, y );
                if isempty(Z.p)
                    output = [];
                    flag = 0;
                    return
                end
                ll = Mstats.reml( s2, X, Z, Z.q, y );
                if ll >= realmax
                    % here the Variance matrix is negative or other problem.
                    % there is no standard
                    % procedure for fixing it. I am just substituting
                    % the mean squared error from the fixed model (dropping random effects)
                    % for any negative components and setting the other
                    % components to 0
                    e       = y-X*(X\y);
                    sse   = e'*e;
                    mse   = sse./(size(y,1)-size(X,2));
                    s2(1:end-1) = 0;
                    s2(end) = mse;
                    ll = Mstats.reml( s2, X, Z, Z.q, y );
                    if ll > realmax
                        s2(:) = mse;
                    end
                end
            end
            
            %% NB
            % I have found fminunc to be more reliable than fmincon.
            % My tests were based on the weather dataset
            %    load weather
            %    glm = encode(y, 3, 2, g1, g2 );
            %    s2{3} = varest_df( glm, 2, options );        % jmp* [44.1682 9.9174 .0859]
            %  and then varying the starting positions. fminunc is often faster to
            %  converge and allows a Hessian to be supplied by the objective function
            [s2 , ~, flag output grad hessian] = fminunc( @(s2) Mstats.reml( s2, X, Z, Z.q, y), s2, options);
            if nargout > 1
                Io = hessian/2;
            end
            
        end
        function s2  = minque( X, Z, y )
            %MINQUE0 minimum unbiased variance estimator (special case)
            %
            % usage
            %       S2 = MINQUE( X, Z, y )
            %           glm is model structure containing Dmat, and y, the response.
            % example
            %   load fertilizer
            %   d = Dmat( Vars( block, fertilizer, 'type', [3 1] );
            %   s2 = minque( d, y );
            %
            
            % Reference:
            %   Searl, Casella and McCulloch. Variance Components, 1992
            %   Wolfinger, Tobias, Sall (1994), "computing gaussian likelihoods
            %   and their derivatives for general mixed models" SIAM J Sci Comput 15:6
            %   pp 1294-1310
            
            % $Id: minque.m 70 2008-02-06 00:34:04Z mboedigh $
            % Copyright 2006 Mike Boedigheimer
            % Amgen Inc.
            % Department of Computational Biology
            % mboedigh@amgen.com
            %
            
            [n r]     = psize(Z);
            Xinv  = pinv(X);    % pinv also computes svd (and rank) which I could use to solve...
            M = eye(n) - X*Xinv;    % does this equal I - X*inv((X'X))*X' ? yes
            MZ2 = cell( r, 1);
            Z2 = cell(r,1);
            for i = 1:r
                Z2{i}   = Z(:,i)*Z(:,i)';  % This is dV/dS(i)
                MZ2{i}  = M*Z2{i};
            end
            
            My = M*y;
            A =  zeros( r+1,r+1);
            Y =  zeros( r+1,1);
            for i = 1:r
                Y(i) = y'*MZ2{i}*My;
                for j = i:r
                    A(i,j) = sum(sum( MZ2{i}.*MZ2{j}'));
                end
                A(i,r+1) = trace( MZ2{i} );    % if M is idempotent then = trace(MZ2{i}*M) = trace(MZ2{i}) I used simpler
            end
            A(r+1,r+1) = trace(M);  % if M*M is idempotent then = trace(M*M) = trace(M), I used simplier
            Y(r+1) = y'*My;         %  M is idempotent so I replaced y'*M*My with y'*M*y = y'*M*My
            
            A = A + triu(A,1)';
            s2 = A\Y;
        end
        function [neg2LogL dLogL d2LogL] = reml( s2, X, Z, q, y )
            % reml              returns -2*logL of a good method.
            %
            % usage:
            %       [neg2LogL dLogL d2LogL] = reml( s2, X, Z, q, y );
            % Very good paper on the subject by Wolfinger, Tobias and Sall (1994). SIAM
            % J SCI Comput vol 15(6), ppp 1294-1310
            
            %TODO: handle case where there are only fixed effects
            
            n = length(y);
            
            G = blkrepmat( 'I', s2(1:end-1), q );
            V = s2(end)*eye(n) + Z*G*Z';
            [L p]  = chol(V);
            if p ~= 0 % can also check whether diag(U'*T) has any negative elements
                % This section is adhoc. I don't know what to do if V is negative! It
                % definitely means that the variance estimates are not feasible
                %                                 neg2LogL = realmax;
                %                                 dLogL = 0;
                %                                 d2LogL = 0;
                %                 dLogL    = s2*.5;
                %                 dLogL(dLogL>0) = 0;
                %                 d2LogL   = 0;
                %                 % calculate reml using fundamentals
                %                 ViX  = V\X;  % = Vi*X;
                %                 XViX = X'*ViX;
                %                 XViy  = X'*(V\y); % = X'*Vi*y;
                %
                %                 b = XViX\XViy;
                %                 r = y - X*b;
                %
                %                 e = r'*(V\r);  % = r'*Vi*r;
                %                 c  = (n-size(X,2))*log(2*pi);
                %
                %                 D1 = det(V);
                %                 D2 = det(XViX);
                %
                % %                 L = (D1.*D2.*exp(e).*exp(c)).^-.5;
                %                 logL = -.5*(log(D1)+log(D2)+e+c);
                %
                %                 neg2LogL = -2*logL; % logL can be simplified to remove .5*(...), then this 2 cancels
                %                 if ~isreal(neg2LogL) || D1 < 0 || D2 < 0
                %                     neg2LogL = realmax;
                %                 end;
                neg2LogL = realmax;
                dLogL = 0;
                d2LogL = zeros(length(s2));
                %                 dLogL    = s2*.5;
                %                 dLogL(dLogL>0) = 0;
                %                 d2LogL   = zeros(length(s2));
                %                 % calculate reml using fundamentals
                %                 ViX  = V\X;  % = Vi*X;
                %                 XViX = X'*ViX;
                %                 XViy  = X'*(V\y); % = X'*Vi*y;
                %
                %                 b = XViX\XViy;
                %                 r = y - X*b;
                %
                %                 e = r'*(V\r);  % = r'*Vi*r;
                %                 c  = (n-size(X,2))*log(2*pi);
                %
                %                 D1 = det(V);
                %                 D2 = det(XViX);
                %
                % %                 L = (D1.*D2.*exp(e).*exp(c)).^-.5;
                %                 logL = -.5*(log(D1)+log(D2)+e+c);
                %
                %                 neg2LogL = -2*logL; % logL can be simplified to remove .5*(...), then this 2 cancels
                %
                %                 if ~isreal(neg2LogL) || D1 < 0 || D2 < 0
                %                     neg2LogL = realmax;
                %                 end;
                
                %% this doesn't work well, I think there is something good in it though,
                % maybe in combination with some sort of constraints on the hessian
                %                 if nargout == 3
                %                 [neg2LogL dLogL d2LogL] = Mstats.reml_bs( s2, X, Z, q, y );
                %                 elseif nargout ==2
                %                     [neg2LogL dLogL] = Mstats.reml_bs( s2, X, Z, q, y );
                %                 else
                %                     neg2LogL = Mstats.reml_bs( s2, X, Z, q, y );
                %                 end
                %                 if ~isreal(neg2LogL)
                %                      neg2LogL = realmax;
                %                 if nargout > 1
                %                      dLogL = dLogL;
                %                 end
                %                 end
                %                 neg2LogL = abs(neg2LogL);
                return;
            end
            
            % X = P*Q*R' (proposed)
            Linv   = L\eye(n);       % temp, Linv only used to calc Vinv
            Vinv   = Linv*Linv';     % V = U*S*T';
            XL     = X'/L;
            XVinvX = XL*XL';  % R*Q*P'*T*Si*U'*P*Q*R'; % Si = diag(1./diag(S))
            XLL    = XL/L';   % X'*inv(V) = R*Q*P'*T*Si*U' (from one line above)
            [pXVinvX, ~, S] = svdinv(XVinvX); %pXVinvX = R*Qi*P'*U*S*T'*P*Qi*R';
            % X*pXVinvX = P*P'*U*S*T'*P*Qi*R';
            % b = Vinv*X\Vinv*y;
            r      = y - X*pXVinvX*XLL*y;
            %X*pXVinvX*XLL*y = P*P'U*S*T'*P*P'*T*Si*U*y
            % r is equal to the y - X*blue
            rl     = r'/L;  % rl*rl' = r'*Vinv*r;
            logDetV = sum(2.*log(diag(L))); % = sum( log(svd(V)))
            logDetXVinvX = sum(log(diag(S))); % ?
            logL = -.5*(logDetV + logDetXVinvX + rl*rl' ...
                + (n-size(X,2))*log(2*pi));
            
            neg2LogL = -2*logL; % logL can be simplified to remove .5*(...), then this 2 cancels
            
            if nargout > 1
                %NOTE: I have sometimes noticed a difference between
                % finite difference gradients and analytical gradients
                % I don't know what causes this. I have tried using alternate methods
                % to calculated each of the arguments to dLdV and even though some
                % alternate methods produced slightly different values (e.g. Vinv as
                % calculated above and svdinv were different (norm of diff was 1e-13),
                % but this leads to small differences in dLdV - norm 1e-13)
                [dLogL XsLL dV] = Mstats.dLdV(Vinv,pXVinvX,rl/L',X,Z,q);
                %     disp(dLogL)
                if nargout > 2
                    d2LogL          = Mstats.d2LdV( Vinv, XsLL, dV, r );
                end
            end
        end
        function [dL XsLL dV] = dLdV( Vinv, pXVinvX, rll, X, Z, q )
            m = size(X,2);
            [C ~] = chol( pXVinvX, 'lower' ); % two ouptut needed
            
            if size(C,1) ~= m
                C(end+1:m,1:end) = 0;
            end
            Xs    = X*C;
            XsLL = Xs'*Vinv;
            dL = zeros(length(q)+1,1 );
            dV = cell(length(q)+1,1);
            for i = 1:length(q)
                s     = zeros(size(q));
                s(i)  = 1;
                dGr   = sparse(blkrepmat('I', s, q ));
                dVr   = Z*dGr*Z';
                dL(i) = trace( Vinv*dVr ) ...
                    -rll*dVr*rll'  ...
                    -trace( XsLL*dVr*XsLL' );
                dV{i} = dVr;
            end
            
            dL(end) = trace( Vinv) ...
                -rll*rll' ...
                -trace( XsLL*XsLL' );
            
            dV{end} = sparse(eye(size(X,1)));
            dL(abs(dL)<eps(1e4)) = 0;
        end
        function H = d2LdV( Vinv, T, dV, r )
            k = length(dV);
            H = zeros(k);
            for i = 1:k
                for j = i:k
                    R  = r'*Vinv;
                    Vr = dV{i};
                    Vs = dV{j};
                    S  = Vr*Vinv*Vs;
                    TT = T'*T;
                    h1 = -trace( Vinv*S );
                    h2 =  2*R*S*R' ...
                        -2*R*Vr*TT*Vs*R';
                    h3 = 2*trace(T*S*T') ...
                        -trace( T*Vr*TT*Vs*T');
                    H(i,j) = h1+h2+h3;
                end
            end
            H = H + triu(H,1)';
        end
    end
    
end