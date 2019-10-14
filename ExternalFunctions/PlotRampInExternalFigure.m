function PlotRampInExternalFigure(FZ, RampXRepresentation, RampYRepresentation, RampDirection)

% Creates new figure
figure;
% Plots will only be shown if the corresponding
% current representations in the X and Y axes are
% available/calculated. Otherwise, an error message is
% displayed in the axes
if FZ.FZRepresentationX(RampXRepresentation) == 1 &&...
        FZ.FZRepresentationY(RampYRepresentation) == 1
	% Two "if" statemes are declared, depending on the value app.RampDirection
	% it is decided whether to plot the forward, the backward or both curves 
	if RampDirection==1 || RampDirection==3
        % Plot the forward fz ramp
        plot(FZ.XF(:,RampXRepresentation), FZ.YF(:,RampYRepresentation), 'o','MarkerSize',1);
        hold on;
        if RampXRepresentation ~= 1 && RampYRepresentation ~= 1 && RampYRepresentation ~= 2
            plot(FZ.HertzX(:, RampXRepresentation-1), FZ.HertzY(:,RampYRepresentation-2), 'g','LineWidth',2);
        end
        if RampXRepresentation == 3 && RampYRepresentation == 4 && FZ.AnalysisRepresentation(3) == 1
            plot(FZ.ExpX, FZ.ExpY, 'm','LineWidth',2);
        end
    end
	if RampDirection==2 || RampDirection==3
        % Plot the backward fz ramp
        plot(FZ.XB(:, RampXRepresentation),FZ.YB(:, RampYRepresentation), 'or','MarkerSize',1);
    end
	% Sets correct label for x axis
	switch RampXRepresentation
        case 1
            xlabel("Sample Vertical Displacement (nm)");
        case 2
            xlabel("Sample Vertical Displacement (nm) Offset Corrected");
        case 3
            xlabel("Probe-Sample Distance (nm)");
    end
	% Sets correct label for x axis
	switch RampYRepresentation
        case 1
            ylabel("Photodetector Signal (V)");
        case 2
            ylabel("Photodetector Signal (V) Offset Corrected");
        case 3
            ylabel("Deflection (nm)");
        case 4
            ylabel("Force (nN)");
    end
	grid on;
else
	text(0.2, 0.5, ...
        'FZ not available in the current representation');
end            