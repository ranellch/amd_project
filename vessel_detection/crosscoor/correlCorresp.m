classdef correlCorresp
    % correlCorresp finds image correspondences by cross-correlation
    %
    % Given two images, IMAGE1 and IMAGE2, this class finds features in
    % IMAGE2 that are good matches for features in IMAGE1.
    %
    % Algorithm
    % ---------
    %
    % An initial set of feature positions is identified in IMAGE1. By
    % default, these are found using local maxima of the grey-level
    % variance. The variance is computed on sliding regions of dimensions
    % FEATUREPATCHSIZE x FEATUREPATCHSIZE. Positions where the variance is
    % a local maximum and is greater than RELTHRESH * (the maximum
    % patch-variance in the image) are the starting feature positions.
    % Alternatively, the feature positions may be set explicitly.
    %
    % For each feature, a patch of IMAGE1, of dimensions SEARCHPATCHSIZE x
    % SEARCHPATCHSIZE and centred on the feature position, is extracted.
    % This patch is compared with a region of IMAGE2. This search region is
    % also determined by the feature position, and is such that the
    % horizontal offset between matches has to lie between XDMIN and XDMAX
    % and the vertical offset between YDMIN and YDMAX.
    %
    % The comparison is carried out using normalised cross-correlation,
    % with a speed-accuracy tradeoff. A convolution mask that approximates
    % the IMAGE1 patch (rotated 180 degrees) is used. The quality of the
    % approximation is determined by CONVTOL (see CONVOLVE2 for details).
    % The convolution result is divided by the patchwise standard deviation
    % of the IMAGE2 search region and the maximum in the search region is
    % taken to determine the best match for the IMAGE1 patch.
    %
    % Optionally, each match is validated by reversing the roles of IMAGE1
    % and IMAGE2, and correlating a patch of IMAGE2, centred on the
    % presumed match position, with an appropriate region of IMAGE1. If the
    % result is the same as the original IMAGE1 feature position, to within
    % a tolerance of MATCHTOL in both X and Y, the match is accepted. In
    % the final result, the position of the feature in IMAGE1 is the
    % average of its original position and the position of the best match
    % found after carrying out the reverse match.
    %
    % Usage
    % -----
    %
    % This is a value class, so any update to the state of a correlCorresp
    % object requires an assignment.
    %
    % A new correlCorresp object is set up using parameter/value arguments,
    % for example:
    %
    %   cc = correlCorresp('searchPatchSize', 15, 'convTol', 0.2);
    %
    % Parameters may also be updated subsequently. Parameters that are not
    % set are given defaults. To see the default values, do
    %
    %   disp(correlCorresp);
    %
    % The images to be processed may be supplied to the constructor, or
    % subsequently:
    %
    %   cc.image1 = im1;
    %   cc.image2 = im2;
    %
    % The correspondences are computed by a call to the findCorresps
    % method:
    %
    %   cc = cc.findCorresps;
    %
    % and the results obtained from the corresps property:
    %
    %   corrs = cc.corresps;
    %
    % See the individual properties and methods for more details, and
    % information about the structure of the results array.
    %
    % Efficiency notes
    % ----------------
    %
    % If many pairs of images are to be processed, it is most efficient to
    % create a single correlCorresp object outside the loop and use it to
    % process each pair of images.
    %
    % If multiple images are to be matched to a given initial image, only
    % the IMAGE2 property should be updated within the loop, to avoid
    % recomputing feature positions.
    %
    % If correspondences are needed between successive pairs of a sequence
    % of images, it is most efficient to call the advance method within the
    % loop to move IMAGE2 to IMAGE1, and to update only the IMAGE2 property
    % directly.
    %
    % See also convolve2, correspDisplay, correspDemo
    
    % Copyright David Young 2010
    
    
    properties (Dependent)
        
        % Feature selection patch size
        %
        % The size of the patches on which the variance is computed when
        % automatic feature finding is used. Must be set to an odd integer.
        featurePatchSize
        
        % Feature selection relative threshold
        %
        % The threshold for the local variance of features, relative to the
        % maximum local variance, when automatic feature finding is used.
        % Must be set to a number in the range 0 to 1.
        relThresh
        
        % Search patch size
        %
        % The size of the patch from IMAGE1 which is correlated with
        % IMAGE2. Must be set to an odd integer.
        searchPatchSize
        
        % Search region in IMAGE2
        %
        % Defines the region of IMAGE2 within which the patch from IMAGE1
        % is correlated. Must be set to a vector of the form [XDMIN XDMAX
        % YDMIN YDMAX]. The elements represent the limits to the offset
        % between a feature in IMAGE1 and its match in IMAGE2.
        searchBox
        
        % The tolerance for mask approximation
        %
        % Sets the trade-off between accuracy (low values) and speed (high
        % values) in the correlation. Must be set to a number from 0 to 1.
        %
        % See also: convolve2
        convTol
        
        % Whether to carry out reverse match checking
        %
        % If true, reverse match checking is carried out.
        doCheck
        
        % The tolerance for reverse match checking
        %
        % Sets the tolerance within which the reverse match must agree with
        % the forwards match. Must be set to a non-negative number. Ignored
        % if doCheck is false.
        matchTol
        
        % Control of printing
        %
        % If non-zero, a report on the progress of the matching process is
        % printed after every printProgress features have been considered.
        % Must be set to a non-negative integer.
        printProgress
        
        % Feature locations
        %
        % May be set to one of the following:
        %
        %   'auto': features are computed from IMAGE1 when findFeatures or
        %   findCorresps is called (see algorithm description).
        %
        %   A 2xM matrix F of integers: this specifies the locations of the
        %   centres of M features in image1. F(1,:) specifies the
        %   x-coordinates and F(2,:) specifies the y-coordinates. Valid
        %   features are selected from these when findFeatures or
        %   findCorresps is called. Valid features are those for which the
        %   x-coordinate is greater than (searchPatchSize-1)/2 and less
        %   than 1+size(image1,2)-(searchPatchSize-1)/2, and likewise for
        %   the y-coordinate.
        %
        % If advanceFeatures has been set to true, a call to ADVANCE will
        % cause this property to be ignored temporarily.
        %
        % See also correlCorresp/findFeatures, correlCorresp/advance,
        % correlCorresp/advanceFeatures, correlCorresp/features
        setFeatures
        
        % Controls whether the ADVANCE method propagates features
        %
        % If true, a call to the ADVANCE method sets the IMAGE1 features
        % for the next match to the features found in IMAGE2 at the last
        % match - that is, the feature set propagates in time along with
        % the image to which it refers. This temporarily overrides the
        % effect of the setFeatures property.
        %
        % The default value is false.
        %
        % The propagated features remain in effect until ADVANCE is called
        % again, or findFeatures is called, or one of the following
        % properties is set: IMAGE1; featurePatchSize; relThresh;
        % searchPatchSize. If one of these properties is changed, the next
        % call to findCorresps will use the value of setFeatures.
        %
        % See also correlCorresp/findFeatures, correlCorresp/advance,
        % correlCorresp/setFeatures, correlCorresp/features
        advanceFeatures
        
        % The base image
        %
        % The image containing the initial features. Must be set by
        % assignment or as an argument to the constructor before
        % findFeatures or findCorresps can be called. Must be set to a 2D
        % array.
        image1
        
        % The search image
        %
        % The image in which matching features are to be found. Must be set
        % by assignment or as an argument to the constructor before
        % findCorresps can be called. Must be set to a 2D array. Normally
        % it should have the same size as image1.
        image2
    end
    
    properties (Dependent, SetAccess = private)
        
        % The current set of valid features - read only
        %
        % Returns the feature positions computed by the last call to
        % findFeatures, findCorresps or ADVANCE, as a 2xM matrix of the
        % form [xcoords; ycoords].
        %
        % The saved features become invalid and cannot be accessed after
        % any of the following properties has been set: IMAGE1;
        % featurePatchSize; relThresh; searchPatchSize.
        %
        % See also correlCorresp/findFeatures, correlCorresp/advance,
        % correlCorresp/setFeatures, correlCorresp/advanceFeatures
        features
        
        % The results of correspondence matching - read only
        %
        % After a call to findCorresps this is a 4xN matrix, representing N
        % matches, with the following structure:
        %
        %   corresps(1,:) - the x-coordinates of features in image1
        %   corresps(2,:) - the y-coordinates of features in image1
        %   corresps(3,:) - the x-coordinates of features in image2
        %   corresps(4,:) - the y-coordinates of features in image2
        %
        % The first two rows will represent positions close to those in the
        % features property. However, if doCheck is true, unmatched
        % features will be omitted, and the position coordinates may differ
        % by up to matchTol/2.
        corresps
        
        % The correlation values for the matches - read only
        %
        % After a call to findCorresps this is a vector containing the
        % correlations for the matches found, in the order corresponding to
        % the corresps property. If doCheck is true, the values are the
        % averages of the forward and backward correlations. If convTol is
        % greater than 0, the values are approximations and may be greater
        % than 1.
        correls
    end
    
    properties (Access = private)
        % Private shadows of the public dependent properties. Needed
        % because set methods are only allowed to change the property to
        % which they refer, but setting one public property must invalidate
        % others.
        
        % Default values are set here.
        fPS = 5
        rT = 0.05
        sPS = 41
        xdmin = -100
        xdmax = 100
        ydmin = -100
        ydmax = 100
        cT = 0.1
        dC = true;
        mT = 2
        pP = false
        
        im1
        im2
        featuresin = 'auto'
        advancefeat = false;
        featOK = false    % if valid features
        fr      % input feature rows in image1
        fc      % input feature cols in image1
        
        % Functions of the individual images, held for efficiency
        stdev1
        stdev2
        
        % Private shadow of the result
        resOK = false       % if valid matches
        frout1      % output feature rows in image1
        fcout1      % output feature cols in image1
        frout2      % matched feature rows in image2
        fcout2      % matched feature cols in image2
        corrout     % correlations of matched features
    end
    
    properties (Dependent, Access = private)
        hpsize      % (search patch size - 1)/2
    end
    
    
    methods     % constructor method
        
        function cc = correlCorresp(varargin)
            % Constructor for image correspondence objects
            %
            % cc = correlCorresp('prop1', val1, 'prop2', val2, ...)
            % constructs an image corresponce object, setting property
            % prop1 to value val1 etc. See the class information for
            % details. Properties not set are given default values; to see
            % these execute disp(correlCorresp).
            %
            % See also: correspDemo
            
            cc = setProps(cc, varargin{:});
        end
        
    end
    
    methods    % set/get methods
        
        % Set/get methods with argument checking and state maintenance.
        % See comments under public properties above.
        % Note: care needed to be sure that setting properties correctly
        % invalidates results of previous computations.
        
        function cc = set.featurePatchSize(cc, s)
            validateattributes(s, {'double'}, ...
                {'odd', 'positive', 'scalar'});
            cc.fPS = s;
            cc.featOK = false; cc.resOK = false;
        end
        function x = get.featurePatchSize(cc)
            x = cc.fPS;
        end
        
        function cc = set.relThresh(cc, t)
            validateattributes(t, {'double'}, ...
                {'scalar', '>=', 0, '<', 1});
            cc.rT = t;
            cc.featOK = false; cc.resOK = false;
        end
        function x = get.relThresh(cc)
            x = cc.rT;
        end
        
        function cc = set.searchPatchSize(cc, s)
            validateattributes(s, {'double'}, ...
                {'odd', 'positive', 'scalar'});
            cc.sPS = s;
            cc.featOK = false; cc.resOK = false;
            cc.stdev1 = []; cc.stdev2 = [];
        end
        function x = get.searchPatchSize(cc)
            x = cc.sPS;
        end
        
        function x = get.hpsize(cc)
            x = (cc.sPS-1)/2;
        end
        
        function cc = set.searchBox(cc, b)
            validateattributes(b, {'double'}, ...
                {'integer', 'size', [1 4]});
            cc.xdmin = b(1);
            cc.xdmax = b(2);
            cc.ydmin = b(3);
            cc.ydmax = b(4);
            cc.resOK = false;
        end
        function x = get.searchBox(cc)
            x = [cc.xdmin cc.xdmax cc.ydmin cc.ydmax];
        end
        
        function cc = set.convTol(cc, t)
            validateattributes(t, {'double'}, ...
                {'scalar', '>=', 0, '<=', 1});
            cc.cT = t;
            cc.resOK = false;
        end
        function x = get.convTol(cc)
            x = cc.cT;
        end
        
        function cc = set.doCheck(cc, b)
            validateattributes(b, {'logical' 'double'}, ...
                {'binary' 'scalar'});
            cc.dC = b;
            cc.resOK = false;
        end
        function b = get.doCheck(cc)
            b = cc.dC;
        end
        
        function cc = set.matchTol(cc, t)
            validateattributes(t, {'double'}, {'nonnegative', 'scalar'});
            cc.mT = t;
            cc.resOK = false;
        end
        function x = get.matchTol(cc)
            x = cc.mT;
        end
        
        function cc = set.printProgress(cc, t)
            validateattributes(t, {'double'}, ...
                {'integer', 'nonnegative', 'scalar'});
            cc.pP = t;
        end
        function x = get.printProgress(cc)
            x = cc.pP;
        end
        
        function cc = set.image1(cc, im)
            % Attributes not checked, as image1 may be set in a loop
            cc.im1 = im;
            cc.stdev1 = [];
            cc.featOK = false; cc.resOK = false;
        end
        function x = get.image1(cc)
            x = cc.im1;
        end
        
        function cc = set.setFeatures(cc, feat)
            if ~isequal(feat, 'auto')
                validateattributes(feat, {'double'}, {'integer'});
                if size(feat,1) ~= 2
                    error('correl_corresp:setfeatures:badsize', ...
                        'Features matrix must have 2 rows');
                end
            end
            cc.featuresin = feat;
            if ~isequal(feat, 'advance')
                cc.featOK = false;
            end
            cc.resOK = false;
        end
        function feat = get.setFeatures(cc)
            feat = cc.featuresin;
        end
        
        function cc = set.advanceFeatures(cc, a)
            validateattributes(a, {'logical' 'double'}, ...
                {'binary' 'scalar'});
            cc.advancefeat = a;
        end
        function a = get.advanceFeatures(cc)
            a = cc.advancefeat;
        end
        
        function x = get.features(cc)
            if cc.featOK
                x = [cc.fc cc.fr].';
            else
                error('correl_corresp:getfeatures:nofeatures', ...
                    'No valid features available');
            end
        end
        
        function cc = set.image2(cc, im)
            % Attributes not checked, as may be set in a loop
            cc.im2 = im;
            cc.stdev2 = [];
            cc.resOK = false;
        end
        function x = get.image2(cc)
            x = cc.im2;
        end
        
        function c = get.corresps(cc)
            if cc.resOK
                c = [cc.fcout1 cc.frout1 cc.fcout2 cc.frout2].';
            else
                error('correl_corresp:getcorresps:nocorresps', ...
                    'No correspondences have been computed');
            end
        end
        
        function c = get.correls(cc)
            if cc.resOK
                c = cc.corrout.';
            else
                error('correl_corresp:getcorrels:nocorresps', ...
                    'No correspondences have been computed');
            end
        end
        
    end
    
    methods     % computational methods
        
        % Image advance method, to avoid recomputing standard deviation
        % array unnecessarily and to allow feature propagation
        
        function cc = advance(cc)
            % ADVANCE Advances image2 to image1.
            %
            % This method is for computation of successive sets of
            % correspondences in image sequences, by moving IMAGE2 to
            % IMAGE1. Its effect is thus
            %
            %   cc.image1 = cc.image2;
            %
            % However, the method is more efficient than the assignment. It
            % could be used like this, assuming we have a cell array of
            % images and we want a cell array of correspondence results:
            %
            %   cc = correlCorresp('image1', images{1});
            %   for k = 2:length(images)
            %       cc.image2 = images{k};
            %       cc = cc.findCorresps;
            %       corresps{k} = cc.corresps;
            %       cc = cc.advance;
            %   end
            %
            % Feature propagation
            % -------------------
            %
            % By default, the feature positions for each new image depend
            % on the value of the setFeatures property. However, if
            % advanceFeatures is true, the feature positions found in
            % IMAGE2 by the last call to findCorresps are propagated with
            % the image. The effect is thus equivalent to
            %
            %   corrs = cc.corresps;
            %   cc.features = corrs([3 4], :);
            %
            % (though the FEATURES property cannot actually be set
            % directly). The propagated features become invalid if any of
            % the following properties is set: IMAGE1; featurePatchSize;
            % relThresh; searchPatchSize. After one of these properties is
            % set, or after a call to findFeatures, the features again
            % depend on the setFeatures property.
            %
            % See also correlCorresp/advanceFeatures,
            % correlCorresp/setFeatures
            
            cc.im1 = cc.im2;
            cc.stdev1 = cc.stdev2;
            if cc.resOK && cc.advancefeat
                cc.fr = cc.frout2;
                cc.fc = cc.fcout2;
                cc.featOK = true;
            else
                cc.featOK = false;
            end
            cc.resOK = false;
        end
        
        
        function cc = findFeatures(cc)
            % Sets feature positions in IMAGE1
            %
            % If the setFeatures property has been set to 'auto' (the
            % default), computes feature positions using local maxima of
            % local variance. If the setFeatures property has been set to a
            % matrix, selects the columns that represent valid positions
            % (such that a searchPatchSize x searchPatchSize box may be
            % centred on the location and remain inside IMAGE1).
            %
            % The feature positions are then available by accessing the
            % FEATURES property, and remain available until IMAGE1,
            % featurePatchSize, relThresh or searchPatchSize is set, or
            % ADVANCE is called.
            % 
            % Called, if necessary, by findCorresps.
            %
            % See also correlCorresp/setFeatures, correlCorresp/features,
            % correlCorresp/advanceFeatures, varPeaks.
            
            if isempty(cc.im1)
                error('correl_corresp:setFeatures:noimage', ...
                    'image1 has not been set')
            end
            if isequal(cc.featuresin, 'auto')
                % get a set of features from im1 as starting point
                % - these will have integer positions as patchsize is odd
                [cc.fr, cc.fc] = varPeaks(cc.im1, cc.fPS, cc.rT);
            else
                % get the features from the input set
                cc.fc = (cc.featuresin(1,:)).';
                cc.fr = (cc.featuresin(2,:)).';
            end
            % remove those that are too near borders
            cc = cc.trimfeatures;
            cc.featOK = true;
        end
        
        
        function cc = findCorresps(cc)
            % Computes correspondences between image1 and image2
            %
            % Finds correspondences using maximum cross-correlation, and
            % sets the corresps property.
            %
            % See also corrpeak, convolve2
 
            if ~cc.featOK
                cc = cc.findFeatures;
            end
            
            if cc.pP && cc.doCheck
                fprintf('Forward matches: ');
            end
            
            cc = cc.findCorrespsFwd;
            
            if cc.doCheck
                % Reverse match check
                dd = cc;
                dd.im1 = cc.im2;  % dd is reverse of cc
                dd.stdev1 = cc.stdev2;
                dd.im2 = cc.im1;
                dd.stdev2 = cc.stdev1;
                dd.fr = cc.frout2;
                dd.fc = cc.fcout2;
                dd.xdmin = -cc.xdmax;
                dd.xdmax = -cc.xdmin;
                dd.ydmin = -cc.ydmax;
                dd.ydmax = -cc.ydmin;
                
                if dd.pP
                    fprintf('Reverse matches: ');
                end
                dd = dd.findCorrespsFwd;
                
                % Only retain matches within matchTol in both x and y
                ok = abs(dd.frout2-cc.frout1) <= cc.mT & ...
                    abs(dd.fcout2-cc.fcout1) <= cc.mT;
                cc.frout1 = (dd.frout2(ok)+cc.frout1(ok))/2;
                cc.fcout1 = (dd.fcout2(ok)+cc.fcout1(ok))/2;
                cc.frout2 = cc.frout2(ok);
                cc.fcout2 = cc.fcout2(ok);
                cc.corrout = (dd.corrout(ok) + cc.corrout(ok))/2;
                
                if cc.pP
                    n = size(cc.fr, 1);
                    nok = size(cc.frout1,1);
                    fprintf('%d consistent matches, no match for %d features\n', ...
                        nok, n - nok);
                end
            end            
        end
        
    end
    
    methods (Access = private)
        
        function cc = findCorrespsFwd(cc)
            % Computes forward correspondences between image1 and image2
            %
            % Finds correspondences using maximum cross-correlation (see
            % algorithm description), and sets the results properties.
            
            if isempty(cc.im2)
                error('correl_corresp:setFeatures:noimage', ...
                    'image2 has not been set')
            end
            
            if isempty(cc.stdev1) && cc.doCheck
                % Compute now for correl normalisation, provided that it
                % will be needed later for reverse match. Otherwise,
                % normalisation for patch can be computed on a
                % patch-by-patch basis.
                cc.stdev1 = patch_std(cc.im1, cc.sPS);
            end
            if isempty(cc.stdev2)
                cc.stdev2 = patch_std(cc.im2, cc.sPS);
            end
                               
            frin = cc.fr;
            fcin = cc.fc;
            n = size(frin, 1);
            frout = zeros(n, 1);
            fcout = zeros(n, 1);
            cout = zeros(n, 1);
            psh = cc.hpsize;
            
            if cc.pP
                fprintf('Matching %d features\n', n);
            end
            
            % Iterate over features
            for i = 1:n
                [frout(i), fcout(i), cout(i)] = ...
                    cc.bestmatch(frin(i), fcin(i), psh);
                                
                if cc.pP && ~(mod(i,cc.pP))
                    fprintf('   Done %d tests\n', i);
                end
            end
            
            cc.frout1 = frin;
            cc.fcout1 = fcin;
            cc.frout2 = frout;
            cc.fcout2 = fcout;
            cc.corrout = cout;
            cc.resOK = true;
        end
        
        
        function [rm, cm, vm] = bestmatch(cc, r, c, psh)
            % Find single one-way match
            %
            % Looks for match between patch in IM1 centred on R,C and
            % region in IM2 specified by R,C and limits XDMIN, XDMAX,
            % YDMIN, YDMAX on the maximum offset (see algorithm
            % description).
                        
            % We know that r and c are not too close to image borders
            patch = cc.im1(r-psh:r+psh, c-psh:c+psh);
            
            [search_area, roff, coff] = cc.getreg(cc.im2, r, c, ...
                cc.ydmin-psh, cc.ydmax+psh, cc.xdmin-psh, cc.xdmax+psh);
            
            % stdev was offset already by psh
            stds = cc.getreg(cc.stdev2, r-psh, c-psh, ...
                cc.ydmin, cc.ydmax, cc.xdmin, cc.xdmax);
            
            patch = patch - mean(patch(:)); % zero mean
            
            % Core call of whole class - search for peak correlation
            [rm, cm, vm] = corrpeak(search_area, patch, stds, cc.cT);
            
            % correct for offset
            rm = rm + roff;
            cm = cm + coff;
            
            % normalise with std dev of patch (already normalised with std
            % dev of search region)
            if isempty(cc.stdev1)
                % ? not worth computing whole stdev array ?
                s = std(patch(:), 1);
            else
                s = cc.stdev1(r-psh, c-psh);
            end
            vm = vm / (numel(patch) * s);
        end
        
        
        function cc = trimfeatures(cc)
            % Trim the feature positions so as not to be too close to the
            % edges of the image
            [nr, nc] = size(cc.im1);
            h = cc.hpsize;
            r = cc.fr;
            c = cc.fc;
            ok = r > h & r <= nr-h & c > h & c <= nc-h;
            cc.fr = r(ok);
            cc.fc = c(ok);
        end
        
    end
    
    methods (Static, Access = private)
        
        function [r, roff, coff] = getreg(im, r, c, r0, r1, c0, c1)
            % Gets region of im defined by r, c and a box, truncating if
            % necessary and returning also the row and column offsets of
            % the region.
            [nr, nc] = size(im);
            rstart = max(1, r+r0);
            rend = min(nr, r+r1);
            cstart = max(1, c+c0);
            cend = min(nc, c+c1);
            r = im(rstart:rend, cstart:cend);
            roff = rstart-1;
            coff = cstart-1;
        end
        
    end
    
end
