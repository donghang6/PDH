classdef PDHReflectionApp < handle
    % Interactive visualization of the Fabry-Perot reflection coefficient.
    % Model: symmetric, lossless cavity as used in Black, AJP 69, 79 (2001).

    properties (Access = private)
        Figure
        LengthField
        MirrorRField
        SpanField
        PointsField
        DetuningSlider
        FSRValueLabel
        FinesseValueLabel
        LinewidthValueLabel
        DetuningValueLabel
        MagnitudeValueLabel
        IntensityValueLabel
        PhaseValueLabel
        TransmissionMagnitudeValueLabel
        TransmissionIntensityValueLabel
        TransmissionPhaseValueLabel
        StatusLabel
        IntensityAxes
        PhaseAxes
        TransmissionIntensityAxes
        TransmissionPhaseAxes
        ComplexAxes
        IntensityMarker
        PhaseMarker
        TransmissionIntensityMarker
        TransmissionPhaseMarker
        ComplexMarker
        ComplexTransmissionMarker
        NormalizedDetuning
        ReflectionCoefficient
        TransmissionCoefficient
        FSRHz
    end

    methods
        function app = PDHReflectionApp
            app.createComponents();
            app.updatePlots();
        end

        function delete(app)
            if ~isempty(app.Figure) && isvalid(app.Figure)
                delete(app.Figure);
            end
        end
    end

    methods (Access = private)
        function createComponents(app)
            app.Figure = uifigure( ...
                'Name', 'Fabry-Perot 腔反射与透射系数分析', ...
                'Position', [60 60 1500 820], ...
                'Color', [0.97 0.97 0.97]);

            mainGrid = uigridlayout(app.Figure, [1 2]);
            mainGrid.ColumnWidth = {325, '1x'};
            mainGrid.RowHeight = {'1x'};
            mainGrid.Padding = [12 12 12 12];
            mainGrid.ColumnSpacing = 12;

            controlPanel = uipanel(mainGrid, 'Title', '参数与读数');
            controlPanel.Layout.Row = 1;
            controlPanel.Layout.Column = 1;

            controls = uigridlayout(controlPanel, [25 2]);
            controls.ColumnWidth = {145, '1x'};
            controls.RowHeight = {32, 34, 30, 30, 30, 30, 20, 24, 24, 24, ...
                8, 20, 38, 8, 24, 20, 24, 24, 24, 20, 24, 24, 24, 32, '1x'};
            controls.Padding = [12 12 12 12];
            controls.RowSpacing = 5;

            titleLabel = uilabel(controls, ...
                'Text', 'Black (2001) 对称无损腔模型', ...
                'FontSize', 15, 'FontWeight', 'bold', ...
                'HorizontalAlignment', 'center');
            titleLabel.Layout.Row = 1;
            titleLabel.Layout.Column = [1 2];

            modelLabel = uilabel(controls, ...
                'Text', ['F = r(e^{i\phi}-1)/(1-r^2e^{i\phi})' newline ...
                'T = (1-r^2)e^{i\phi/2}/(1-r^2e^{i\phi})'], ...
                'HorizontalAlignment', 'center', ...
                'FontName', 'Courier New', 'WordWrap', 'on');
            modelLabel.Layout.Row = 2;
            modelLabel.Layout.Column = [1 2];

            app.addControlLabel(controls, 3, '腔长 L (m)');
            app.LengthField = uieditfield(controls, 'numeric', ...
                'Value', 0.20, 'Limits', [1e-6 Inf], ...
                'ValueDisplayFormat', '%.6g');
            app.place(app.LengthField, 3, 2);

            app.addControlLabel(controls, 4, '单镜振幅反射率 r');
            app.MirrorRField = uieditfield(controls, 'numeric', ...
                'Value', 0.90, 'Limits', [1e-6 0.999999], ...
                'ValueDisplayFormat', '%.6f');
            app.place(app.MirrorRField, 4, 2);

            app.addControlLabel(controls, 5, '显示半宽 (FSR)');
            app.SpanField = uieditfield(controls, 'numeric', ...
                'Value', 0.50, 'Limits', [0.005 5], ...
                'ValueDisplayFormat', '%.4g');
            app.place(app.SpanField, 5, 2);

            app.addControlLabel(controls, 6, '采样点数');
            app.PointsField = uieditfield(controls, 'numeric', ...
                'Value', 1201, 'Limits', [101 20001], ...
                'RoundFractionalValues', 'on', ...
                'ValueDisplayFormat', '%.0f');
            app.place(app.PointsField, 6, 2);

            cavityLabel = uilabel(controls, 'Text', '腔参数（高精细度近似）', ...
                'FontWeight', 'bold');
            cavityLabel.Layout.Row = 7;
            cavityLabel.Layout.Column = [1 2];

            app.addControlLabel(controls, 8, '自由光谱范围');
            app.FSRValueLabel = app.addValueLabel(controls, 8);

            app.addControlLabel(controls, 9, '精细度 𝓕');
            app.FinesseValueLabel = app.addValueLabel(controls, 9);

            app.addControlLabel(controls, 10, '腔线宽');
            app.LinewidthValueLabel = app.addValueLabel(controls, 10);

            separator1 = uilabel(controls, 'Text', '');
            separator1.Layout.Row = 11;
            separator1.Layout.Column = [1 2];

            cursorTitle = uilabel(controls, 'Text', '失谐游标', ...
                'FontWeight', 'bold');
            cursorTitle.Layout.Row = 12;
            cursorTitle.Layout.Column = [1 2];

            app.DetuningSlider = uislider(controls, ...
                'Limits', [-0.5 0.5], 'Value', 0.05, ...
                'MajorTicks', [-0.5 0 0.5], ...
                'MajorTickLabels', {'-0.5', '0', '0.5'});
            app.DetuningSlider.Layout.Row = 13;
            app.DetuningSlider.Layout.Column = [1 2];

            separator2 = uilabel(controls, 'Text', '');
            separator2.Layout.Row = 14;
            separator2.Layout.Column = [1 2];

            app.addControlLabel(controls, 15, '失谐 Δν');
            app.DetuningValueLabel = app.addValueLabel(controls, 15);

            reflectionTitle = uilabel(controls, 'Text', '反射系数 F', ...
                'FontWeight', 'bold');
            reflectionTitle.Layout.Row = 16;
            reflectionTitle.Layout.Column = [1 2];

            app.addControlLabel(controls, 17, '振幅 |F|');
            app.MagnitudeValueLabel = app.addValueLabel(controls, 17);

            app.addControlLabel(controls, 18, '反射强度 |F|²');
            app.IntensityValueLabel = app.addValueLabel(controls, 18);

            app.addControlLabel(controls, 19, '反射相位 arg(F)');
            app.PhaseValueLabel = app.addValueLabel(controls, 19);

            transmissionTitle = uilabel(controls, 'Text', '透射系数 T', ...
                'FontWeight', 'bold');
            transmissionTitle.Layout.Row = 20;
            transmissionTitle.Layout.Column = [1 2];

            app.addControlLabel(controls, 21, '振幅 |T|');
            app.TransmissionMagnitudeValueLabel = app.addValueLabel(controls, 21);

            app.addControlLabel(controls, 22, '透射强度 |T|²');
            app.TransmissionIntensityValueLabel = app.addValueLabel(controls, 22);

            app.addControlLabel(controls, 23, '透射相位 arg(T)');
            app.TransmissionPhaseValueLabel = app.addValueLabel(controls, 23);

            buttonGrid = uigridlayout(controls, [1 2]);
            buttonGrid.Layout.Row = 24;
            buttonGrid.Layout.Column = [1 2];
            buttonGrid.ColumnWidth = {'1x', '1x'};
            buttonGrid.Padding = [0 0 0 0];
            resetButton = uibutton(buttonGrid, 'push', 'Text', '恢复默认值', ...
                'ButtonPushedFcn', @(~, ~) app.resetParameters());
            exportButton = uibutton(buttonGrid, 'push', 'Text', '导出 CSV', ...
                'ButtonPushedFcn', @(~, ~) app.exportData());
            resetButton.Layout.Column = 1;
            exportButton.Layout.Column = 2;

            app.StatusLabel = uilabel(controls, ...
                'Text', '移动游标可读取任意失谐点。', ...
                'WordWrap', 'on', ...
                'VerticalAlignment', 'top', ...
                'FontColor', [0.25 0.25 0.25]);
            app.StatusLabel.Layout.Row = 25;
            app.StatusLabel.Layout.Column = [1 2];

            plots = uigridlayout(mainGrid, [2 3]);
            plots.Layout.Row = 1;
            plots.Layout.Column = 2;
            plots.ColumnWidth = {'1x', '1x', '1.05x'};
            plots.RowHeight = {'1x', '1x'};
            plots.Padding = [0 0 0 0];
            plots.RowSpacing = 10;
            plots.ColumnSpacing = 10;

            app.IntensityAxes = uiaxes(plots);
            app.IntensityAxes.Layout.Row = 1;
            app.IntensityAxes.Layout.Column = 1;
            title(app.IntensityAxes, '归一化反射强度');
            xlabel(app.IntensityAxes, '归一化失谐  Δν / FSR');
            ylabel(app.IntensityAxes, '|F|^2');
            grid(app.IntensityAxes, 'on');

            app.PhaseAxes = uiaxes(plots);
            app.PhaseAxes.Layout.Row = 2;
            app.PhaseAxes.Layout.Column = 1;
            title(app.PhaseAxes, '反射场相位');
            xlabel(app.PhaseAxes, '归一化失谐  Δν / FSR');
            ylabel(app.PhaseAxes, 'arg(F) (deg)');
            grid(app.PhaseAxes, 'on');

            app.ComplexAxes = uiaxes(plots);
            app.ComplexAxes.Layout.Row = [1 2];
            app.ComplexAxes.Layout.Column = 3;
            title(app.ComplexAxes, '复系数轨迹');
            xlabel(app.ComplexAxes, '实部');
            ylabel(app.ComplexAxes, '虚部');
            grid(app.ComplexAxes, 'on');
            axis(app.ComplexAxes, 'equal');

            app.TransmissionIntensityAxes = uiaxes(plots);
            app.TransmissionIntensityAxes.Layout.Row = 1;
            app.TransmissionIntensityAxes.Layout.Column = 2;
            title(app.TransmissionIntensityAxes, '归一化透射强度');
            xlabel(app.TransmissionIntensityAxes, '归一化失谐  Δν / FSR');
            ylabel(app.TransmissionIntensityAxes, '|T|^2');
            grid(app.TransmissionIntensityAxes, 'on');

            app.TransmissionPhaseAxes = uiaxes(plots);
            app.TransmissionPhaseAxes.Layout.Row = 2;
            app.TransmissionPhaseAxes.Layout.Column = 2;
            title(app.TransmissionPhaseAxes, '透射场相位');
            xlabel(app.TransmissionPhaseAxes, '归一化失谐  Δν / FSR');
            ylabel(app.TransmissionPhaseAxes, 'arg(T) (deg)');
            grid(app.TransmissionPhaseAxes, 'on');

            fields = {app.LengthField, app.MirrorRField, ...
                app.SpanField, app.PointsField};
            for k = 1:numel(fields)
                fields{k}.ValueChangedFcn = @(~, ~) app.updatePlots();
            end
            app.DetuningSlider.ValueChangingFcn = ...
                @(~, event) app.updateMarker(event.Value);
            app.DetuningSlider.ValueChangedFcn = ...
                @(source, ~) app.updateMarker(source.Value);
        end

        function updatePlots(app)
            c = 299792458;
            L = app.LengthField.Value;
            r = app.MirrorRField.Value;
            span = app.SpanField.Value;
            nPoints = max(101, round(app.PointsField.Value));
            if mod(nPoints, 2) == 0
                nPoints = nPoints + 1;
                app.PointsField.Value = nPoints;
            end

            app.FSRHz = c / (2 * L);
            finesse = pi / (1 - r^2);
            linewidth = app.FSRHz / finesse;

            app.FSRValueLabel.Text = app.formatFrequency(app.FSRHz);
            app.FinesseValueLabel.Text = sprintf('%.4g', finesse);
            app.LinewidthValueLabel.Text = app.formatFrequency(linewidth);

            app.NormalizedDetuning = linspace(-span, span, nPoints);
            phi = 2 * pi * app.NormalizedDetuning;
            app.ReflectionCoefficient = ...
                r .* (exp(1i * phi) - 1) ./ (1 - r^2 .* exp(1i * phi));
            app.TransmissionCoefficient = ...
                (1 - r^2) .* exp(1i * phi / 2) ./ ...
                (1 - r^2 .* exp(1i * phi));

            reflectionIntensity = abs(app.ReflectionCoefficient).^2;
            reflectionPhaseDeg = rad2deg(angle(app.ReflectionCoefficient));
            reflectionPhaseDeg(abs(app.ReflectionCoefficient) < 1e-12) = NaN;
            transmissionIntensity = abs(app.TransmissionCoefficient).^2;
            transmissionPhaseDeg = rad2deg(angle(app.TransmissionCoefficient));

            cla(app.IntensityAxes);
            plot(app.IntensityAxes, app.NormalizedDetuning, reflectionIntensity, ...
                'LineWidth', 1.8, 'Color', [0.05 0.38 0.72]);
            hold(app.IntensityAxes, 'on');
            xline(app.IntensityAxes, 0, '--', '共振', ...
                'Color', [0.45 0.45 0.45], 'LabelVerticalAlignment', 'bottom');
            app.IntensityMarker = plot(app.IntensityAxes, 0, 0, 'o', ...
                'MarkerSize', 8, 'MarkerFaceColor', [0.88 0.22 0.17], ...
                'MarkerEdgeColor', 'white', 'LineWidth', 1.2);
            hold(app.IntensityAxes, 'off');
            xlim(app.IntensityAxes, [-span span]);
            ylim(app.IntensityAxes, [0 1.05]);
            grid(app.IntensityAxes, 'on');

            cla(app.PhaseAxes);
            plot(app.PhaseAxes, app.NormalizedDetuning, reflectionPhaseDeg, ...
                'LineWidth', 1.8, 'Color', [0.49 0.23 0.63]);
            hold(app.PhaseAxes, 'on');
            xline(app.PhaseAxes, 0, '--', 'Color', [0.45 0.45 0.45]);
            app.PhaseMarker = plot(app.PhaseAxes, NaN, NaN, 'o', ...
                'MarkerSize', 8, 'MarkerFaceColor', [0.88 0.22 0.17], ...
                'MarkerEdgeColor', 'white', 'LineWidth', 1.2);
            hold(app.PhaseAxes, 'off');
            xlim(app.PhaseAxes, [-span span]);
            ylim(app.PhaseAxes, [-190 190]);
            yticks(app.PhaseAxes, -180:90:180);
            grid(app.PhaseAxes, 'on');

            cla(app.TransmissionIntensityAxes);
            plot(app.TransmissionIntensityAxes, app.NormalizedDetuning, ...
                transmissionIntensity, 'LineWidth', 1.8, ...
                'Color', [0.91 0.48 0.10]);
            hold(app.TransmissionIntensityAxes, 'on');
            xline(app.TransmissionIntensityAxes, 0, '--', '共振', ...
                'Color', [0.45 0.45 0.45], ...
                'LabelVerticalAlignment', 'bottom');
            app.TransmissionIntensityMarker = plot( ...
                app.TransmissionIntensityAxes, 0, 1, 'o', ...
                'MarkerSize', 8, 'MarkerFaceColor', [0.88 0.22 0.17], ...
                'MarkerEdgeColor', 'white', 'LineWidth', 1.2);
            hold(app.TransmissionIntensityAxes, 'off');
            xlim(app.TransmissionIntensityAxes, [-span span]);
            ylim(app.TransmissionIntensityAxes, [0 1.05]);
            grid(app.TransmissionIntensityAxes, 'on');

            cla(app.TransmissionPhaseAxes);
            plot(app.TransmissionPhaseAxes, app.NormalizedDetuning, ...
                transmissionPhaseDeg, 'LineWidth', 1.8, ...
                'Color', [0.12 0.58 0.55]);
            hold(app.TransmissionPhaseAxes, 'on');
            xline(app.TransmissionPhaseAxes, 0, '--', ...
                'Color', [0.45 0.45 0.45]);
            app.TransmissionPhaseMarker = plot(app.TransmissionPhaseAxes, ...
                0, 0, 'o', 'MarkerSize', 8, ...
                'MarkerFaceColor', [0.88 0.22 0.17], ...
                'MarkerEdgeColor', 'white', 'LineWidth', 1.2);
            hold(app.TransmissionPhaseAxes, 'off');
            xlim(app.TransmissionPhaseAxes, [-span span]);
            ylim(app.TransmissionPhaseAxes, [-190 190]);
            yticks(app.TransmissionPhaseAxes, -180:90:180);
            grid(app.TransmissionPhaseAxes, 'on');

            cla(app.ComplexAxes);
            reflectionTrace = plot(app.ComplexAxes, ...
                real(app.ReflectionCoefficient), ...
                imag(app.ReflectionCoefficient), 'LineWidth', 1.8, ...
                'Color', [0.05 0.38 0.72], 'DisplayName', '反射 F');
            hold(app.ComplexAxes, 'on');
            transmissionTrace = plot(app.ComplexAxes, ...
                real(app.TransmissionCoefficient), ...
                imag(app.TransmissionCoefficient), 'LineWidth', 1.8, ...
                'Color', [0.91 0.48 0.10], 'DisplayName', '透射 T');
            xline(app.ComplexAxes, 0, ':', 'Color', [0.55 0.55 0.55]);
            yline(app.ComplexAxes, 0, ':', 'Color', [0.55 0.55 0.55]);
            app.ComplexMarker = plot(app.ComplexAxes, 0, 0, 'o', ...
                'MarkerSize', 9, 'MarkerFaceColor', [0.88 0.22 0.17], ...
                'MarkerEdgeColor', 'white', 'LineWidth', 1.2, ...
                'HandleVisibility', 'off');
            app.ComplexTransmissionMarker = plot(app.ComplexAxes, 1, 0, 's', ...
                'MarkerSize', 9, 'MarkerFaceColor', [0.55 0.15 0.80], ...
                'MarkerEdgeColor', 'white', 'LineWidth', 1.2, ...
                'HandleVisibility', 'off');
            hold(app.ComplexAxes, 'off');
            axis(app.ComplexAxes, 'equal');
            grid(app.ComplexAxes, 'on');
            legend(app.ComplexAxes, [reflectionTrace transmissionTrace], ...
                'Location', 'best');

            currentValue = min(max(app.DetuningSlider.Value, -span), span);
            app.DetuningSlider.Limits = [-span span];
            app.DetuningSlider.MajorTicks = [-span 0 span];
            app.DetuningSlider.MajorTickLabels = ...
                {sprintf('%.3g', -span), '0', sprintf('%.3g', span)};
            app.DetuningSlider.Value = currentValue;
            app.updateMarker(currentValue);
        end

        function updateMarker(app, normalizedDetuning)
            r = app.MirrorRField.Value;
            phi = 2 * pi * normalizedDetuning;
            F = r * (exp(1i * phi) - 1) / (1 - r^2 * exp(1i * phi));
            T = (1 - r^2) * exp(1i * phi / 2) / ...
                (1 - r^2 * exp(1i * phi));
            reflectionIntensity = abs(F)^2;
            transmissionIntensity = abs(T)^2;

            if ~isempty(app.IntensityMarker) && isvalid(app.IntensityMarker)
                app.IntensityMarker.XData = normalizedDetuning;
                app.IntensityMarker.YData = reflectionIntensity;
                app.TransmissionIntensityMarker.XData = normalizedDetuning;
                app.TransmissionIntensityMarker.YData = transmissionIntensity;
                app.TransmissionPhaseMarker.XData = normalizedDetuning;
                app.TransmissionPhaseMarker.YData = rad2deg(angle(T));
                app.ComplexMarker.XData = real(F);
                app.ComplexMarker.YData = imag(F);
                app.ComplexTransmissionMarker.XData = real(T);
                app.ComplexTransmissionMarker.YData = imag(T);
            end

            detuningHz = normalizedDetuning * app.FSRHz;
            app.DetuningValueLabel.Text = sprintf('%s  (%.5g FSR)', ...
                app.formatFrequency(detuningHz), normalizedDetuning);
            app.MagnitudeValueLabel.Text = sprintf('%.7f', abs(F));
            app.IntensityValueLabel.Text = sprintf('%.7f', reflectionIntensity);
            app.TransmissionMagnitudeValueLabel.Text = sprintf('%.7f', abs(T));
            app.TransmissionIntensityValueLabel.Text = ...
                sprintf('%.7f', transmissionIntensity);
            app.TransmissionPhaseValueLabel.Text = ...
                sprintf('%.4f°', rad2deg(angle(T)));

            if abs(F) < 1e-12
                app.PhaseValueLabel.Text = '未定义（F = 0）';
                if ~isempty(app.PhaseMarker) && isvalid(app.PhaseMarker)
                    app.PhaseMarker.XData = NaN;
                    app.PhaseMarker.YData = NaN;
                end
            else
                phaseDeg = rad2deg(angle(F));
                app.PhaseValueLabel.Text = sprintf('%.4f°', phaseDeg);
                if ~isempty(app.PhaseMarker) && isvalid(app.PhaseMarker)
                    app.PhaseMarker.XData = normalizedDetuning;
                    app.PhaseMarker.YData = phaseDeg;
                end
            end
            app.StatusLabel.Text = sprintf( ...
                '能量守恒校验：|F|² + |T|² = %.12f', ...
                reflectionIntensity + transmissionIntensity);
            drawnow limitrate;
        end

        function resetParameters(app)
            app.LengthField.Value = 0.20;
            app.MirrorRField.Value = 0.90;
            app.SpanField.Value = 0.50;
            app.PointsField.Value = 1201;
            app.DetuningSlider.Value = 0.05;
            app.updatePlots();
        end

        function exportData(app)
            [fileName, folder] = uiputfile('*.csv', '导出计算数据', ...
                'pdh_reflection_transmission_data.csv');
            if isequal(fileName, 0)
                app.StatusLabel.Text = '已取消导出。';
                return;
            end

            F = app.ReflectionCoefficient;
            T = app.TransmissionCoefficient;
            reflectionPhaseDeg = rad2deg(angle(F));
            reflectionPhaseDeg(abs(F) < 1e-12) = NaN;
            transmissionPhaseDeg = rad2deg(angle(T));
            data = table( ...
                app.NormalizedDetuning(:), ...
                app.NormalizedDetuning(:) .* app.FSRHz, ...
                real(F(:)), imag(F(:)), abs(F(:)), abs(F(:)).^2, ...
                reflectionPhaseDeg(:), real(T(:)), imag(T(:)), ...
                abs(T(:)), abs(T(:)).^2, transmissionPhaseDeg(:), ...
                'VariableNames', {'DetuningOverFSR', 'DetuningHz', ...
                'RealF', 'ImagF', 'MagnitudeF', 'ReflectionIntensity', ...
                'ReflectionPhaseDeg', 'RealT', 'ImagT', 'MagnitudeT', ...
                'TransmissionIntensity', 'TransmissionPhaseDeg'});
            writetable(data, fullfile(folder, fileName));
            app.StatusLabel.Text = ['数据已导出：' fullfile(folder, fileName)];
        end

        function label = addValueLabel(~, parent, row)
            label = uilabel(parent, 'Text', '--', ...
                'HorizontalAlignment', 'right', 'FontWeight', 'bold');
            label.Layout.Row = row;
            label.Layout.Column = 2;
        end

        function addControlLabel(~, parent, row, textValue)
            label = uilabel(parent, 'Text', textValue);
            label.Layout.Row = row;
            label.Layout.Column = 1;
        end

        function place(~, component, row, column)
            component.Layout.Row = row;
            component.Layout.Column = column;
        end

        function textValue = formatFrequency(~, frequencyHz)
            absFrequency = abs(frequencyHz);
            if absFrequency >= 1e9
                textValue = sprintf('%.6g GHz', frequencyHz / 1e9);
            elseif absFrequency >= 1e6
                textValue = sprintf('%.6g MHz', frequencyHz / 1e6);
            elseif absFrequency >= 1e3
                textValue = sprintf('%.6g kHz', frequencyHz / 1e3);
            else
                textValue = sprintf('%.6g Hz', frequencyHz);
            end
        end
    end
end
