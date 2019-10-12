classdef ForceRampClass < handle
    % Class definition of force ramp objects
    
    properties
        XF
        XB
        YF
        YB
        FZRepresentationX
        FZRepresentationY
        AnalysisRepresentation
        % Property to define different properties of the ramp:
        % 1 -> xposition
        % 2 -> yposition
        % 3 -> height
        % 4 -> selected
        % 5 -> slope
        % 6 -> Young modulus
        % 7 -> contact point
        % 8 -> maximum adhesion
        % 9 -> adhesion work
        % 10 -> exponential amplitude
        % 11 -> exponential length
        Property
        % Properties consisting on 1-d arrays used for representing fits of
        % the Ramps
        %
        % For Slope Fit
        SlopeX
        SlopeY
        % For Hertz Fit
        HertzX
        HertzY
        % For exponential fit
        ExpX
        ExpY
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
        
%         function outputArg = method1(obj,inputArg)
%             %METHOD1 Summary of this method goes here
%             %   Detailed explanation goes here
%             outputArg = obj.Property1 + inputArg;
%         end
%         
        function YOffsetAverageRamp(fz, param)
            % Substract an offset from the Y of the raw representation of
            % the force ramp
            %
            [IndMinF,IndMaxF]=FromRange2Indexes(fz.XF(:,1),param.xForwardMin, param.xForwardMax);
            [IndMinB,IndMaxB]=FromRange2Indexes(fz.XB(:,1),param.xBackwardMin, param.xBackwardMax);
            fz.YF(:,2) = fz.YF(:,1)-nanmean(fz.YF(IndMinF:IndMaxF,1));
            fz.YB(:,2) = fz.YB(:,1)-nanmean(fz.YB(IndMinB:IndMaxB,1));
            fz.FZRepresentationY(2) = 1;
        end
        
        function RampCalibration(fz, param)
            fz.YF(:,3) = fz.YF(:,2)*param.PhotodetectorSensitivity;
            fz.YB(:,3) = fz.YB(:,2)*param.PhotodetectorSensitivity;
            fz.YF(:,4) = fz.YF(:,3)*param.SpringConstant;
            fz.YB(:,4) = fz.YB(:,3)*param.SpringConstant;
            fz.FZRepresentationY(3) = 1;
            fz.FZRepresentationY(4) = 1;
            fz.Property(8) = abs(min(fz.YB(:,4)));
        end
        
        function HertzXOffsetRamp(fz, param)
            % Fit user defined contact region to the Hertz Model,
            % find the contact point and substract it from the Sample
            % Vertical position values (offset them)
            %
            [IndMinF,IndMaxF] =...
                FromRange2Indexes(fz.XF(:,1),param.xForwardMin, param.xForwardMax);
            [fz.Property(6) , fz.Property(7), HertzY, HertzX] =...
                HertzXOffsetDetermination(...
                fz.YF(IndMinF:IndMaxF,3), fz.XF(IndMinF:IndMaxF,1),...
                param.SpringConstant, param.ProbeRadius,...
                param.PoissonRatio);
            if ~isnan(fz.Property(6))
                fz.HertzY = [];
                fz.HertzX = [];
                fz.HertzY(:,1) = HertzY;
                fz.HertzX(:,1) = HertzX;
                fz.XF(:,2) = fz.XF(:,1)-fz.Property(7);
                fz.XB(:,2) = fz.XB(:,1)-fz.Property(7);
                fz.HertzY(:,2) = fz.HertzY(:,1) * param.SpringConstant;
                fz.FZRepresentationX(2) = 1;
                fz.AnalysisRepresentation(1) = 1;
                % Finds probe-sample distance representation
                fz.XF(:,3) = TSDistanceConverter(fz.XF(:,2),fz.YF(:,3));
                fz.XB(:,3) = TSDistanceConverter(fz.XB(:,2),fz.YB(:,3));
                fz.FZRepresentationX(3) = 1;
                fz.HertzX(:,2) =...
                    TSDistanceConverter(fz.HertzX(:,1), fz.HertzY(:,1));
                % Finds work of adhesion
                [xData, yData] = Ordenar(fz.XB(:,3),fz.YB(:,4));
                yData(yData>0) = 0;
                fz.Property(9) = -trapz(xData, yData);
            end
        end
        
        function ProbeSampleDistanceConverter(fz, param)
            % Finds probe-sample distance representation for a FZ ramp
            fz.XF(:,3)=TSDistanceConverter(fz.XF(:,2),fz.YF(:,3));
            fz.XB(:,3)=TSDistanceConverter(fz.XB(:,2),fz.YB(:,3));
            fz.FZRepresentationX(3) = 1;
        end
        
        function ExponentialFitRamp(fz, param)
            % Fit user defined region to an exponential function
            %
            [xData, yData] = Ordenar(fz.XF(:,3),fz.YF(:,4));
            [IndMinF, IndMaxF] = FromRange2Indexes(xData, param.xForwardMin, param.xForwardMax);
            f=fit(xData(IndMinF:IndMaxF),yData(IndMinF:IndMaxF),'exp1', 'Lower', [param.MinP1, -1/param.MinP2],...
                'Upper', [param.MaxP1, -1/param.MaxP2], 'StartPoint',[param.StartP1 -1/param.StartP2]);
            c=coeffvalues(f);
            if (c(1) ~= param.MinP1) && (c(1) ~= param.MaxP1) && (c(2) ~= param.MinP2) && (c(2) ~= param.MaxP2)
                fz.ExpX = [];
                fz.ExpY = [];
                fz.Property(10) = c(1);
                fz.Property(11) = -1/c(2);
                fz.ExpX = xData(IndMinF:IndMaxF);
                fz.ExpY = c(1)*exp(c(2)*fz.ExpX);
                fz.AnalysisRepresentation(3) = 1;
            end
        end
        
    end
end

