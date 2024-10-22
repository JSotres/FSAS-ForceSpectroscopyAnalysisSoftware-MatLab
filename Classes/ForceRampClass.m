classdef ForceRampClass < handle
    % Class definition of force ramp objects
    
    properties
        % 2D arrays where each column accounts for a X and Y values of a
        % force ramp. "F" and "B" indicate whether they correspond to
        % forward (approach) or backward (withdraw) ramps.
        % X(F/B)(:,1) -> sample vertical absolute positions
        % X(F/B)(:,2) -> sample vertical offset corrected positions
        % (contact point found)
        % X(F/B)(:,3) -> sample probe relative distances
        % Y(F/B)(:,1) -> absolute photodetector signal
        % Y(F/B)(:,2) -> offset corrected photodetector signal
        % Y(F/B)(:,3) -> cantilever deflection
        % Y(F/B)(:,4) -> force
        XF
        XB
        YF
        YB
        
        % 1D arrays indicating whether a give representation for the X or Y
        % values or a Ramp were found (value 1) or not (value 0)
        FZRepresentationX
        FZRepresentationY
        
        % 1D array indicating whether a given analysis for a Ramp was
        % performed (value 1) or not (value 0)
        % 1 -> Hertz Offset
        % 2 -> Linear fit
        % 3 -> Exponetial fit
        AnalysisRepresentation
       
        % Property to define different properties of the ramp:
        % 1 -> xposition
        % 2 -> yposition
        % 3 -> height
        % 4 -> selected
        % 5 -> slope of linear fit
        % 6 -> sample Young modulus
        % 7 -> contact point
        % 8 -> maximum adhesion
        % 9 -> adhesion work
        % 10 -> exponential amplitude
        % 11 -> exponential length
        Property
        
        % Properties consisting on 1-d arrays used for representing fits of
        % the Ramps
        %
        % For Linear Fit
        LinearFitX
        LinearFitY
        % For Hertz Fit
        HertzX
        HertzY
        % For exponential fit
        ExpX
        ExpY
        
        % For the linear fit, two more properties are used indicating the X
        % and Y representations used
        linearFitRepresentationX
        linearFitRepresentationY
        
        % Name/title of the ramp, corresponds to the name of the file if
        % individual ramps are loaded, and it is left empty if a force
        % volume file is loaded
        Title
    end
    
    methods
        function fz = ForceRampClass
            % Constructor. So far, just for naming as "obj"
            % an instance of the class
        end
        
        function YOffsetAverageRamp(fz, param)
            % Substract an offset from the Y of the raw representation of
            % the force ramp fz.YF(:,1), creating YF(:,2)
            
            % Find the indices corresponding to the XF(:,1) region defined
            % for the Y(F/B) offset substration
            [IndMinF,IndMaxF] =...
                FromRange2Indexes(fz.XF(:,1),param.xForwardMin, param.xForwardMax);
            [IndMinB,IndMaxB] =...
                FromRange2Indexes(fz.XB(:,1),param.xBackwardMin, param.xBackwardMax);
            
            % Actual offset substraction
            fz.YF(:,2) = fz.YF(:,1)-nanmean(fz.YF(IndMinF:IndMaxF,1));
            fz.YB(:,2) = fz.YB(:,1)-nanmean(fz.YB(IndMinB:IndMaxB,1));
            
            % Indicate that (offset corrected) photodetector values
            % representations were found
            fz.FZRepresentationY(2) = 1;
        end
        
        function RampCalibration(fz, param)
            % Converts the (offset corrected) photodetector values,
            % Y(F/B)(:, 2), into cantilever deflection, Y(F/B)(:, 3), and
            % force, Y(F/B)(:, 4), representations
            fz.YF(:,3) = fz.YF(:,2)*param.PhotodetectorSensitivity;
            fz.YB(:,3) = fz.YB(:,2)*param.PhotodetectorSensitivity;
            fz.YF(:,4) = fz.YF(:,3)*param.SpringConstant;
            fz.YB(:,4) = fz.YB(:,3)*param.SpringConstant;
            
            % Indicate that caltilever deflection and force Y
            % representations were found
            fz.FZRepresentationY(3) = 1;
            fz.FZRepresentationY(4) = 1;
            fz.Property(8) = abs(min(fz.YB(:,4)));
        end
        
        function HertzXOffsetRamp(fz, param)
            % Fit user defined contact region to the Hertz Model,
            % find the contact point and substract it from the Sample
            % Vertical position values (offset them).
            % It also determines the probe-sample distance representations
            % XF(:,3) and YF(:,3), and also the work of adhesion
            % Property(9)
            
            % Find the indices corresponding to the XF(:,1) region defined
            % for the Hertz fitting
            [IndMinF,IndMaxF] =...
                FromRange2Indexes(fz.XF(:,1),param.xForwardMin, param.xForwardMax);
            
            % Call the HertzXOffsetDetermination function, which returns
            % the sample Young modulus, Property(6), the contact point,
            % Property(7), and the X and Y values of the Hertz fit, 
            % HertzY and HertzX
            [fz.Property(6) , fz.Property(7), HertzY, HertzX] =...
                HertzXOffsetDetermination(...
                fz.YF(IndMinF:IndMaxF,3), fz.XF(IndMinF:IndMaxF,1),...
                fz.YF(:,3), fz.XF(:,1),...
                param.SpringConstant, param.ProbeRadius,...
                param.PoissonRatio);
            
            % If the returned Young modulus is not NaN
            if ~isnan(fz.Property(6))
                % Defines the offset corrected sample vertical values
                % X(F/B)(:,2)
                fz.XF(:,2) = fz.XF(:,1)-fz.Property(7);
                fz.XB(:,2) = fz.XB(:,1)-fz.Property(7);
                
                % Indicate that the the offset corrected sample vertical
                % values representation was found
                fz.FZRepresentationX(2) = 1;
                
                % Defines 1D arrays for the Hertz fit
                fz.HertzX = [];
                fz.HertzY = [];
                fz.HertzY(:,1) = HertzY;
                fz.HertzX(:,1) = HertzX;                
                fz.HertzY(:,2) = fz.HertzY(:,1) * param.SpringConstant;
                
                % Indicate that the Ramp was analyzed with a Hertz fit
                fz.AnalysisRepresentation(1) = 1;
                
                % Finds probe-sample distance representation by calling the
                % function (defined in a different file)
                % TSDistanceConverter
                fz.XF(:,3) = TSDistanceConverter(fz.XF(:,2),fz.YF(:,3));
                fz.XB(:,3) = TSDistanceConverter(fz.XB(:,2),fz.YB(:,3));
                % Indicate that the probe-sample distance represntation was
                % found
                fz.FZRepresentationX(3) = 1;
                % Transforms the X values of the Hertz fit to a
                % sample-distance representation, HertzX(:,2)
                fz.HertzX(:,2) =...
                    TSDistanceConverter(fz.HertzX(:,1), fz.HertzY(:,1));
                
                % Finds work of adhesion
                % It require arranging XF(:,3) and YF(:,4) in incremental
                % values of XF(:,3), which is done by calling the external
                % function "Ordenar"            
                [xData, yData] = Ordenar(fz.XB(:,3),fz.YB(:,4));
                % A new 1d array is defined, yData, similar to YB(:,4) 
                % but with all positive values changed to 0
                yData(yData>0) = 0;
                % Work of adhesion for the ramp, Property(9) is calculated
                % by integrating the array defined above, yData
                fz.Property(9) = -trapz(xData, yData);
            end
        end
        
        function ProbeSampleDistanceConverter(fz, ~)
            % Finds probe-sample distance representation for a Ramp
            fz.XF(:,3) = TSDistanceConverter(fz.XF(:,2),fz.YF(:,3));
            fz.XB(:,3) = TSDistanceConverter(fz.XB(:,2),fz.YB(:,3));
            % Indicate that the probe-sample distance represntation was
            % found
            fz.FZRepresentationX(3) = 1;
        end
        
        function LinearFitRamp(fz, param, xRepresentation, yRepresentation)
            % Fit user defined region of the ramp in the "xRepresentation"
            % and "yRepresentation" with a linear function y=slope*x+y0
            
            % For safety, XF(:,xRepresentation) and YF(:,yRepresentation)
            % are arranged in incremental values of XF(:,xRepresentation),
            % which is done by calling the external function "Ordenar"
            [xData, yData] =...
                Ordenar(fz.XF(:,xRepresentation),fz.YF(:,yRepresentation));
            
            % Identification of the indices of xData (and yData)
            % corresponding to the values within the range provided as
            % fields of "param"
            [IndMinF, IndMaxF] =...
                FromRange2Indexes(xData, param.xForwardMin, param.xForwardMax);
            
            % Actual linear fit
            f = polyfit(xData(IndMinF:IndMaxF), yData(IndMinF:IndMaxF), 1);
            
            % Defines the slope of the linear fit
            fz.Property(5) = f(1);
            
            % Defines 1D arrays (X and Y) for the linear fit
            fz.LinearFitX = [];
            fz.LinearFitY = [];
            fz.LinearFitX = xData(IndMinF:IndMaxF);
            fz.LinearFitY= polyval(f, fz.LinearFitX);
            
            %Indicates that the ramp was analyzed with an exponential
            %fit
            fz.AnalysisRepresentation(2) = 1;
            
            % Indicates the X and Y representations from which the linear
            % fit was found
            fz.linearFitRepresentationX = xRepresentation;
            fz.linearFitRepresentationY = yRepresentation;
        end
        
        function ExponentialFitRamp(fz, param)
            % Fit user defined region of the force vs probe-sample distance
            % representation to an exponential function
            
            % It require arranging XF(:,3) and YF(:,4) in incremental
            % values of XF(:,3), which is done by calling the external
            % function "Ordenar"
            [xData, yData] = Ordenar(fz.XF(:,3),fz.YF(:,4));
            [IndMinF, IndMaxF] =...
                FromRange2Indexes(xData, param.xForwardMin, param.xForwardMax);
            
            % Actual exponential fit
            f = fit(xData(IndMinF:IndMaxF),yData(IndMinF:IndMaxF),'exp1',...
                'Lower', [param.MinP1, -1/param.MinP2],...
                'Upper', [param.MaxP1, -1/param.MaxP2],...
                'StartPoint',[param.StartP1 -1/param.StartP2]);
            
            % Further actions to be taken if the fit parameters do not
            % equal the minimium or maximum limits
            c=coeffvalues(f);
            if (c(1) ~= param.MinP1) && (c(1) ~= param.MaxP1) &&...
                    (c(2) ~= param.MinP2) && (c(2) ~= param.MaxP2)
                % Defines the amplitude, Property(10), and characteristic
                % length, Property(11), of the exponential fit
                fz.Property(10) = c(1);
                fz.Property(11) = -1/c(2);
                
                % Defines 1D arrays (X and Y) for the exponential fit
                fz.ExpX = [];
                fz.ExpY = [];
                fz.ExpX = xData(IndMinF:IndMaxF);
                fz.ExpY = c(1)*exp(c(2)*fz.ExpX);
                
                %Indicates that the ramp was analyzed with an exponential
                %fit
                fz.AnalysisRepresentation(3) = 1;
            end
        end
        
    end
end

