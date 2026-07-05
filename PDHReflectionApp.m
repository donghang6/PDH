classdef PDHReflectionApp < handle
    % Fabry-Perot cavity response and first-order PDH modulation model.
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
        PDHVpiField
        PDHBetaField
        PDHDriveVppValueLabel
        PDHModulationFrequencyField
        PDHCarrierDetuningField
        PDHIncidentPowerField
        PDHPeriodsField
        PDHFSRValueLabel
        PDHMirrorRValueLabel
        PDHDCValueLabel
        PDHBeatFundamentalLabel
        PDHBeatSecondHarmonicLabel
        PDHTruncatedPowerLabel
        PDHStatusLabel
        PDHFieldAxes
        PDHPowerAxes
        PDHSpectrumAxes
        PDHComponentTable
        PDHFilterCenterField
        PDHFilterBandwidthField
        PDHFilterOrderField
        PDHFilterSampleRateField
        PDHFilterWindowField
        PDHFilterLowCutoffLabel
        PDHFilterHighCutoffLabel
        PDHFilterFundamentalGainLabel
        PDHFilterSecondHarmonicGainLabel
        PDHFilterRMSLabel
        PDHFilterStatusLabel
        PDHFilterRawAxes
        PDHFilterOutputAxes
        PDHFilterSpectrumAxes
        PDHFilterResponseAxes
        PDHFilterTimeSeconds
        PDHFilterRawPowerMW
        PDHFilterOutputMW
        PDHFilterSampleRateHz
        PDHMixerLOFrequencyField
        PDHMixerPhaseField
        PDHMixerAmplitudeField
        PDHMixerDifferenceFrequencyLabel
        PDHMixerMeanLabel
        PDHMixerRMSLabel
        PDHMixerStatusLabel
        PDHMixerInputAxes
        PDHMixerLOAxes
        PDHMixerOutputAxes
        PDHMixerSpectrumAxes
        PDHMixerTimeSeconds
        PDHMixerOutputSignal
        PDHMixerSampleRateHz
        PDHErrorPIDBandwidthField
        PDHErrorLowpassCutoffField
        PDHErrorLowpassOrderField
        PDHErrorGainAtPIDLabel
        PDHErrorGainAt2FMLabel
        PDHErrorCurrentValueLabel
        PDHErrorSlopeLabel
        PDHErrorStatusLabel
        PDHErrorMixerAxes
        PDHErrorLowpassAxes
        PDHErrorCurveAxes
        PDHErrorResponseAxes
        ChainVpiField
        ChainBetaField
        ChainDriveVppValueLabel
        ChainModulationFrequencyField
        ChainIncidentPowerField
        ChainDetuningField
        ChainLengthField
        ChainMirrorIntensityField
        ChainMirrorAmplitudeLabel
        ChainFSRLabel
        ChainDetectorBandwidthField
        ChainDetectorGainLabel
        ChainBandCenterField
        ChainBandWidthField
        ChainBandOrderField
        ChainBandGainLabel
        ChainLOFrequencyField
        ChainLOPhaseField
        ChainLOAmplitudeField
        ChainPIDBandwidthField
        ChainLowpassCutoffField
        ChainLowpassOrderField
        ChainLowpassGainLabel
        ChainCurrentErrorLabel
        ChainSlopeLabel
        ChainPolarityLabel
        ChainStatusLabel
        ChainErrorAxes
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

            rootGrid = uigridlayout(app.Figure, [1 1]);
            rootGrid.Padding = [8 8 8 8];

            tabGroup = uitabgroup(rootGrid);
            tabGroup.Layout.Row = 1;
            tabGroup.Layout.Column = 1;

            cavityResponseTab = uitab(tabGroup, 'Title', '腔响应');
            modulationTab = uitab(tabGroup, 'Title', 'PDH 调制');
            chainTab = uitab(tabGroup, 'Title', '完整链路');
            app.createPDHComponents(modulationTab);
            app.createFullChainComponents(chainTab);

            mainGrid = uigridlayout(cavityResponseTab, [1 2]);
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

        function createPDHComponents(app, parentTab)
            tabGrid = uigridlayout(parentTab, [1 1]);
            tabGrid.Padding = [0 0 0 0];
            pdhTabGroup = uitabgroup(tabGrid);
            pdhTabGroup.Layout.Row = 1;
            pdhTabGroup.Layout.Column = 1;
            beatTab = uitab(pdhTabGroup, 'Title', '反射拍频');
            filterTab = uitab(pdhTabGroup, 'Title', '带通滤波');
            mixerTab = uitab(pdhTabGroup, 'Title', '混频');
            errorTab = uitab(pdhTabGroup, 'Title', '低通与误差信号');

            parentTab = beatTab;
            mainGrid = uigridlayout(parentTab, [1 2]);
            mainGrid.ColumnWidth = {330, '1x'};
            mainGrid.RowHeight = {'1x'};
            mainGrid.Padding = [12 12 12 12];
            mainGrid.ColumnSpacing = 12;

            controlPanel = uipanel(mainGrid, 'Title', 'EOM 与拍频参数');
            controlPanel.Layout.Row = 1;
            controlPanel.Layout.Column = 1;

            controls = uigridlayout(controlPanel, [20 2]);
            controls.ColumnWidth = {150, '1x'};
            controls.RowHeight = {32, 74, 31, 31, 26, 31, 31, 31, 31, ...
                8, 20, 24, 24, 8, 20, 26, 26, 26, 26, '1x'};
            controls.Padding = [12 12 12 12];
            controls.RowSpacing = 6;

            titleLabel = uilabel(controls, ...
                'Text', '反射光场与探测器拍频', ...
                'FontSize', 15, 'FontWeight', 'bold', ...
                'HorizontalAlignment', 'center');
            titleLabel.Layout.Row = 1;
            titleLabel.Layout.Column = [1 2];

            formulaLabel = uilabel(controls, ...
                'Text', ['一阶边带近似：' newline ...
                'Vpp = 2βVπ/π' newline ...
                'Eref = e^{iωt}[A_0 + A_+e^{iΩt} + A_-e^{-iΩt}]' newline ...
                'Pdet = |A_0 + A_+e^{iΩt} + A_-e^{-iΩt}|^2'], ...
                'FontName', 'Courier New', ...
                'FontSize', 11, ...
                'WordWrap', 'on', ...
                'HorizontalAlignment', 'center');
            formulaLabel.Layout.Row = 2;
            formulaLabel.Layout.Column = [1 2];

            app.addControlLabel(controls, 3, '半波电压 Vπ (V)');
            app.PDHVpiField = uieditfield(controls, 'numeric', ...
                'Value', 5, 'Limits', [eps Inf], ...
                'ValueDisplayFormat', '%.7g');
            app.place(app.PDHVpiField, 3, 2);

            app.addControlLabel(controls, 4, '调制深度 β (rad)');
            app.PDHBetaField = uieditfield(controls, 'numeric', ...
                'Value', 0.30, 'Limits', [0 Inf], ...
                'ValueDisplayFormat', '%.7g');
            app.place(app.PDHBetaField, 4, 2);

            app.addControlLabel(controls, 5, '计算驱动 Vpp');
            app.PDHDriveVppValueLabel = app.addValueLabel(controls, 5);

            app.addControlLabel(controls, 6, '调制频率 f_m (MHz)');
            app.PDHModulationFrequencyField = uieditfield(controls, 'numeric', ...
                'Value', 20, 'Limits', [1e-6 Inf], ...
                'ValueDisplayFormat', '%.7g');
            app.place(app.PDHModulationFrequencyField, 6, 2);

            app.addControlLabel(controls, 7, '载波失谐 Δf (MHz)');
            app.PDHCarrierDetuningField = uieditfield(controls, 'numeric', ...
                'Value', 1, 'ValueDisplayFormat', '%.7g');
            app.place(app.PDHCarrierDetuningField, 7, 2);

            app.addControlLabel(controls, 8, '入射功率 P_0 (mW)');
            app.PDHIncidentPowerField = uieditfield(controls, 'numeric', ...
                'Value', 1, 'Limits', [1e-12 Inf], ...
                'ValueDisplayFormat', '%.7g');
            app.place(app.PDHIncidentPowerField, 8, 2);

            app.addControlLabel(controls, 9, '显示周期数');
            app.PDHPeriodsField = uieditfield(controls, 'numeric', ...
                'Value', 3, 'Limits', [1 20], ...
                'RoundFractionalValues', 'on', ...
                'ValueDisplayFormat', '%.0f');
            app.place(app.PDHPeriodsField, 9, 2);

            separator1 = uilabel(controls, 'Text', '');
            separator1.Layout.Row = 10;
            separator1.Layout.Column = [1 2];

            cavityTitle = uilabel(controls, ...
                'Text', '关联“腔响应”标签页参数', ...
                'FontWeight', 'bold');
            cavityTitle.Layout.Row = 11;
            cavityTitle.Layout.Column = [1 2];

            app.addControlLabel(controls, 12, '自由光谱范围');
            app.PDHFSRValueLabel = app.addValueLabel(controls, 12);

            app.addControlLabel(controls, 13, '单镜振幅反射率');
            app.PDHMirrorRValueLabel = app.addValueLabel(controls, 13);

            separator2 = uilabel(controls, 'Text', '');
            separator2.Layout.Row = 14;
            separator2.Layout.Column = [1 2];

            beatTitle = uilabel(controls, 'Text', '探测器功率分量', ...
                'FontWeight', 'bold');
            beatTitle.Layout.Row = 15;
            beatTitle.Layout.Column = [1 2];

            app.addControlLabel(controls, 16, '直流分量');
            app.PDHDCValueLabel = app.addValueLabel(controls, 16);

            app.addControlLabel(controls, 17, 'f_m 拍频');
            app.PDHBeatFundamentalLabel = app.addValueLabel(controls, 17);

            app.addControlLabel(controls, 18, '2f_m 拍频');
            app.PDHBeatSecondHarmonicLabel = app.addValueLabel(controls, 18);

            app.addControlLabel(controls, 19, '保留的入射功率');
            app.PDHTruncatedPowerLabel = app.addValueLabel(controls, 19);

            app.PDHStatusLabel = uilabel(controls, ...
                'Text', '当前仅计算反射光场与光电探测器功率。', ...
                'WordWrap', 'on', ...
                'VerticalAlignment', 'top', ...
                'FontColor', [0.30 0.30 0.30]);
            app.PDHStatusLabel.Layout.Row = 20;
            app.PDHStatusLabel.Layout.Column = [1 2];

            resultsGrid = uigridlayout(mainGrid, [2 2]);
            resultsGrid.Layout.Row = 1;
            resultsGrid.Layout.Column = 2;
            resultsGrid.ColumnWidth = {'1x', '1x'};
            resultsGrid.RowHeight = {'1x', '1x'};
            resultsGrid.Padding = [0 0 0 0];
            resultsGrid.RowSpacing = 10;
            resultsGrid.ColumnSpacing = 10;

            app.PDHFieldAxes = uiaxes(resultsGrid);
            app.PDHFieldAxes.Layout.Row = 1;
            app.PDHFieldAxes.Layout.Column = 1;
            title(app.PDHFieldAxes, '反射光场慢变包络');
            xlabel(app.PDHFieldAxes, '时间  f_m t（调制周期）');
            ylabel(app.PDHFieldAxes, '场幅 / sqrt(mW)');
            grid(app.PDHFieldAxes, 'on');

            app.PDHPowerAxes = uiaxes(resultsGrid);
            app.PDHPowerAxes.Layout.Row = 2;
            app.PDHPowerAxes.Layout.Column = 1;
            title(app.PDHPowerAxes, '探测器上的拍频功率');
            xlabel(app.PDHPowerAxes, '时间  f_m t（调制周期）');
            ylabel(app.PDHPowerAxes, 'P_{det} (mW)');
            grid(app.PDHPowerAxes, 'on');

            app.PDHSpectrumAxes = uiaxes(resultsGrid);
            app.PDHSpectrumAxes.Layout.Row = 1;
            app.PDHSpectrumAxes.Layout.Column = 2;
            title(app.PDHSpectrumAxes, '反射载波与一阶边带');
            xlabel(app.PDHSpectrumAxes, '相对载波频率 (MHz)');
            ylabel(app.PDHSpectrumAxes, '分量功率 (mW)');
            grid(app.PDHSpectrumAxes, 'on');

            app.PDHComponentTable = uitable(resultsGrid, ...
                'ColumnName', {'频偏/MHz', 'EOM系数', 'Re(A)/sqrt(mW)', ...
                'Im(A)/sqrt(mW)', '功率/mW', '相位/deg'}, ...
                'RowName', {'下边带', '载波', '上边带'}, ...
                'ColumnEditable', false(1, 6));
            app.PDHComponentTable.Layout.Row = 2;
            app.PDHComponentTable.Layout.Column = 2;

            fields = {app.PDHVpiField, app.PDHBetaField, ...
                app.PDHModulationFrequencyField, ...
                app.PDHCarrierDetuningField, ...
                app.PDHIncidentPowerField, app.PDHPeriodsField};
            for k = 1:numel(fields)
                fields{k}.ValueChangedFcn = @(~, ~) app.updatePDHPlots();
            end

            app.createPDHFilterComponents(filterTab);
            app.createPDHMixerComponents(mixerTab);
            app.createPDHErrorComponents(errorTab);
        end

        function createPDHFilterComponents(app, parentTab)
            mainGrid = uigridlayout(parentTab, [1 2]);
            mainGrid.ColumnWidth = {330, '1x'};
            mainGrid.RowHeight = {'1x'};
            mainGrid.Padding = [12 12 12 12];
            mainGrid.ColumnSpacing = 12;

            controlPanel = uipanel(mainGrid, 'Title', '带通滤波设置');
            controlPanel.Layout.Row = 1;
            controlPanel.Layout.Column = 1;

            controls = uigridlayout(controlPanel, [16 2]);
            controls.ColumnWidth = {155, '1x'};
            controls.RowHeight = {32, 52, 31, 31, 31, 31, 31, 34, 8, ...
                20, 24, 24, 24, 24, 24, '1x'};
            controls.Padding = [12 12 12 12];
            controls.RowSpacing = 6;

            titleLabel = uilabel(controls, ...
                'Text', '探测器信号带通滤波', ...
                'FontSize', 15, 'FontWeight', 'bold', ...
                'HorizontalAlignment', 'center');
            titleLabel.Layout.Row = 1;
            titleLabel.Layout.Column = [1 2];

            noteLabel = uilabel(controls, ...
                'Text', ['对 Pdet(t) 进行零相位 Butterworth 型频域滤波。' ...
                '输出是去除直流后的交流拍频分量，可为负值。'], ...
                'WordWrap', 'on', ...
                'HorizontalAlignment', 'center', ...
                'FontColor', [0.30 0.30 0.30]);
            noteLabel.Layout.Row = 2;
            noteLabel.Layout.Column = [1 2];

            app.addControlLabel(controls, 3, '中心频率 f_c (MHz)');
            app.PDHFilterCenterField = uieditfield(controls, 'numeric', ...
                'Value', 20, 'Limits', [1e-6 Inf], ...
                'ValueDisplayFormat', '%.7g');
            app.place(app.PDHFilterCenterField, 3, 2);

            app.addControlLabel(controls, 4, '3 dB 带宽 BW (MHz)');
            app.PDHFilterBandwidthField = uieditfield(controls, 'numeric', ...
                'Value', 10, 'Limits', [1e-6 Inf], ...
                'ValueDisplayFormat', '%.7g');
            app.place(app.PDHFilterBandwidthField, 4, 2);

            app.addControlLabel(controls, 5, '滤波器阶数');
            app.PDHFilterOrderField = uieditfield(controls, 'numeric', ...
                'Value', 4, 'Limits', [1 12], ...
                'RoundFractionalValues', 'on', ...
                'ValueDisplayFormat', '%.0f');
            app.place(app.PDHFilterOrderField, 5, 2);

            app.addControlLabel(controls, 6, '采样率 (MS/s)');
            app.PDHFilterSampleRateField = uieditfield(controls, 'numeric', ...
                'Value', 500, 'Limits', [1e-3 Inf], ...
                'ValueDisplayFormat', '%.7g');
            app.place(app.PDHFilterSampleRateField, 6, 2);

            app.addControlLabel(controls, 7, '时间窗口 (us)');
            app.PDHFilterWindowField = uieditfield(controls, 'numeric', ...
                'Value', 2, 'Limits', [1e-3 1e3], ...
                'ValueDisplayFormat', '%.7g');
            app.place(app.PDHFilterWindowField, 7, 2);

            centerButton = uibutton(controls, 'push', ...
                'Text', '将通带中心设为当前 f_m', ...
                'ButtonPushedFcn', @(~, ~) app.centerFilterOnModulation());
            centerButton.Layout.Row = 8;
            centerButton.Layout.Column = [1 2];

            separator = uilabel(controls, 'Text', '');
            separator.Layout.Row = 9;
            separator.Layout.Column = [1 2];

            resultTitle = uilabel(controls, 'Text', '滤波结果', ...
                'FontWeight', 'bold');
            resultTitle.Layout.Row = 10;
            resultTitle.Layout.Column = [1 2];

            app.addControlLabel(controls, 11, '低截止频率');
            app.PDHFilterLowCutoffLabel = app.addValueLabel(controls, 11);

            app.addControlLabel(controls, 12, '高截止频率');
            app.PDHFilterHighCutoffLabel = app.addValueLabel(controls, 12);

            app.addControlLabel(controls, 13, '|H(f_m)|');
            app.PDHFilterFundamentalGainLabel = app.addValueLabel(controls, 13);

            app.addControlLabel(controls, 14, '|H(2f_m)|');
            app.PDHFilterSecondHarmonicGainLabel = app.addValueLabel(controls, 14);

            app.addControlLabel(controls, 15, '输出 RMS');
            app.PDHFilterRMSLabel = app.addValueLabel(controls, 15);

            app.PDHFilterStatusLabel = uilabel(controls, ...
                'Text', '等待计算。', ...
                'WordWrap', 'on', ...
                'VerticalAlignment', 'top', ...
                'FontColor', [0.30 0.30 0.30]);
            app.PDHFilterStatusLabel.Layout.Row = 16;
            app.PDHFilterStatusLabel.Layout.Column = [1 2];

            plots = uigridlayout(mainGrid, [2 2]);
            plots.Layout.Row = 1;
            plots.Layout.Column = 2;
            plots.ColumnWidth = {'1x', '1x'};
            plots.RowHeight = {'1x', '1x'};
            plots.Padding = [0 0 0 0];
            plots.RowSpacing = 10;
            plots.ColumnSpacing = 10;

            app.PDHFilterRawAxes = uiaxes(plots);
            app.PDHFilterRawAxes.Layout.Row = 1;
            app.PDHFilterRawAxes.Layout.Column = 1;
            title(app.PDHFilterRawAxes, '滤波前：探测器功率');
            xlabel(app.PDHFilterRawAxes, '时间  f_m t（调制周期）');
            ylabel(app.PDHFilterRawAxes, 'P_{det} (mW)');
            grid(app.PDHFilterRawAxes, 'on');

            app.PDHFilterOutputAxes = uiaxes(plots);
            app.PDHFilterOutputAxes.Layout.Row = 1;
            app.PDHFilterOutputAxes.Layout.Column = 2;
            title(app.PDHFilterOutputAxes, '滤波后：交流拍频分量');
            xlabel(app.PDHFilterOutputAxes, '时间  f_m t（调制周期）');
            ylabel(app.PDHFilterOutputAxes, '带通输出 (mW)');
            grid(app.PDHFilterOutputAxes, 'on');

            app.PDHFilterSpectrumAxes = uiaxes(plots);
            app.PDHFilterSpectrumAxes.Layout.Row = 2;
            app.PDHFilterSpectrumAxes.Layout.Column = 1;
            title(app.PDHFilterSpectrumAxes, '滤波前后单边幅度谱');
            xlabel(app.PDHFilterSpectrumAxes, '频率 (MHz)');
            ylabel(app.PDHFilterSpectrumAxes, '幅度 (mW)');
            grid(app.PDHFilterSpectrumAxes, 'on');

            app.PDHFilterResponseAxes = uiaxes(plots);
            app.PDHFilterResponseAxes.Layout.Row = 2;
            app.PDHFilterResponseAxes.Layout.Column = 2;
            title(app.PDHFilterResponseAxes, '带通滤波器幅频响应');
            xlabel(app.PDHFilterResponseAxes, '频率 (MHz)');
            ylabel(app.PDHFilterResponseAxes, '|H(f)|');
            grid(app.PDHFilterResponseAxes, 'on');

            fields = {app.PDHFilterCenterField, ...
                app.PDHFilterBandwidthField, app.PDHFilterOrderField, ...
                app.PDHFilterSampleRateField, app.PDHFilterWindowField};
            for k = 1:numel(fields)
                fields{k}.ValueChangedFcn = @(~, ~) app.updatePDHFilterPlots();
            end
        end

        function createPDHMixerComponents(app, parentTab)
            mainGrid = uigridlayout(parentTab, [1 2]);
            mainGrid.ColumnWidth = {330, '1x'};
            mainGrid.RowHeight = {'1x'};
            mainGrid.Padding = [12 12 12 12];
            mainGrid.ColumnSpacing = 12;

            controlPanel = uipanel(mainGrid, 'Title', '混频设置');
            controlPanel.Layout.Row = 1;
            controlPanel.Layout.Column = 1;

            controls = uigridlayout(controlPanel, [12 2]);
            controls.ColumnWidth = {155, '1x'};
            controls.RowHeight = {32, 72, 31, 31, 31, 34, 8, 20, ...
                26, 26, 26, '1x'};
            controls.Padding = [12 12 12 12];
            controls.RowSpacing = 7;

            titleLabel = uilabel(controls, ...
                'Text', '本地振荡器混频', ...
                'FontSize', 15, 'FontWeight', 'bold', ...
                'HorizontalAlignment', 'center');
            titleLabel.Layout.Row = 1;
            titleLabel.Layout.Column = [1 2];

            formulaLabel = uilabel(controls, ...
                'Text', ['VLO(t) = (VLO,pp/2) sin(2*pi*fLO*t + phiLO)' ...
                newline 'Vmix(t) = PBPF(t) VLO(t)' ...
                newline '当前只执行乘法混频，尚未低通滤波。'], ...
                'FontName', 'Courier New', ...
                'WordWrap', 'on', ...
                'HorizontalAlignment', 'center');
            formulaLabel.Layout.Row = 2;
            formulaLabel.Layout.Column = [1 2];

            app.addControlLabel(controls, 3, 'LO 频率 (MHz)');
            app.PDHMixerLOFrequencyField = uieditfield(controls, 'numeric', ...
                'Value', 20, 'Limits', [1e-6 Inf], ...
                'ValueDisplayFormat', '%.7g');
            app.place(app.PDHMixerLOFrequencyField, 3, 2);

            app.addControlLabel(controls, 4, 'LO 相位 (deg)');
            app.PDHMixerPhaseField = uieditfield(controls, 'numeric', ...
                'Value', 0, 'Limits', [-360 360], ...
                'ValueDisplayFormat', '%.7g');
            app.place(app.PDHMixerPhaseField, 4, 2);

            app.addControlLabel(controls, 5, 'LO 峰峰值 Vpp (V)');
            app.PDHMixerAmplitudeField = uieditfield(controls, 'numeric', ...
                'Value', 2, 'Limits', [0 Inf], ...
                'ValueDisplayFormat', '%.7g');
            app.place(app.PDHMixerAmplitudeField, 5, 2);

            syncButton = uibutton(controls, 'push', ...
                'Text', '将 LO 频率设为当前 f_m', ...
                'ButtonPushedFcn', @(~, ~) app.syncMixerToModulation());
            syncButton.Layout.Row = 6;
            syncButton.Layout.Column = [1 2];

            separator = uilabel(controls, 'Text', '');
            separator.Layout.Row = 7;
            separator.Layout.Column = [1 2];

            resultTitle = uilabel(controls, 'Text', '混频结果', ...
                'FontWeight', 'bold');
            resultTitle.Layout.Row = 8;
            resultTitle.Layout.Column = [1 2];

            app.addControlLabel(controls, 9, '|f_LO - f_m|');
            app.PDHMixerDifferenceFrequencyLabel = app.addValueLabel(controls, 9);

            app.addControlLabel(controls, 10, '输出平均值');
            app.PDHMixerMeanLabel = app.addValueLabel(controls, 10);

            app.addControlLabel(controls, 11, '输出 RMS');
            app.PDHMixerRMSLabel = app.addValueLabel(controls, 11);

            app.PDHMixerStatusLabel = uilabel(controls, ...
                'Text', '等待计算。', ...
                'WordWrap', 'on', ...
                'VerticalAlignment', 'top', ...
                'FontColor', [0.30 0.30 0.30]);
            app.PDHMixerStatusLabel.Layout.Row = 12;
            app.PDHMixerStatusLabel.Layout.Column = [1 2];

            plots = uigridlayout(mainGrid, [2 2]);
            plots.Layout.Row = 1;
            plots.Layout.Column = 2;
            plots.ColumnWidth = {'1x', '1x'};
            plots.RowHeight = {'1x', '1x'};
            plots.Padding = [0 0 0 0];
            plots.RowSpacing = 10;
            plots.ColumnSpacing = 10;

            app.PDHMixerInputAxes = uiaxes(plots);
            app.PDHMixerInputAxes.Layout.Row = 1;
            app.PDHMixerInputAxes.Layout.Column = 1;
            title(app.PDHMixerInputAxes, '混频器输入：带通输出');
            xlabel(app.PDHMixerInputAxes, '时间  f_m t（调制周期）');
            ylabel(app.PDHMixerInputAxes, 'P_{BPF} (mW)');
            grid(app.PDHMixerInputAxes, 'on');

            app.PDHMixerLOAxes = uiaxes(plots);
            app.PDHMixerLOAxes.Layout.Row = 1;
            app.PDHMixerLOAxes.Layout.Column = 2;
            title(app.PDHMixerLOAxes, '本地振荡器');
            xlabel(app.PDHMixerLOAxes, '时间  f_m t（调制周期）');
            ylabel(app.PDHMixerLOAxes, 'V_{LO} (V)');
            grid(app.PDHMixerLOAxes, 'on');

            app.PDHMixerOutputAxes = uiaxes(plots);
            app.PDHMixerOutputAxes.Layout.Row = 2;
            app.PDHMixerOutputAxes.Layout.Column = 1;
            title(app.PDHMixerOutputAxes, '混频器输出（未低通）');
            xlabel(app.PDHMixerOutputAxes, '时间  f_m t（调制周期）');
            ylabel(app.PDHMixerOutputAxes, 'V_{mix} (mW-equivalent)');
            grid(app.PDHMixerOutputAxes, 'on');

            app.PDHMixerSpectrumAxes = uiaxes(plots);
            app.PDHMixerSpectrumAxes.Layout.Row = 2;
            app.PDHMixerSpectrumAxes.Layout.Column = 2;
            title(app.PDHMixerSpectrumAxes, '混频输出单边幅度谱');
            xlabel(app.PDHMixerSpectrumAxes, '频率 (MHz)');
            ylabel(app.PDHMixerSpectrumAxes, '幅度 (mW-equivalent)');
            grid(app.PDHMixerSpectrumAxes, 'on');

            fields = {app.PDHMixerLOFrequencyField, ...
                app.PDHMixerPhaseField, app.PDHMixerAmplitudeField};
            for k = 1:numel(fields)
                fields{k}.ValueChangedFcn = @(~, ~) app.updatePDHMixerPlots();
            end
        end

        function createPDHErrorComponents(app, parentTab)
            mainGrid = uigridlayout(parentTab, [1 2]);
            mainGrid.ColumnWidth = {330, '1x'};
            mainGrid.RowHeight = {'1x'};
            mainGrid.Padding = [12 12 12 12];
            mainGrid.ColumnSpacing = 12;

            controlPanel = uipanel(mainGrid, 'Title', '低通与环路带宽');
            controlPanel.Layout.Row = 1;
            controlPanel.Layout.Column = 1;

            controls = uigridlayout(controlPanel, [13 2]);
            controls.ColumnWidth = {160, '1x'};
            controls.RowHeight = {32, 62, 31, 31, 31, 34, 8, 20, ...
                26, 26, 26, 26, '1x'};
            controls.Padding = [12 12 12 12];
            controls.RowSpacing = 7;

            titleLabel = uilabel(controls, ...
                'Text', '低通滤波与 PDH 误差信号', ...
                'FontSize', 15, 'FontWeight', 'bold', ...
                'HorizontalAlignment', 'center');
            titleLabel.Layout.Row = 1;
            titleLabel.Layout.Column = [1 2];

            noteLabel = uilabel(controls, ...
                'Text', ['PID 目标带宽为 100 kHz。默认低通截止为其 5 倍，' ...
                '减少环路带宽处的幅度损失。'], ...
                'WordWrap', 'on', ...
                'HorizontalAlignment', 'center', ...
                'FontColor', [0.30 0.30 0.30]);
            noteLabel.Layout.Row = 2;
            noteLabel.Layout.Column = [1 2];

            app.addControlLabel(controls, 3, 'PID 带宽 (kHz)');
            app.PDHErrorPIDBandwidthField = uieditfield(controls, 'numeric', ...
                'Value', 100, 'Limits', [1e-3 Inf], ...
                'ValueDisplayFormat', '%.7g');
            app.place(app.PDHErrorPIDBandwidthField, 3, 2);

            app.addControlLabel(controls, 4, '低通截止频率 (kHz)');
            app.PDHErrorLowpassCutoffField = uieditfield(controls, 'numeric', ...
                'Value', 500, 'Limits', [1e-3 Inf], ...
                'ValueDisplayFormat', '%.7g');
            app.place(app.PDHErrorLowpassCutoffField, 4, 2);

            app.addControlLabel(controls, 5, '低通滤波器阶数');
            app.PDHErrorLowpassOrderField = uieditfield(controls, 'numeric', ...
                'Value', 4, 'Limits', [1 12], ...
                'RoundFractionalValues', 'on', ...
                'ValueDisplayFormat', '%.0f');
            app.place(app.PDHErrorLowpassOrderField, 5, 2);

            cutoffButton = uibutton(controls, 'push', ...
                'Text', '截止频率设为 5 × PID 带宽', ...
                'ButtonPushedFcn', @(~, ~) app.setLowpassFromPIDBandwidth());
            cutoffButton.Layout.Row = 6;
            cutoffButton.Layout.Column = [1 2];

            separator = uilabel(controls, 'Text', '');
            separator.Layout.Row = 7;
            separator.Layout.Column = [1 2];

            resultTitle = uilabel(controls, 'Text', '误差信号结果', ...
                'FontWeight', 'bold');
            resultTitle.Layout.Row = 8;
            resultTitle.Layout.Column = [1 2];

            app.addControlLabel(controls, 9, '|H_LP(B_PID)|');
            app.PDHErrorGainAtPIDLabel = app.addValueLabel(controls, 9);

            app.addControlLabel(controls, 10, '|H_LP(2f_m)|');
            app.PDHErrorGainAt2FMLabel = app.addValueLabel(controls, 10);

            app.addControlLabel(controls, 11, '当前误差信号');
            app.PDHErrorCurrentValueLabel = app.addValueLabel(controls, 11);

            app.addControlLabel(controls, 12, '共振点斜率');
            app.PDHErrorSlopeLabel = app.addValueLabel(controls, 12);

            app.PDHErrorStatusLabel = uilabel(controls, ...
                'Text', '等待计算。', ...
                'WordWrap', 'on', ...
                'VerticalAlignment', 'top', ...
                'FontColor', [0.30 0.30 0.30]);
            app.PDHErrorStatusLabel.Layout.Row = 13;
            app.PDHErrorStatusLabel.Layout.Column = [1 2];

            plots = uigridlayout(mainGrid, [2 2]);
            plots.Layout.Row = 1;
            plots.Layout.Column = 2;
            plots.ColumnWidth = {'1x', '1x'};
            plots.RowHeight = {'1x', '1x'};
            plots.Padding = [0 0 0 0];
            plots.RowSpacing = 10;
            plots.ColumnSpacing = 10;

            app.PDHErrorMixerAxes = uiaxes(plots);
            app.PDHErrorMixerAxes.Layout.Row = 1;
            app.PDHErrorMixerAxes.Layout.Column = 1;
            title(app.PDHErrorMixerAxes, '低通前：混频输出');
            xlabel(app.PDHErrorMixerAxes, '时间  f_m t（调制周期）');
            ylabel(app.PDHErrorMixerAxes, 'V_{mix} (mW-equivalent)');
            grid(app.PDHErrorMixerAxes, 'on');

            app.PDHErrorLowpassAxes = uiaxes(plots);
            app.PDHErrorLowpassAxes.Layout.Row = 1;
            app.PDHErrorLowpassAxes.Layout.Column = 2;
            title(app.PDHErrorLowpassAxes, '低通后：误差信号');
            xlabel(app.PDHErrorLowpassAxes, '时间  f_m t（调制周期）');
            ylabel(app.PDHErrorLowpassAxes, 'V_{err} (mW-equivalent)');
            grid(app.PDHErrorLowpassAxes, 'on');

            app.PDHErrorCurveAxes = uiaxes(plots);
            app.PDHErrorCurveAxes.Layout.Row = 2;
            app.PDHErrorCurveAxes.Layout.Column = 1;
            title(app.PDHErrorCurveAxes, 'PDH 误差信号曲线');
            xlabel(app.PDHErrorCurveAxes, '归一化失谐  Δf / FSR');
            ylabel(app.PDHErrorCurveAxes, 'V_{err} (mW-equivalent)');
            grid(app.PDHErrorCurveAxes, 'on');

            app.PDHErrorResponseAxes = uiaxes(plots);
            app.PDHErrorResponseAxes.Layout.Row = 2;
            app.PDHErrorResponseAxes.Layout.Column = 2;
            title(app.PDHErrorResponseAxes, '低通滤波器幅频响应');
            xlabel(app.PDHErrorResponseAxes, '频率 (kHz)');
            ylabel(app.PDHErrorResponseAxes, '|H_{LP}(f)|');
            grid(app.PDHErrorResponseAxes, 'on');

            fields = {app.PDHErrorPIDBandwidthField, ...
                app.PDHErrorLowpassCutoffField, ...
                app.PDHErrorLowpassOrderField};
            for k = 1:numel(fields)
                fields{k}.ValueChangedFcn = @(~, ~) app.updatePDHErrorPlots();
            end
        end

        function createFullChainComponents(app, parentTab)
            mainGrid = uigridlayout(parentTab, [3 1]);
            mainGrid.RowHeight = {38, '1x', 300};
            mainGrid.ColumnWidth = {'1x'};
            mainGrid.Padding = [12 10 12 12];
            mainGrid.RowSpacing = 10;

            titleLabel = uilabel(mainGrid, ...
                'Text', 'PDH 完整信号链：参数设置与误差信号输出', ...
                'FontSize', 18, 'FontWeight', 'bold', ...
                'HorizontalAlignment', 'center');
            titleLabel.Layout.Row = 1;
            titleLabel.Layout.Column = 1;

            flowGrid = uigridlayout(mainGrid, [3 7]);
            flowGrid.Layout.Row = 2;
            flowGrid.Layout.Column = 1;
            flowGrid.ColumnWidth = {'1x', 38, '1x', 38, '1x', 38, '1x'};
            flowGrid.RowHeight = {'1x', 36, '1x'};
            flowGrid.Padding = [0 0 0 0];
            flowGrid.RowSpacing = 4;
            flowGrid.ColumnSpacing = 4;

            laserPanel = uipanel(flowGrid, 'Title', '1  激光器');
            laserPanel.Layout.Row = 1;
            laserPanel.Layout.Column = 1;
            laserGrid = uigridlayout(laserPanel, [3 2]);
            laserGrid.ColumnWidth = {'1x', 92};
            laserGrid.RowHeight = {25, 25, '1x'};
            laserGrid.Padding = [6 6 6 6];
            app.addControlLabel(laserGrid, 1, '激光功率 P_0 (mW)');
            app.ChainIncidentPowerField = uieditfield(laserGrid, 'numeric', ...
                'Value', 1, 'Limits', [1e-12 Inf], ...
                'ValueDisplayFormat', '%.7g');
            app.place(app.ChainIncidentPowerField, 1, 2);
            app.addControlLabel(laserGrid, 2, '载波失谐 (MHz)');
            app.ChainDetuningField = uieditfield(laserGrid, 'numeric', ...
                'Value', 1, 'ValueDisplayFormat', '%.7g');
            app.place(app.ChainDetuningField, 2, 2);
            laserNote = uilabel(laserGrid, ...
                'Text', '|E_0|^2 = P_0，误差信号正比于 P_0', ...
                'FontColor', [0.35 0.35 0.35], ...
                'HorizontalAlignment', 'center', ...
                'WordWrap', 'on');
            laserNote.Layout.Row = 3;
            laserNote.Layout.Column = [1 2];

            eomPanel = uipanel(flowGrid, 'Title', '2  EOM 相位调制');
            eomPanel.Layout.Row = 1;
            eomPanel.Layout.Column = 3;
            eomGrid = uigridlayout(eomPanel, [4 2]);
            eomGrid.ColumnWidth = {'1x', 92};
            eomGrid.RowHeight = {25, 25, 25, 25};
            eomGrid.Padding = [6 6 6 6];
            app.addControlLabel(eomGrid, 1, 'Vπ (V)');
            app.ChainVpiField = uieditfield(eomGrid, 'numeric', ...
                'Value', 5, 'Limits', [eps Inf], ...
                'ValueDisplayFormat', '%.7g');
            app.place(app.ChainVpiField, 1, 2);
            app.addControlLabel(eomGrid, 2, '调制深度 β');
            app.ChainBetaField = uieditfield(eomGrid, 'numeric', ...
                'Value', 0.30, 'Limits', [0 Inf], ...
                'ValueDisplayFormat', '%.7g');
            app.place(app.ChainBetaField, 2, 2);
            app.addControlLabel(eomGrid, 3, '计算 Vpp');
            app.ChainDriveVppValueLabel = app.addValueLabel(eomGrid, 3);
            app.addControlLabel(eomGrid, 4, '调制频率 (MHz)');
            app.ChainModulationFrequencyField = uieditfield(eomGrid, ...
                'numeric', 'Value', 20, 'Limits', [1e-6 Inf], ...
                'ValueDisplayFormat', '%.7g');
            app.place(app.ChainModulationFrequencyField, 4, 2);

            fpPanel = uipanel(flowGrid, 'Title', '3  FP 腔反射');
            fpPanel.Layout.Row = 1;
            fpPanel.Layout.Column = 5;
            fpGrid = uigridlayout(fpPanel, [4 2]);
            fpGrid.ColumnWidth = {'1x', 92};
            fpGrid.RowHeight = {25, 25, 25, 25};
            fpGrid.Padding = [6 6 6 6];
            app.addControlLabel(fpGrid, 1, '腔长 L (m)');
            app.ChainLengthField = uieditfield(fpGrid, 'numeric', ...
                'Value', 0.20, 'Limits', [1e-6 Inf], ...
                'ValueDisplayFormat', '%.6g');
            app.place(app.ChainLengthField, 1, 2);
            app.addControlLabel(fpGrid, 2, '光强反射率 R');
            app.ChainMirrorIntensityField = uieditfield(fpGrid, 'numeric', ...
                'Value', 0.81, 'Limits', [1e-12 0.999999], ...
                'ValueDisplayFormat', '%.6f');
            app.place(app.ChainMirrorIntensityField, 2, 2);
            app.addControlLabel(fpGrid, 3, '振幅反射率 r');
            app.ChainMirrorAmplitudeLabel = app.addValueLabel(fpGrid, 3);
            app.addControlLabel(fpGrid, 4, 'FSR');
            app.ChainFSRLabel = app.addValueLabel(fpGrid, 4);

            detectorPanel = uipanel(flowGrid, 'Title', '4  光电探测器');
            detectorPanel.Layout.Row = 1;
            detectorPanel.Layout.Column = 7;
            detectorGrid = uigridlayout(detectorPanel, [3 2]);
            detectorGrid.ColumnWidth = {'1x', 92};
            detectorGrid.RowHeight = {25, 25, '1x'};
            detectorGrid.Padding = [6 6 6 6];
            app.addControlLabel(detectorGrid, 1, '3 dB 带宽 (MHz)');
            app.ChainDetectorBandwidthField = uieditfield( ...
                detectorGrid, 'numeric', 'Value', 400, ...
                'Limits', [1e-6 Inf], 'ValueDisplayFormat', '%.7g');
            app.place(app.ChainDetectorBandwidthField, 1, 2);
            app.addControlLabel(detectorGrid, 2, '|H_PD(f_m)|');
            app.ChainDetectorGainLabel = app.addValueLabel(detectorGrid, 2);
            detectorNote = uilabel(detectorGrid, ...
                'Text', '一阶电学低通模型', ...
                'FontColor', [0.40 0.40 0.40], ...
                'HorizontalAlignment', 'center');
            detectorNote.Layout.Row = 3;
            detectorNote.Layout.Column = [1 2];

            bandPanel = uipanel(flowGrid, 'Title', '5  带通滤波');
            bandPanel.Layout.Row = 3;
            bandPanel.Layout.Column = 7;
            bandGrid = uigridlayout(bandPanel, [4 2]);
            bandGrid.ColumnWidth = {'1x', 92};
            bandGrid.RowHeight = {25, 25, 25, 25};
            bandGrid.Padding = [6 6 6 6];
            app.addControlLabel(bandGrid, 1, '中心频率 (MHz)');
            app.ChainBandCenterField = uieditfield(bandGrid, 'numeric', ...
                'Value', 20, 'Limits', [1e-6 Inf], ...
                'ValueDisplayFormat', '%.7g');
            app.place(app.ChainBandCenterField, 1, 2);
            app.addControlLabel(bandGrid, 2, '3 dB 带宽 (MHz)');
            app.ChainBandWidthField = uieditfield(bandGrid, 'numeric', ...
                'Value', 10, 'Limits', [1e-6 Inf], ...
                'ValueDisplayFormat', '%.7g');
            app.place(app.ChainBandWidthField, 2, 2);
            app.addControlLabel(bandGrid, 3, '阶数');
            app.ChainBandOrderField = uieditfield(bandGrid, 'numeric', ...
                'Value', 4, 'Limits', [1 12], ...
                'RoundFractionalValues', 'on', ...
                'ValueDisplayFormat', '%.0f');
            app.place(app.ChainBandOrderField, 3, 2);
            app.addControlLabel(bandGrid, 4, '|H_BP(f_m)|');
            app.ChainBandGainLabel = app.addValueLabel(bandGrid, 4);

            mixerPanel = uipanel(flowGrid, 'Title', '6  正弦本振混频');
            mixerPanel.Layout.Row = 3;
            mixerPanel.Layout.Column = 5;
            mixerGrid = uigridlayout(mixerPanel, [3 2]);
            mixerGrid.ColumnWidth = {'1x', 92};
            mixerGrid.RowHeight = {25, 25, 25};
            mixerGrid.Padding = [6 6 6 6];
            app.addControlLabel(mixerGrid, 1, 'LO 频率 (MHz)');
            app.ChainLOFrequencyField = uieditfield(mixerGrid, 'numeric', ...
                'Value', 20, 'Limits', [1e-6 Inf], ...
                'ValueDisplayFormat', '%.7g');
            app.place(app.ChainLOFrequencyField, 1, 2);
            app.addControlLabel(mixerGrid, 2, 'LO 相位 (deg)');
            app.ChainLOPhaseField = uieditfield(mixerGrid, 'numeric', ...
                'Value', 0, 'Limits', [-360 360], ...
                'ValueDisplayFormat', '%.7g');
            app.place(app.ChainLOPhaseField, 2, 2);
            app.addControlLabel(mixerGrid, 3, 'LO Vpp (V)');
            app.ChainLOAmplitudeField = uieditfield(mixerGrid, 'numeric', ...
                'Value', 2, 'Limits', [0 Inf], ...
                'ValueDisplayFormat', '%.7g');
            app.place(app.ChainLOAmplitudeField, 3, 2);

            lowpassPanel = uipanel(flowGrid, 'Title', '7  低通与 PID 带宽');
            lowpassPanel.Layout.Row = 3;
            lowpassPanel.Layout.Column = 3;
            lowpassGrid = uigridlayout(lowpassPanel, [4 2]);
            lowpassGrid.ColumnWidth = {'1x', 92};
            lowpassGrid.RowHeight = {25, 25, 25, 25};
            lowpassGrid.Padding = [6 6 6 6];
            app.addControlLabel(lowpassGrid, 1, 'PID 带宽 (kHz)');
            app.ChainPIDBandwidthField = uieditfield(lowpassGrid, 'numeric', ...
                'Value', 100, 'Limits', [1e-3 Inf], ...
                'ValueDisplayFormat', '%.7g');
            app.place(app.ChainPIDBandwidthField, 1, 2);
            app.addControlLabel(lowpassGrid, 2, 'LPF 截止 (kHz)');
            app.ChainLowpassCutoffField = uieditfield(lowpassGrid, 'numeric', ...
                'Value', 500, 'Limits', [1e-3 Inf], ...
                'ValueDisplayFormat', '%.7g');
            app.place(app.ChainLowpassCutoffField, 2, 2);
            app.addControlLabel(lowpassGrid, 3, 'LPF 阶数');
            app.ChainLowpassOrderField = uieditfield(lowpassGrid, 'numeric', ...
                'Value', 4, 'Limits', [1 12], ...
                'RoundFractionalValues', 'on', ...
                'ValueDisplayFormat', '%.0f');
            app.place(app.ChainLowpassOrderField, 3, 2);
            app.addControlLabel(lowpassGrid, 4, '|H_LP(B_PID)|');
            app.ChainLowpassGainLabel = app.addValueLabel(lowpassGrid, 4);

            errorPanel = uipanel(flowGrid, 'Title', '8  误差信号输出');
            errorPanel.Layout.Row = 3;
            errorPanel.Layout.Column = 1;
            errorGrid = uigridlayout(errorPanel, [4 2]);
            errorGrid.ColumnWidth = {'1x', '1x'};
            errorGrid.RowHeight = {25, 25, 25, '1x'};
            errorGrid.Padding = [6 6 6 6];
            app.addControlLabel(errorGrid, 1, '当前误差');
            app.ChainCurrentErrorLabel = app.addValueLabel(errorGrid, 1);
            app.addControlLabel(errorGrid, 2, '共振点斜率');
            app.ChainSlopeLabel = app.addValueLabel(errorGrid, 2);
            app.addControlLabel(errorGrid, 3, '建议 P 极性');
            app.ChainPolarityLabel = app.addValueLabel(errorGrid, 3);
            app.ChainStatusLabel = uilabel(errorGrid, ...
                'Text', '等待计算。', 'WordWrap', 'on', ...
                'VerticalAlignment', 'top', ...
                'FontColor', [0.30 0.30 0.30]);
            app.ChainStatusLabel.Layout.Row = 4;
            app.ChainStatusLabel.Layout.Column = [1 2];

            app.addFlowArrow(flowGrid, 1, 2, '→');
            app.addFlowArrow(flowGrid, 1, 4, '→');
            app.addFlowArrow(flowGrid, 1, 6, '→');
            app.addFlowArrow(flowGrid, 2, 7, '↓');
            app.addFlowArrow(flowGrid, 3, 6, '←');
            app.addFlowArrow(flowGrid, 3, 4, '←');
            app.addFlowArrow(flowGrid, 3, 2, '←');

            app.ChainErrorAxes = uiaxes(mainGrid);
            app.ChainErrorAxes.Layout.Row = 3;
            app.ChainErrorAxes.Layout.Column = 1;
            title(app.ChainErrorAxes, '完整链路输出：PDH 误差信号');
            xlabel(app.ChainErrorAxes, '归一化失谐  Δf / FSR');
            ylabel(app.ChainErrorAxes, 'V_{err} (mW-equivalent)');
            grid(app.ChainErrorAxes, 'on');

            fields = {app.ChainVpiField, app.ChainBetaField, ...
                app.ChainModulationFrequencyField, ...
                app.ChainIncidentPowerField, app.ChainDetuningField, ...
                app.ChainLengthField, app.ChainMirrorIntensityField, ...
                app.ChainDetectorBandwidthField, ...
                app.ChainBandCenterField, app.ChainBandWidthField, ...
                app.ChainBandOrderField, app.ChainLOFrequencyField, ...
                app.ChainLOPhaseField, app.ChainLOAmplitudeField, ...
                app.ChainPIDBandwidthField, app.ChainLowpassCutoffField, ...
                app.ChainLowpassOrderField};
            for k = 1:numel(fields)
                fields{k}.ValueChangedFcn = @(~, ~) app.updateFullChainPlots();
            end
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
            app.updatePDHPlots();
            app.updateFullChainPlots();
        end

        function updatePDHPlots(app)
            c = 299792458;
            L = app.LengthField.Value;
            r = app.MirrorRField.Value;
            fsrHz = c / (2 * L);

            beta = app.PDHBetaField.Value;
            driveVpp = app.eomDriveVpp(app.PDHVpiField.Value, beta);
            app.PDHDriveVppValueLabel.Text = sprintf('%.7g V', driveVpp);
            modulationHz = app.PDHModulationFrequencyField.Value * 1e6;
            detuningHz = app.PDHCarrierDetuningField.Value * 1e6;
            incidentPowerW = app.PDHIncidentPowerField.Value * 1e-3;
            periods = round(app.PDHPeriodsField.Value);

            J0 = besselj(0, beta);
            J1 = besselj(1, beta);
            incidentFieldAmplitude = sqrt(incidentPowerW);

            Fminus = app.cavityReflection( ...
                (detuningHz - modulationHz) / fsrHz, r);
            Fcarrier = app.cavityReflection(detuningHz / fsrHz, r);
            Fplus = app.cavityReflection( ...
                (detuningHz + modulationHz) / fsrHz, r);

            Aminus = -incidentFieldAmplitude * J1 * Fminus;
            Acarrier = incidentFieldAmplitude * J0 * Fcarrier;
            Aplus = incidentFieldAmplitude * J1 * Fplus;

            normalizedTime = linspace(0, periods, 2401);
            modulationPhase = 2 * pi * normalizedTime;
            reflectedEnvelope = Acarrier ...
                + Aplus .* exp(1i * modulationPhase) ...
                + Aminus .* exp(-1i * modulationPhase);
            detectorPowerW = abs(reflectedEnvelope).^2;

            dcPowerW = abs(Acarrier)^2 + abs(Aplus)^2 + abs(Aminus)^2;
            beatCoefficient1 = Aplus * conj(Acarrier) ...
                + Acarrier * conj(Aminus);
            beatCoefficient2 = Aplus * conj(Aminus);
            beatAmplitude1W = 2 * abs(beatCoefficient1);
            beatAmplitude2W = 2 * abs(beatCoefficient2);

            fieldScale = sqrt(1e3);
            cla(app.PDHFieldAxes);
            realTrace = plot(app.PDHFieldAxes, normalizedTime, ...
                real(reflectedEnvelope) * fieldScale, ...
                'LineWidth', 1.8, 'Color', [0.88 0.18 0.16], ...
                'DisplayName', 'Re(Et)');
            hold(app.PDHFieldAxes, 'on');
            imagTrace = plot(app.PDHFieldAxes, normalizedTime, ...
                imag(reflectedEnvelope) * fieldScale, ...
                'LineWidth', 1.8, 'Color', [0.05 0.38 0.72], ...
                'DisplayName', 'Im(Et)');
            hold(app.PDHFieldAxes, 'off');
            xlim(app.PDHFieldAxes, [0 periods]);
            grid(app.PDHFieldAxes, 'on');
            legend(app.PDHFieldAxes, [realTrace imagTrace], ...
                'Location', 'best');

            cla(app.PDHPowerAxes);
            plot(app.PDHPowerAxes, normalizedTime, detectorPowerW * 1e3, ...
                'LineWidth', 1.8, 'Color', [0.88 0.22 0.17]);
            xlim(app.PDHPowerAxes, [0 periods]);
            grid(app.PDHPowerAxes, 'on');

            offsetsMHz = [-modulationHz, 0, modulationHz] / 1e6;
            componentFields = [Aminus, Acarrier, Aplus];
            componentPowersmW = abs(componentFields).^2 * 1e3;
            cla(app.PDHSpectrumAxes);
            stem(app.PDHSpectrumAxes, offsetsMHz, componentPowersmW, ...
                'filled', 'LineWidth', 1.6, 'Color', [0.08 0.57 0.46]);
            xlim(app.PDHSpectrumAxes, ...
                1.35 * [-modulationHz, modulationHz] / 1e6);
            grid(app.PDHSpectrumAxes, 'on');

            eomCoefficients = [-J1, J0, J1];
            componentPhasesDeg = rad2deg(angle(componentFields));
            app.PDHComponentTable.Data = [offsetsMHz(:), ...
                eomCoefficients(:), real(componentFields(:)) * fieldScale, ...
                imag(componentFields(:)) * fieldScale, ...
                componentPowersmW(:), componentPhasesDeg(:)];

            app.PDHFSRValueLabel.Text = app.formatFrequency(fsrHz);
            app.PDHMirrorRValueLabel.Text = sprintf('%.6f', r);
            app.PDHDCValueLabel.Text = sprintf('%.7g mW', dcPowerW * 1e3);
            app.PDHBeatFundamentalLabel.Text = app.formatBeatComponent( ...
                beatAmplitude1W, beatCoefficient1);
            app.PDHBeatSecondHarmonicLabel.Text = app.formatBeatComponent( ...
                beatAmplitude2W, beatCoefficient2);
            retainedPowerFraction = J0^2 + 2 * J1^2;
            app.PDHTruncatedPowerLabel.Text = sprintf('%.6f %%', ...
                retainedPowerFraction * 100);
            app.PDHStatusLabel.Text = [ ...
                '已计算反射载波、上下边带及探测器拍频；' ...
                '尚未加入混频、低通或误差信号。'];
            app.updatePDHFilterPlots();
        end

        function updatePDHFilterPlots(app)
            c = 299792458;
            L = app.LengthField.Value;
            r = app.MirrorRField.Value;
            fsrHz = c / (2 * L);

            beta = app.PDHBetaField.Value;
            modulationHz = app.PDHModulationFrequencyField.Value * 1e6;
            detuningHz = app.PDHCarrierDetuningField.Value * 1e6;
            incidentPowerW = app.PDHIncidentPowerField.Value * 1e-3;

            centerHz = app.PDHFilterCenterField.Value * 1e6;
            bandwidthHz = app.PDHFilterBandwidthField.Value * 1e6;
            order = round(app.PDHFilterOrderField.Value);
            sampleRateHz = app.PDHFilterSampleRateField.Value * 1e6;
            requestedWindowSeconds = app.PDHFilterWindowField.Value * 1e-6;
            cutoffSeparation = sqrt(bandwidthHz^2 + 4 * centerHz^2);
            lowCutoffHz = (cutoffSeparation - bandwidthHz) / 2;
            highCutoffHz = (cutoffSeparation + bandwidthHz) / 2;

            app.PDHFilterLowCutoffLabel.Text = ...
                app.formatFrequency(lowCutoffHz);
            app.PDHFilterHighCutoffLabel.Text = ...
                app.formatFrequency(highCutoffHz);

            if highCutoffHz >= sampleRateHz / 2
                app.PDHFilterStatusLabel.Text = sprintf([ ...
                    '采样率不足：Nyquist 频率必须高于 %.6g MHz。'], ...
                    highCutoffHz / 1e6);
                app.PDHFilterFundamentalGainLabel.Text = '--';
                app.PDHFilterSecondHarmonicGainLabel.Text = '--';
                app.PDHFilterRMSLabel.Text = '--';
                app.PDHFilterTimeSeconds = [];
                app.PDHFilterRawPowerMW = [];
                app.PDHFilterOutputMW = [];
                app.clearPDHFilterAxes();
                app.clearPDHMixerAxes();
                return;
            end

            requestedSamples = max(256, round( ...
                sampleRateHz * requestedWindowSeconds));
            sampleCount = min(requestedSamples, 200000);
            timeSeconds = (0:sampleCount - 1) / sampleRateHz;

            J0 = besselj(0, beta);
            J1 = besselj(1, beta);
            incidentFieldAmplitude = sqrt(incidentPowerW);
            Fminus = app.cavityReflection( ...
                (detuningHz - modulationHz) / fsrHz, r);
            Fcarrier = app.cavityReflection(detuningHz / fsrHz, r);
            Fplus = app.cavityReflection( ...
                (detuningHz + modulationHz) / fsrHz, r);
            Aminus = -incidentFieldAmplitude * J1 * Fminus;
            Acarrier = incidentFieldAmplitude * J0 * Fcarrier;
            Aplus = incidentFieldAmplitude * J1 * Fplus;

            phase = 2 * pi * modulationHz * timeSeconds;
            reflectedEnvelope = Acarrier + Aplus .* exp(1i * phase) ...
                + Aminus .* exp(-1i * phase);
            rawPowerMW = abs(reflectedEnvelope).^2 * 1e3;

            frequencyHz = (0:sampleCount - 1) * sampleRateHz / sampleCount;
            frequencyHz(frequencyHz > sampleRateHz / 2) = ...
                frequencyHz(frequencyHz > sampleRateHz / 2) - sampleRateHz;
            filterMagnitude = app.butterworthBandMagnitude( ...
                abs(frequencyHz), lowCutoffHz, highCutoffHz, order);
            filteredPowerMW = real(ifft(fft(rawPowerMW) .* filterMagnitude));
            app.PDHFilterTimeSeconds = timeSeconds;
            app.PDHFilterRawPowerMW = rawPowerMW;
            app.PDHFilterOutputMW = filteredPowerMW;
            app.PDHFilterSampleRateHz = sampleRateHz;

            halfCount = floor(sampleCount / 2) + 1;
            positiveFrequencyMHz = (0:halfCount - 1) ...
                * sampleRateHz / sampleCount / 1e6;
            rawAmplitude = abs(fft(rawPowerMW) / sampleCount);
            filteredAmplitude = abs(fft(filteredPowerMW) / sampleCount);
            rawAmplitude = rawAmplitude(1:halfCount);
            filteredAmplitude = filteredAmplitude(1:halfCount);
            if mod(sampleCount, 2) == 0
                doubleRange = 2:halfCount - 1;
            else
                doubleRange = 2:halfCount;
            end
            rawAmplitude(doubleRange) = 2 * rawAmplitude(doubleRange);
            filteredAmplitude(doubleRange) = 2 * filteredAmplitude(doubleRange);

            timeInPeriods = timeSeconds * modulationHz;
            requestedDisplayPeriods = round(app.PDHPeriodsField.Value);
            displayedPeriods = min(requestedDisplayPeriods, timeInPeriods(end));
            displayMask = timeInPeriods <= displayedPeriods + eps(displayedPeriods);
            cla(app.PDHFilterRawAxes);
            plot(app.PDHFilterRawAxes, timeInPeriods(displayMask), ...
                rawPowerMW(displayMask), ...
                'LineWidth', 1.5, 'Color', [0.30 0.30 0.30]);
            xlim(app.PDHFilterRawAxes, [0 displayedPeriods]);
            grid(app.PDHFilterRawAxes, 'on');

            cla(app.PDHFilterOutputAxes);
            plot(app.PDHFilterOutputAxes, timeInPeriods(displayMask), ...
                filteredPowerMW(displayMask), ...
                'LineWidth', 1.6, 'Color', [0.88 0.18 0.16]);
            yline(app.PDHFilterOutputAxes, 0, ':', ...
                'Color', [0.45 0.45 0.45]);
            xlim(app.PDHFilterOutputAxes, [0 displayedPeriods]);
            grid(app.PDHFilterOutputAxes, 'on');

            maximumViewMHz = min(sampleRateHz / 2 / 1e6, ...
                max([3 * modulationHz / 1e6, 2 * highCutoffHz / 1e6, 1]));
            cla(app.PDHFilterSpectrumAxes);
            rawSpectrumTrace = plot(app.PDHFilterSpectrumAxes, ...
                positiveFrequencyMHz, rawAmplitude, ...
                'LineWidth', 1.4, 'Color', [0.35 0.35 0.35], ...
                'DisplayName', '滤波前');
            hold(app.PDHFilterSpectrumAxes, 'on');
            filteredSpectrumTrace = plot(app.PDHFilterSpectrumAxes, ...
                positiveFrequencyMHz, filteredAmplitude, ...
                'LineWidth', 1.7, 'Color', [0.05 0.38 0.72], ...
                'DisplayName', '滤波后');
            hold(app.PDHFilterSpectrumAxes, 'off');
            xlim(app.PDHFilterSpectrumAxes, [0 maximumViewMHz]);
            grid(app.PDHFilterSpectrumAxes, 'on');
            legend(app.PDHFilterSpectrumAxes, ...
                [rawSpectrumTrace filteredSpectrumTrace], ...
                'Location', 'best');

            responseFrequencyMHz = linspace(0, maximumViewMHz, 2001);
            responseMagnitude = app.butterworthBandMagnitude( ...
                responseFrequencyMHz * 1e6, ...
                lowCutoffHz, highCutoffHz, order);
            cla(app.PDHFilterResponseAxes);
            plot(app.PDHFilterResponseAxes, responseFrequencyMHz, ...
                responseMagnitude, 'LineWidth', 1.8, ...
                'Color', [0.08 0.57 0.46]);
            hold(app.PDHFilterResponseAxes, 'on');
            xline(app.PDHFilterResponseAxes, lowCutoffHz / 1e6, '--', ...
                'Color', [0.55 0.55 0.55]);
            xline(app.PDHFilterResponseAxes, highCutoffHz / 1e6, '--', ...
                'Color', [0.55 0.55 0.55]);
            yline(app.PDHFilterResponseAxes, 1 / sqrt(2), ':', '-3 dB', ...
                'Color', [0.55 0.55 0.55]);
            hold(app.PDHFilterResponseAxes, 'off');
            xlim(app.PDHFilterResponseAxes, [0 maximumViewMHz]);
            ylim(app.PDHFilterResponseAxes, [0 1.05]);
            grid(app.PDHFilterResponseAxes, 'on');

            gainAtFundamental = app.butterworthBandMagnitude( ...
                modulationHz, lowCutoffHz, highCutoffHz, order);
            gainAtSecondHarmonic = app.butterworthBandMagnitude( ...
                2 * modulationHz, lowCutoffHz, highCutoffHz, order);
            app.PDHFilterFundamentalGainLabel.Text = ...
                sprintf('%.6f', gainAtFundamental);
            app.PDHFilterSecondHarmonicGainLabel.Text = ...
                sprintf('%.6f', gainAtSecondHarmonic);
            app.PDHFilterRMSLabel.Text = sprintf('%.7g mW', ...
                sqrt(mean(filteredPowerMW.^2)));

            if modulationHz >= lowCutoffHz && modulationHz <= highCutoffHz
                passbandMessage = 'f_m 位于通带内。';
            else
                passbandMessage = '注意：f_m 不在当前通带内。';
            end
            if requestedSamples > sampleCount
                sampleMessage = sprintf(' 样本数已限制为 %d。', sampleCount);
            else
                sampleMessage = '';
            end
            if displayedPeriods < requestedDisplayPeriods
                displayMessage = sprintf([ ...
                    ' 时间窗口仅包含 %.3g 个调制周期。'], displayedPeriods);
            else
                displayMessage = '';
            end
            app.PDHFilterStatusLabel.Text = [passbandMessage ...
                ' 当前为零相位离线滤波。' sampleMessage displayMessage];
            app.updatePDHMixerPlots();
        end

        function centerFilterOnModulation(app)
            app.PDHFilterCenterField.Value = ...
                app.PDHModulationFrequencyField.Value;
            app.updatePDHFilterPlots();
        end

        function updatePDHMixerPlots(app)
            if isempty(app.PDHFilterTimeSeconds) || ...
                    isempty(app.PDHFilterOutputMW)
                app.PDHMixerStatusLabel.Text = ...
                    '带通滤波器没有可用输出，请先检查滤波设置。';
                app.clearPDHMixerAxes();
                app.clearPDHErrorAxes();
                return;
            end

            timeSeconds = app.PDHFilterTimeSeconds;
            bandpassSignalMW = app.PDHFilterOutputMW;
            sampleRateHz = app.PDHFilterSampleRateHz;
            modulationHz = app.PDHModulationFrequencyField.Value * 1e6;
            loFrequencyHz = app.PDHMixerLOFrequencyField.Value * 1e6;
            loPhaseRad = deg2rad(app.PDHMixerPhaseField.Value);
            loVpp = app.PDHMixerAmplitudeField.Value;
            loPeakAmplitude = loVpp / 2;

            localOscillator = loPeakAmplitude * sin( ...
                2 * pi * loFrequencyHz * timeSeconds + loPhaseRad);
            mixerOutput = bandpassSignalMW .* localOscillator;
            app.PDHMixerTimeSeconds = timeSeconds;
            app.PDHMixerOutputSignal = mixerOutput;
            app.PDHMixerSampleRateHz = sampleRateHz;

            timeInPeriods = timeSeconds * modulationHz;
            requestedDisplayPeriods = round(app.PDHPeriodsField.Value);
            displayedPeriods = min(requestedDisplayPeriods, timeInPeriods(end));
            displayMask = timeInPeriods <= displayedPeriods + eps(displayedPeriods);

            cla(app.PDHMixerInputAxes);
            plot(app.PDHMixerInputAxes, timeInPeriods(displayMask), ...
                bandpassSignalMW(displayMask), 'LineWidth', 1.6, ...
                'Color', [0.05 0.38 0.72]);
            yline(app.PDHMixerInputAxes, 0, ':', ...
                'Color', [0.50 0.50 0.50]);
            xlim(app.PDHMixerInputAxes, [0 displayedPeriods]);
            grid(app.PDHMixerInputAxes, 'on');

            cla(app.PDHMixerLOAxes);
            plot(app.PDHMixerLOAxes, timeInPeriods(displayMask), ...
                localOscillator(displayMask), 'LineWidth', 1.6, ...
                'Color', [0.88 0.18 0.16]);
            yline(app.PDHMixerLOAxes, 0, ':', ...
                'Color', [0.50 0.50 0.50]);
            xlim(app.PDHMixerLOAxes, [0 displayedPeriods]);
            grid(app.PDHMixerLOAxes, 'on');

            cla(app.PDHMixerOutputAxes);
            plot(app.PDHMixerOutputAxes, timeInPeriods(displayMask), ...
                mixerOutput(displayMask), 'LineWidth', 1.6, ...
                'Color', [0.49 0.23 0.63]);
            yline(app.PDHMixerOutputAxes, 0, ':', ...
                'Color', [0.50 0.50 0.50]);
            xlim(app.PDHMixerOutputAxes, [0 displayedPeriods]);
            grid(app.PDHMixerOutputAxes, 'on');

            sampleCount = numel(mixerOutput);
            halfCount = floor(sampleCount / 2) + 1;
            positiveFrequencyMHz = (0:halfCount - 1) ...
                * sampleRateHz / sampleCount / 1e6;
            mixerAmplitude = abs(fft(mixerOutput) / sampleCount);
            mixerAmplitude = mixerAmplitude(1:halfCount);
            if mod(sampleCount, 2) == 0
                doubleRange = 2:halfCount - 1;
            else
                doubleRange = 2:halfCount;
            end
            mixerAmplitude(doubleRange) = 2 * mixerAmplitude(doubleRange);

            maximumViewMHz = min(sampleRateHz / 2 / 1e6, max([ ...
                2.5 * modulationHz / 1e6, ...
                1.5 * (modulationHz + loFrequencyHz) / 1e6, 1]));
            cla(app.PDHMixerSpectrumAxes);
            plot(app.PDHMixerSpectrumAxes, positiveFrequencyMHz, ...
                mixerAmplitude, 'LineWidth', 1.7, ...
                'Color', [0.08 0.57 0.46]);
            xline(app.PDHMixerSpectrumAxes, ...
                abs(loFrequencyHz - modulationHz) / 1e6, '--', ...
                '差频', 'Color', [0.55 0.55 0.55]);
            xline(app.PDHMixerSpectrumAxes, ...
                (loFrequencyHz + modulationHz) / 1e6, '--', ...
                '和频', 'Color', [0.55 0.55 0.55]);
            xlim(app.PDHMixerSpectrumAxes, [0 maximumViewMHz]);
            grid(app.PDHMixerSpectrumAxes, 'on');

            differenceFrequencyHz = abs(loFrequencyHz - modulationHz);
            app.PDHMixerDifferenceFrequencyLabel.Text = ...
                app.formatFrequency(differenceFrequencyHz);
            app.PDHMixerMeanLabel.Text = sprintf('%.7g mW-eq', ...
                mean(mixerOutput));
            app.PDHMixerRMSLabel.Text = sprintf('%.7g mW-eq', ...
                sqrt(mean(mixerOutput.^2)));

            frequencyResolutionHz = sampleRateHz / sampleCount;
            if differenceFrequencyHz <= frequencyResolutionHz / 2
                syncMessage = 'LO 与 f_m 同步，混频输出含直流项。';
            else
                syncMessage = sprintf([ ...
                    'LO 与 f_m 不同频，输出包含 %.6g MHz 差频。'], ...
                    differenceFrequencyHz / 1e6);
            end
            app.PDHMixerStatusLabel.Text = [syncMessage ...
                ' 当前尚未进行低通滤波。'];
            app.updatePDHErrorPlots();
        end

        function syncMixerToModulation(app)
            app.PDHMixerLOFrequencyField.Value = ...
                app.PDHModulationFrequencyField.Value;
            app.updatePDHMixerPlots();
        end

        function updatePDHErrorPlots(app)
            if isempty(app.PDHMixerTimeSeconds) || ...
                    isempty(app.PDHMixerOutputSignal)
                app.PDHErrorStatusLabel.Text = ...
                    '混频器没有可用输出，请先检查前级设置。';
                app.clearPDHErrorAxes();
                return;
            end

            timeSeconds = app.PDHMixerTimeSeconds;
            mixerOutput = app.PDHMixerOutputSignal;
            sampleRateHz = app.PDHMixerSampleRateHz;
            pidBandwidthHz = app.PDHErrorPIDBandwidthField.Value * 1e3;
            lowpassCutoffHz = app.PDHErrorLowpassCutoffField.Value * 1e3;
            lowpassOrder = round(app.PDHErrorLowpassOrderField.Value);
            modulationHz = app.PDHModulationFrequencyField.Value * 1e6;

            if lowpassCutoffHz >= sampleRateHz / 2
                app.PDHErrorStatusLabel.Text = ...
                    '低通截止频率必须低于采样率的一半。';
                app.clearPDHErrorAxes();
                return;
            end

            sampleCount = numel(mixerOutput);
            frequencyHz = (0:sampleCount - 1) * sampleRateHz / sampleCount;
            frequencyHz(frequencyHz > sampleRateHz / 2) = ...
                frequencyHz(frequencyHz > sampleRateHz / 2) - sampleRateHz;
            lowpassMagnitude = app.butterworthLowpassMagnitude( ...
                abs(frequencyHz), lowpassCutoffHz, lowpassOrder);
            errorOutput = real(ifft(fft(mixerOutput) .* lowpassMagnitude));

            timeInPeriods = timeSeconds * modulationHz;
            requestedDisplayPeriods = round(app.PDHPeriodsField.Value);
            displayedPeriods = min(requestedDisplayPeriods, timeInPeriods(end));
            displayMask = timeInPeriods <= displayedPeriods + eps(displayedPeriods);

            cla(app.PDHErrorMixerAxes);
            plot(app.PDHErrorMixerAxes, timeInPeriods(displayMask), ...
                mixerOutput(displayMask), 'LineWidth', 1.5, ...
                'Color', [0.49 0.23 0.63]);
            yline(app.PDHErrorMixerAxes, 0, ':', ...
                'Color', [0.50 0.50 0.50]);
            xlim(app.PDHErrorMixerAxes, [0 displayedPeriods]);
            grid(app.PDHErrorMixerAxes, 'on');

            cla(app.PDHErrorLowpassAxes);
            plot(app.PDHErrorLowpassAxes, timeInPeriods(displayMask), ...
                errorOutput(displayMask), 'LineWidth', 1.8, ...
                'Color', [0.88 0.18 0.16]);
            yline(app.PDHErrorLowpassAxes, 0, ':', ...
                'Color', [0.50 0.50 0.50]);
            xlim(app.PDHErrorLowpassAxes, [0 displayedPeriods]);
            grid(app.PDHErrorLowpassAxes, 'on');

            c = 299792458;
            L = app.LengthField.Value;
            r = app.MirrorRField.Value;
            fsrHz = c / (2 * L);
            beta = app.PDHBetaField.Value;
            incidentPowerW = app.PDHIncidentPowerField.Value * 1e-3;
            span = app.SpanField.Value;
            numberOfPoints = max(501, round(app.PointsField.Value));
            if mod(numberOfPoints, 2) == 0
                numberOfPoints = numberOfPoints + 1;
            end
            normalizedDetuning = linspace(-span, span, numberOfPoints);
            J0 = besselj(0, beta);
            J1 = besselj(1, beta);
            inputFieldAmplitude = sqrt(incidentPowerW);
            modulationOverFSR = modulationHz / fsrHz;
            Fcarrier = app.cavityReflection(normalizedDetuning, r);
            Fminus = app.cavityReflection( ...
                normalizedDetuning - modulationOverFSR, r);
            Fplus = app.cavityReflection( ...
                normalizedDetuning + modulationOverFSR, r);
            Acarrier = inputFieldAmplitude * J0 .* Fcarrier;
            Aminus = -inputFieldAmplitude * J1 .* Fminus;
            Aplus = inputFieldAmplitude * J1 .* Fplus;
            beatCoefficient = Aplus .* conj(Acarrier) ...
                + Acarrier .* conj(Aminus);

            bandCenterHz = app.PDHFilterCenterField.Value * 1e6;
            bandWidthHz = app.PDHFilterBandwidthField.Value * 1e6;
            bandOrder = round(app.PDHFilterOrderField.Value);
            cutoffSeparation = sqrt(bandWidthHz^2 + 4 * bandCenterHz^2);
            bandLowHz = (cutoffSeparation - bandWidthHz) / 2;
            bandHighHz = (cutoffSeparation + bandWidthHz) / 2;
            bandGainAtFM = app.butterworthBandMagnitude( ...
                modulationHz, bandLowHz, bandHighHz, bandOrder);
            filteredBeatCoefficient = bandGainAtFM .* beatCoefficient;

            loPeakAmplitude = app.PDHMixerAmplitudeField.Value / 2;
            loPhaseRad = deg2rad(app.PDHMixerPhaseField.Value);
            errorCurveMW = loPeakAmplitude .* ( ...
                real(filteredBeatCoefficient) * sin(loPhaseRad) ...
                - imag(filteredBeatCoefficient) * cos(loPhaseRad)) * 1e3;

            currentNormalizedDetuning = ...
                app.PDHCarrierDetuningField.Value * 1e6 / fsrHz;
            currentCurveValue = interp1(normalizedDetuning, errorCurveMW, ...
                currentNormalizedDetuning, 'linear', NaN);
            cla(app.PDHErrorCurveAxes);
            plot(app.PDHErrorCurveAxes, normalizedDetuning, errorCurveMW, ...
                'LineWidth', 1.8, 'Color', [0.05 0.38 0.72]);
            hold(app.PDHErrorCurveAxes, 'on');
            xline(app.PDHErrorCurveAxes, 0, '--', '共振', ...
                'Color', [0.50 0.50 0.50]);
            yline(app.PDHErrorCurveAxes, 0, ':', ...
                'Color', [0.50 0.50 0.50]);
            if isfinite(currentCurveValue)
                plot(app.PDHErrorCurveAxes, currentNormalizedDetuning, ...
                    currentCurveValue, 'o', 'MarkerSize', 8, ...
                    'MarkerFaceColor', [0.88 0.18 0.16], ...
                    'MarkerEdgeColor', 'white', 'LineWidth', 1.2);
            end
            hold(app.PDHErrorCurveAxes, 'off');
            xlim(app.PDHErrorCurveAxes, [-span span]);
            grid(app.PDHErrorCurveAxes, 'on');

            minimumResponseHz = max(1, lowpassCutoffHz / 1000);
            maximumResponseHz = max([2 * modulationHz, ...
                10 * lowpassCutoffHz, 2 * pidBandwidthHz]);
            responseFrequencyHz = logspace(log10(minimumResponseHz), ...
                log10(maximumResponseHz), 2401);
            responseMagnitude = app.butterworthLowpassMagnitude( ...
                responseFrequencyHz, lowpassCutoffHz, lowpassOrder);
            cla(app.PDHErrorResponseAxes);
            semilogx(app.PDHErrorResponseAxes, responseFrequencyHz / 1e3, ...
                responseMagnitude, 'LineWidth', 1.8, ...
                'Color', [0.08 0.57 0.46]);
            hold(app.PDHErrorResponseAxes, 'on');
            xline(app.PDHErrorResponseAxes, pidBandwidthHz / 1e3, '--', ...
                'PID BW', 'Color', [0.88 0.18 0.16]);
            xline(app.PDHErrorResponseAxes, lowpassCutoffHz / 1e3, '--', ...
                'LPF fc', 'Color', [0.45 0.45 0.45]);
            yline(app.PDHErrorResponseAxes, 1 / sqrt(2), ':', '-3 dB', ...
                'Color', [0.55 0.55 0.55]);
            hold(app.PDHErrorResponseAxes, 'off');
            ylim(app.PDHErrorResponseAxes, [0 1.05]);
            grid(app.PDHErrorResponseAxes, 'on');

            gainAtPID = app.butterworthLowpassMagnitude( ...
                pidBandwidthHz, lowpassCutoffHz, lowpassOrder);
            gainAt2FM = app.butterworthLowpassMagnitude( ...
                2 * modulationHz, lowpassCutoffHz, lowpassOrder);
            app.PDHErrorGainAtPIDLabel.Text = sprintf('%.6f', gainAtPID);
            app.PDHErrorGainAt2FMLabel.Text = sprintf('%.3e', gainAt2FM);
            app.PDHErrorCurrentValueLabel.Text = sprintf('%.7g mW-eq', ...
                mean(errorOutput));
            errorSlope = gradient(errorCurveMW, normalizedDetuning);
            [~, resonanceIndex] = min(abs(normalizedDetuning));
            app.PDHErrorSlopeLabel.Text = sprintf('%.7g mW-eq/FSR', ...
                errorSlope(resonanceIndex));

            loFrequencyHz = app.PDHMixerLOFrequencyField.Value * 1e6;
            frequencyDifferenceHz = abs(loFrequencyHz - modulationHz);
            if frequencyDifferenceHz > lowpassCutoffHz
                syncMessage = 'LO 差频超出低通带宽，无法形成稳定误差信号。';
            elseif frequencyDifferenceHz > sampleRateHz / sampleCount / 2
                syncMessage = 'LO 未完全同步，低通输出仍含差频振荡。';
            else
                syncMessage = 'LO 已同步，低通输出为 PDH 误差信号。';
            end
            if lowpassCutoffHz < pidBandwidthHz
                bandwidthMessage = ' 警告：低通截止低于 PID 带宽。';
            else
                bandwidthMessage = '';
            end
            app.PDHErrorStatusLabel.Text = [syncMessage bandwidthMessage ...
                ' 当前使用零相位理论滤波。'];
        end

        function updateFullChainPlots(app)
            c = 299792458;
            L = app.ChainLengthField.Value;
            mirrorIntensity = app.ChainMirrorIntensityField.Value;
            r = sqrt(mirrorIntensity);
            fsrHz = c / (2 * L);
            beta = app.ChainBetaField.Value;
            driveVpp = app.eomDriveVpp(app.ChainVpiField.Value, beta);
            app.ChainDriveVppValueLabel.Text = sprintf('%.7g V', driveVpp);
            modulationHz = app.ChainModulationFrequencyField.Value * 1e6;
            incidentPowerW = app.ChainIncidentPowerField.Value * 1e-3;
            detectorBandwidthHz = app.ChainDetectorBandwidthField.Value * 1e6;

            bandCenterHz = app.ChainBandCenterField.Value * 1e6;
            bandWidthHz = app.ChainBandWidthField.Value * 1e6;
            bandOrder = round(app.ChainBandOrderField.Value);
            cutoffSeparation = sqrt(bandWidthHz^2 + 4 * bandCenterHz^2);
            bandLowHz = (cutoffSeparation - bandWidthHz) / 2;
            bandHighHz = (cutoffSeparation + bandWidthHz) / 2;

            loFrequencyHz = app.ChainLOFrequencyField.Value * 1e6;
            loPhaseRad = deg2rad(app.ChainLOPhaseField.Value);
            loPeakAmplitude = app.ChainLOAmplitudeField.Value / 2;
            pidBandwidthHz = app.ChainPIDBandwidthField.Value * 1e3;
            lowpassCutoffHz = app.ChainLowpassCutoffField.Value * 1e3;
            lowpassOrder = round(app.ChainLowpassOrderField.Value);

            detectorGain = 1 / sqrt(1 + ...
                (modulationHz / detectorBandwidthHz)^2);
            bandGain = app.butterworthBandMagnitude( ...
                modulationHz, bandLowHz, bandHighHz, bandOrder);
            differenceFrequencyHz = abs(loFrequencyHz - modulationHz);
            differenceGain = app.butterworthLowpassMagnitude( ...
                differenceFrequencyHz, lowpassCutoffHz, lowpassOrder);
            lowpassGainAtPID = app.butterworthLowpassMagnitude( ...
                pidBandwidthHz, lowpassCutoffHz, lowpassOrder);

            normalizedDetuning = linspace(-0.5, 0.5, 2001);
            modulationOverFSR = modulationHz / fsrHz;
            inputFieldAmplitude = sqrt(incidentPowerW);
            J0 = besselj(0, beta);
            J1 = besselj(1, beta);
            Fcarrier = app.cavityReflection(normalizedDetuning, r);
            Fminus = app.cavityReflection( ...
                normalizedDetuning - modulationOverFSR, r);
            Fplus = app.cavityReflection( ...
                normalizedDetuning + modulationOverFSR, r);
            Acarrier = inputFieldAmplitude * J0 .* Fcarrier;
            Aminus = -inputFieldAmplitude * J1 .* Fminus;
            Aplus = inputFieldAmplitude * J1 .* Fplus;
            beatCoefficient = Aplus .* conj(Acarrier) ...
                + Acarrier .* conj(Aminus);
            detectedBeatCoefficient = detectorGain * bandGain ...
                .* beatCoefficient;
            errorCurveMW = loPeakAmplitude * differenceGain .* ( ...
                real(detectedBeatCoefficient) * sin(loPhaseRad) ...
                - imag(detectedBeatCoefficient) * cos(loPhaseRad)) * 1e3;

            currentNormalizedDetuning = ...
                app.ChainDetuningField.Value * 1e6 / fsrHz;
            currentError = interp1(normalizedDetuning, errorCurveMW, ...
                currentNormalizedDetuning, 'linear', NaN);
            errorSlope = gradient(errorCurveMW, normalizedDetuning);
            [~, resonanceIndex] = min(abs(normalizedDetuning));
            resonanceSlope = errorSlope(resonanceIndex);

            app.ChainMirrorAmplitudeLabel.Text = sprintf('%.6f', r);
            app.ChainFSRLabel.Text = app.formatFrequency(fsrHz);
            app.ChainDetectorGainLabel.Text = sprintf('%.6f', detectorGain);
            app.ChainBandGainLabel.Text = sprintf('%.6f', bandGain);
            app.ChainLowpassGainLabel.Text = sprintf('%.6f', lowpassGainAtPID);
            if isfinite(currentError)
                app.ChainCurrentErrorLabel.Text = ...
                    sprintf('%.7g mW-eq', currentError);
            else
                app.ChainCurrentErrorLabel.Text = '超出 ±0.5 FSR';
            end
            app.ChainSlopeLabel.Text = sprintf('%.7g mW-eq/FSR', ...
                resonanceSlope);
            if resonanceSlope < 0
                app.ChainPolarityLabel.Text = 'P > 0';
                app.ChainPolarityLabel.FontColor = [0.05 0.50 0.20];
            elseif resonanceSlope > 0
                app.ChainPolarityLabel.Text = 'P < 0';
                app.ChainPolarityLabel.FontColor = [0.75 0.20 0.12];
            else
                app.ChainPolarityLabel.Text = '未定义';
                app.ChainPolarityLabel.FontColor = [0.40 0.40 0.40];
            end

            cla(app.ChainErrorAxes);
            plot(app.ChainErrorAxes, normalizedDetuning, errorCurveMW, ...
                'LineWidth', 2.0, 'Color', [0.05 0.38 0.72]);
            hold(app.ChainErrorAxes, 'on');
            xline(app.ChainErrorAxes, 0, '--', '共振', ...
                'Color', [0.48 0.48 0.48]);
            yline(app.ChainErrorAxes, 0, ':', ...
                'Color', [0.48 0.48 0.48]);
            if isfinite(currentError)
                plot(app.ChainErrorAxes, currentNormalizedDetuning, ...
                    currentError, 'o', 'MarkerSize', 9, ...
                    'MarkerFaceColor', [0.88 0.18 0.16], ...
                    'MarkerEdgeColor', 'white', 'LineWidth', 1.2);
            end
            hold(app.ChainErrorAxes, 'off');
            xlim(app.ChainErrorAxes, [-0.5 0.5]);
            grid(app.ChainErrorAxes, 'on');

            messages = {};
            if modulationHz >= detectorBandwidthHz
                messages{end + 1} = 'f_m 已超过探测器 3 dB 带宽'; %#ok<AGROW>
            end
            if bandGain < 0.7
                messages{end + 1} = 'f_m 未被带通滤波器充分通过'; %#ok<AGROW>
            end
            if differenceFrequencyHz > lowpassCutoffHz
                messages{end + 1} = 'LO 差频超出低通带宽'; %#ok<AGROW>
            elseif differenceFrequencyHz > 1
                messages{end + 1} = 'LO 未完全同步，输出会随差频振荡'; %#ok<AGROW>
            end
            if lowpassCutoffHz < pidBandwidthHz
                messages{end + 1} = 'LPF 截止低于 PID 带宽'; %#ok<AGROW>
            end
            if isempty(messages)
                statusText = '链路参数有效。P 极性假设正控制电压提高激光频率。';
            else
                statusText = strjoin(messages, '；');
            end
            app.ChainStatusLabel.Text = statusText;
        end

        function setLowpassFromPIDBandwidth(app)
            app.PDHErrorLowpassCutoffField.Value = ...
                5 * app.PDHErrorPIDBandwidthField.Value;
            app.updatePDHErrorPlots();
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

        function addFlowArrow(~, parent, row, column, arrowText)
            arrow = uilabel(parent, ...
                'Text', arrowText, ...
                'FontSize', 28, ...
                'FontWeight', 'bold', ...
                'FontColor', [0.15 0.45 0.72], ...
                'HorizontalAlignment', 'center', ...
                'VerticalAlignment', 'center');
            arrow.Layout.Row = row;
            arrow.Layout.Column = column;
        end

        function place(~, component, row, column)
            component.Layout.Row = row;
            component.Layout.Column = column;
        end

        function F = cavityReflection(~, normalizedDetuning, r)
            phi = 2 * pi * normalizedDetuning;
            F = r .* (exp(1i * phi) - 1) ./ ...
                (1 - r^2 .* exp(1i * phi));
        end

        function driveVpp = eomDriveVpp(~, vpi, beta)
            % Sinusoidal phase modulator: beta = pi*Vpp/(2*Vpi).
            driveVpp = 2 * beta * vpi / pi;
        end

        function magnitude = butterworthBandMagnitude( ...
                ~, frequencyHz, lowCutoffHz, highCutoffHz, order)
            frequencyHz = abs(frequencyHz);
            safeFrequencyHz = max(frequencyHz, realmin);
            centerHz = sqrt(lowCutoffHz * highCutoffHz);
            bandwidthHz = highCutoffHz - lowCutoffHz;
            transformedFrequency = abs((safeFrequencyHz.^2 - centerHz^2) ...
                ./ (bandwidthHz .* safeFrequencyHz));
            magnitude = 1 ./ sqrt(1 + transformedFrequency.^(2 * order));
            magnitude(frequencyHz == 0) = 0;
        end

        function magnitude = butterworthLowpassMagnitude( ...
                ~, frequencyHz, cutoffHz, order)
            magnitude = 1 ./ sqrt(1 + ...
                (abs(frequencyHz) ./ cutoffHz).^(2 * order));
        end

        function clearPDHFilterAxes(app)
            cla(app.PDHFilterRawAxes);
            cla(app.PDHFilterOutputAxes);
            cla(app.PDHFilterSpectrumAxes);
            cla(app.PDHFilterResponseAxes);
        end

        function clearPDHMixerAxes(app)
            cla(app.PDHMixerInputAxes);
            cla(app.PDHMixerLOAxes);
            cla(app.PDHMixerOutputAxes);
            cla(app.PDHMixerSpectrumAxes);
            app.PDHMixerTimeSeconds = [];
            app.PDHMixerOutputSignal = [];
            app.PDHMixerDifferenceFrequencyLabel.Text = '--';
            app.PDHMixerMeanLabel.Text = '--';
            app.PDHMixerRMSLabel.Text = '--';
            app.PDHMixerStatusLabel.Text = '带通滤波器没有可用输出。';
            app.clearPDHErrorAxes();
            app.PDHErrorStatusLabel.Text = '混频器没有可用输出。';
        end


        function clearPDHErrorAxes(app)
            cla(app.PDHErrorMixerAxes);
            cla(app.PDHErrorLowpassAxes);
            cla(app.PDHErrorCurveAxes);
            cla(app.PDHErrorResponseAxes);
            app.PDHErrorGainAtPIDLabel.Text = '--';
            app.PDHErrorGainAt2FMLabel.Text = '--';
            app.PDHErrorCurrentValueLabel.Text = '--';
            app.PDHErrorSlopeLabel.Text = '--';
        end

        function textValue = formatBeatComponent(~, amplitudeW, coefficient)
            if abs(coefficient) < 1e-18
                textValue = '0 mW（相位未定义）';
            else
                textValue = sprintf('%.7g mW, %.3f°', ...
                    amplitudeW * 1e3, rad2deg(angle(coefficient)));
            end
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
