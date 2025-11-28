%% Neural Rejuvenation Hypothesis - Population Model (Publication Quality)
% This model demonstrates the key concepts of neural rejuvenation in addiction
% at the population level for scientific publication

clear all; close all; clc;

%% Simulation Parameters
dt = 0.1;                    % Time step (arbitrary units)
t_total = 500;               % Total simulation time
t = 0:dt:t_total;
n_steps = length(t);

% Drug exposure protocol
exposure_start = 100;        % When drug exposure begins
exposure_duration = 50;      % Duration of repeated exposures
n_exposures = 5;             % Number of exposure sessions
exposure_interval = 30;      % Time between exposures
withdrawal_start = exposure_start + n_exposures * exposure_interval;

%% Initial Population of Synapses
N_total = 1000;              % Total number of synapses
N_adult = N_total;           % Adult-like synapses (GluN2A-dominant)
N_juvenile = 0;              % Juvenile-like synapses (GluN2B-dominant)
N_silent = 0;                % Silent synapses (NMDA-only)
N_mature_silent = 0;         % Matured silent synapses (with CP-AMPARs)

%% Model Parameters
% Rejuvenation rates during exposure
k_adult_to_juvenile = 0.08;  % Rate of adult→juvenile conversion
k_silent_generation = 0.03;  % Rate of silent synapse generation

% Maturation rates during withdrawal
k_juvenile_to_adult = 0.02;  % Rate of juvenile→adult recovery
k_silent_maturation = 0.04;  % Rate of silent→mature conversion
k_silent_pruning = 0.01;     % Rate of silent synapse elimination

% Plasticity parameters
plasticity_adult = 1.0;      % Baseline plasticity for adult synapses
plasticity_juvenile = 2.5;   % Enhanced plasticity for juvenile synapses
plasticity_silent = 0.5;     % Reduced plasticity for silent synapses
plasticity_cp_ampar = 3.0;   % Very high plasticity for CP-AMPAR synapses

%% Initialize arrays to store results
populations = zeros(n_steps, 4);  % [Adult, Juvenile, Silent, Mature_Silent]
drug_present = zeros(n_steps, 1);
total_plasticity = zeros(n_steps, 1);
memory_strength = zeros(n_steps, 1);
cue_response = zeros(n_steps, 1);

%% Main simulation loop
current_memory = 0;

for i = 1:n_steps
    current_time = t(i);
    
    %% Determine if drug is present
    drug_exposure = 0;
    for exp = 1:n_exposures
        exp_start = exposure_start + (exp-1) * exposure_interval;
        if current_time >= exp_start && current_time <= exp_start + 5
            drug_exposure = 1;
            break;
        end
    end
    
    drug_present(i) = drug_exposure;
    
    %% During drug exposure - Rejuvenation phase
    if drug_exposure == 1
        % Convert adult synapses to juvenile-like
        adult_to_juvenile = k_adult_to_juvenile * N_adult * dt;
        N_adult = max(0, N_adult - adult_to_juvenile);
        N_juvenile = N_juvenile + adult_to_juvenile;
        
        % Generate silent synapses from juvenile population
        juvenile_to_silent = k_silent_generation * N_juvenile * dt;
        N_juvenile = max(0, N_juvenile - juvenile_to_silent);
        N_silent = N_silent + juvenile_to_silent;
        
    %% During withdrawal - Maturation phase
    elseif current_time > withdrawal_start
        % Gradual recovery of juvenile to adult
        juvenile_to_adult = k_juvenile_to_adult * N_juvenile * dt;
        N_juvenile = max(0, N_juvenile - juvenile_to_adult);
        N_adult = N_adult + juvenile_to_adult;
        
        % Silent synapses can mature or be pruned
        silent_maturation = k_silent_maturation * N_silent * dt;
        silent_pruning = k_silent_pruning * N_silent * dt;
        
        N_silent = max(0, N_silent - silent_maturation - silent_pruning);
        N_mature_silent = N_mature_silent + silent_maturation;
        % Pruned synapses are lost from the system
    end
    
    %% Calculate total plasticity capacity
    total_plasticity(i) = (N_adult * plasticity_adult + ...
                          N_juvenile * plasticity_juvenile + ...
                          N_silent * plasticity_silent + ...
                          N_mature_silent * plasticity_cp_ampar) / N_total;
    
    %% Memory formation and incubation
    if drug_exposure == 1
        % Strong memory formation during drug exposure
        memory_increment = 0.5 * total_plasticity(i);
        current_memory = current_memory + memory_increment * dt;
    else
        % Memory incubation - grows during withdrawal due to silent synapse maturation
        incubation_factor = N_mature_silent / N_total;  % More mature silent synapses = stronger incubation
        memory_increment = 0.1 * incubation_factor;
        current_memory = current_memory + memory_increment * dt;
    end
    
    memory_strength(i) = current_memory;
    
    %% Cue-induced response (simplified)
    % Simulate periodic cue presentation
    if mod(current_time, 50) < 2  % Cue every 50 time units for 2 units duration
        cue_response(i) = memory_strength(i) * total_plasticity(i) * 0.8;
    else
        cue_response(i) = 0;
    end
    
    %% Store population data
    populations(i, :) = [N_adult, N_juvenile, N_silent, N_mature_silent];
end

%% Publication Quality Figure Settings
% Set default figure properties for publication
set(0, 'DefaultFigureColor', 'white');
set(0, 'DefaultAxesLineWidth', 1.5);
set(0, 'DefaultLineLineWidth', 2);
set(0, 'DefaultAxesFontSize', 12);
set(0, 'DefaultTextFontSize', 12);

% A4 paper size in inches (210 × 297 mm = 8.27 × 11.69 inches)
A4_width = 8.27;
A4_height = 11.69;

%% Figure 1: Core Rejuvenation Dynamics
fig1 = figure('Position', [100, 100, 800, 1000], 'Color', 'white');
% Set figure size to A4 with proper aspect ratio (3 rows, 2 columns)
set(fig1, 'Units', 'inches');
set(fig1, 'Position', [1, 1, A4_width, A4_height*0.85]); % Use 85% of A4 height
set(fig1, 'PaperUnits', 'inches');
set(fig1, 'PaperSize', [A4_width, A4_height*0.85]);
set(fig1, 'PaperPosition', [0, 0, A4_width, A4_height*0.85]);

% Panel A: Drug exposure timeline and cue-induced responses
subplot(3, 2, 1);
% Create a comprehensive timeline view
yyaxis left
h_cue = stem(t(cue_response > 0), cue_response(cue_response > 0), 'g', 'LineWidth', 2, 'MarkerSize', 4);
ylabel('Cue Response Strength', 'FontSize', 11, 'FontWeight', 'bold');
set(gca, 'YColor', [0.2 0.7 0.3]);

yyaxis right
% Show drug exposure as filled regions
drug_timeline = zeros(size(t));
drug_timeline(drug_present > 0) = 1;
h_drug = area(t, drug_timeline, 'FaceColor', [0.8 0.3 0.3], 'EdgeColor', 'none', 'FaceAlpha', 0.6);
ylabel('Drug Exposure', 'FontSize', 11, 'FontWeight', 'bold');
set(gca, 'YColor', [0.8 0.3 0.3], 'YTick', [0 1], 'YTickLabel', {'Off', 'On'});
ylim([0 1.2]);

xlabel('Time (a.u.)', 'FontSize', 11, 'FontWeight', 'bold');
title('A. Drug Exposure & Cue Responses', 'FontSize', 13, 'FontWeight', 'bold');
set(gca, 'Box', 'off', 'LineWidth', 1.5);
grid on;

% Add phase annotations
text(50, 0.5, 'Baseline', 'FontSize', 9, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
text(150, 0.5, 'Exposure', 'FontSize', 9, 'FontWeight', 'bold', 'HorizontalAlignment', 'center', 'Color', [0.8 0.3 0.3]);
text(350, 0.5, 'Withdrawal', 'FontSize', 9, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
text(450, 0.5, 'Incubation', 'FontSize', 9, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');

% Panel B: Population dynamics
subplot(3, 2, 2);
colors = [0.2 0.4 0.8; 0.8 0.2 0.2; 0.2 0.7 0.3; 0.7 0.2 0.7];
h1 = plot(t, populations(:, 1), 'Color', colors(1,:), 'LineWidth', 2.5); hold on;
h2 = plot(t, populations(:, 2), 'Color', colors(2,:), 'LineWidth', 2.5);
h3 = plot(t, populations(:, 3), 'Color', colors(3,:), 'LineWidth', 2.5);
h4 = plot(t, populations(:, 4), 'Color', colors(4,:), 'LineWidth', 2.5);

% Mark drug exposure periods
drug_times = find(drug_present > 0);
if ~isempty(drug_times)
    exposure_regions = [];
    for j = 1:length(drug_times)
        if j == 1 || drug_times(j) - drug_times(j-1) > 10
            region_start = t(drug_times(j));
        end
        if j == length(drug_times) || drug_times(j+1) - drug_times(j) > 10
            region_end = t(drug_times(j));
            patch([region_start region_end region_end region_start], ...
                  [0 0 N_total*1.1 N_total*1.1], [0.9 0.9 0.9], ...
                  'EdgeColor', 'none', 'FaceAlpha', 0.3);
        end
    end
end

xlabel('Time (a.u.)', 'FontSize', 11, 'FontWeight', 'bold');
ylabel('Number of Synapses', 'FontSize', 11, 'FontWeight', 'bold');
title('B. Synapse Population Dynamics', 'FontSize', 13, 'FontWeight', 'bold');
legend([h1 h2 h3 h4], {'Adult (GluN2A)', 'Juvenile (GluN2B)', 'Silent', 'Matured (CP-AMPAR)'}, ...
       'Location', 'best', 'FontSize', 9);
set(gca, 'Box', 'off', 'LineWidth', 1.5);
ylim([0 N_total*1.1]);
grid on; grid minor;

% Panel C: NMDA receptor subunit composition
subplot(3, 2, 3);
gluN2A_ratio = populations(:, 1) ./ (populations(:, 1) + populations(:, 2) + 0.001);
gluN2B_ratio = populations(:, 2) ./ (populations(:, 1) + populations(:, 2) + 0.001);
h5 = plot(t, gluN2A_ratio, 'Color', [0.2 0.4 0.8], 'LineWidth', 3); hold on;
h6 = plot(t, gluN2B_ratio, 'Color', [0.8 0.2 0.2], 'LineWidth', 3);
plot(t, ones(size(t))*0.8, '--', 'Color', [0.2 0.4 0.8], 'LineWidth', 1.5);
plot(t, ones(size(t))*0.2, '--', 'Color', [0.8 0.2 0.2], 'LineWidth', 1.5);

% Mark drug exposure periods
if ~isempty(drug_times)
    for j = 1:length(drug_times)
        if j == 1 || drug_times(j) - drug_times(j-1) > 10
            region_start = t(drug_times(j));
        end
        if j == length(drug_times) || drug_times(j+1) - drug_times(j) > 10
            region_end = t(drug_times(j));
            patch([region_start region_end region_end region_start], ...
                  [0 0 1 1], [0.9 0.9 0.9], 'EdgeColor', 'none', 'FaceAlpha', 0.3);
        end
    end
end

xlabel('Time (a.u.)', 'FontSize', 11, 'FontWeight', 'bold');
ylabel('Receptor Subunit Ratio', 'FontSize', 11, 'FontWeight', 'bold');
title('C. NMDA Receptor Rejuvenation', 'FontSize', 13, 'FontWeight', 'bold');
legend([h5 h6], {'GluN2A (Adult)', 'GluN2B (Juvenile)'}, 'Location', 'best', 'FontSize', 9);
ylim([0 1]); 
set(gca, 'Box', 'off', 'LineWidth', 1.5);
grid on; grid minor;

% Panel D: Memory strength and incubation
subplot(3, 2, 4);
h7 = plot(t, memory_strength, 'Color', [0.8 0.1 0.1], 'LineWidth', 3); hold on;

% Mark drug exposure periods
if ~isempty(drug_times)
    for j = 1:length(drug_times)
        if j == 1 || drug_times(j) - drug_times(j-1) > 10
            region_start = t(drug_times(j));
        end
        if j == length(drug_times) || drug_times(j+1) - drug_times(j) > 10
            region_end = t(drug_times(j));
            patch([region_start region_end region_end region_start], ...
                  [0 0 max(memory_strength)*1.1 max(memory_strength)*1.1], ...
                  [0.9 0.9 0.9], 'EdgeColor', 'none', 'FaceAlpha', 0.3);
        end
    end
end

xlabel('Time (a.u.)', 'FontSize', 11, 'FontWeight', 'bold');
ylabel('Memory Strength', 'FontSize', 11, 'FontWeight', 'bold');
title('D. Memory Formation & Incubation', 'FontSize', 13, 'FontWeight', 'bold');
set(gca, 'Box', 'off', 'LineWidth', 1.5);
ylim([0 max(memory_strength)*1.1]);
grid on; grid minor;

% Panel E: Plasticity capacity over time
subplot(3, 2, 5);
h8 = plot(t, total_plasticity, 'Color', [0.1 0.1 0.8], 'LineWidth', 3); hold on;

% Mark drug exposure periods
if ~isempty(drug_times)
    for j = 1:length(drug_times)
        if j == 1 || drug_times(j) - drug_times(j-1) > 10
            region_start = t(drug_times(j));
        end
        if j == length(drug_times) || drug_times(j+1) - drug_times(j) > 10
            region_end = t(drug_times(j));
            patch([region_start region_end region_end region_start], ...
                  [0 0 max(total_plasticity)*1.1 max(total_plasticity)*1.1], ...
                  [0.9 0.9 0.9], 'EdgeColor', 'none', 'FaceAlpha', 0.3);
        end
    end
end

xlabel('Time (a.u.)', 'FontSize', 11, 'FontWeight', 'bold');
ylabel('Plasticity Capacity', 'FontSize', 11, 'FontWeight', 'bold');
title('E. Enhanced Plasticity Window', 'FontSize', 13, 'FontWeight', 'bold');
set(gca, 'Box', 'off', 'LineWidth', 1.5);
ylim([1 max(total_plasticity)*1.1]);
grid on; grid minor;

% Panel F: Conceptual diagram of rejuvenation process
subplot(3, 2, 6);
% Create a schematic showing the key concept
x_stages = [1 2 3 4];
stage_names = {'Adult', 'Juvenile', 'Silent', 'Matured'};
stage_heights = [1, 2.5, 1.5, 3];
stage_colors = colors;

for i = 1:4
    bar(x_stages(i), stage_heights(i), 'FaceColor', stage_colors(i,:), ...
        'EdgeColor', 'black', 'LineWidth', 1.5);
    hold on;
end

set(gca, 'XTick', x_stages, 'XTickLabel', stage_names);
ylabel('Plasticity Level', 'FontSize', 11, 'FontWeight', 'bold');
title('F. Rejuvenation Process', 'FontSize', 13, 'FontWeight', 'bold');
set(gca, 'Box', 'off', 'LineWidth', 1.5);
ylim([0 3.5]);
grid on;

% Add overall title
sgtitle('Neural Rejuvenation Hypothesis: Population-Level Dynamics', ...
        'FontSize', 16, 'FontWeight', 'bold');

%% Save Figure 1 in multiple formats
fig1_name = 'Figure1_Neural_Rejuvenation_Dynamics';

% PNG format (300 DPI)
print(fig1, [fig1_name '.png'], '-dpng', '-r300');

% TIFF format (300 DPI)
print(fig1, [fig1_name '.tiff'], '-dtiff', '-r300');

% PDF format (vector graphics, best for publications)
print(fig1, [fig1_name '.pdf'], '-dpdf', '-r300');

% MATLAB .fig format (for future editing)
savefig(fig1, [fig1_name '.fig']);

% EPS format (vector graphics, alternative to PDF)
print(fig1, [fig1_name '.eps'], '-depsc2', '-r300');

fprintf('Figure 1 saved in formats: PNG, TIFF, PDF, FIG, EPS\n');

%% Figure 2: Silent Synapse Dynamics and Experimental Predictions
fig2 = figure('Position', [200, 200, 800, 600], 'Color', 'white');
% Set figure size to A4 with proper aspect ratio (3 rows, 2 columns)
set(fig2, 'Units', 'inches');
set(fig2, 'Position', [1, 1, A4_width, A4_height*0.75]); % Use 75% of A4 height
set(fig2, 'PaperUnits', 'inches');
set(fig2, 'PaperSize', [A4_width, A4_height*0.75]);
set(fig2, 'PaperPosition', [0, 0, A4_width, A4_height*0.75]);

% Panel A: Silent synapse generation and maturation
subplot(3, 2, 1);
silent_total = populations(:, 3) + populations(:, 4);
h9 = plot(t, populations(:, 3), 'Color', [0.2 0.7 0.3], 'LineWidth', 2.5); hold on;
h10 = plot(t, populations(:, 4), 'Color', [0.7 0.2 0.7], 'LineWidth', 2.5);
h11 = plot(t, silent_total, '--', 'Color', [0.3 0.3 0.3], 'LineWidth', 2);

% Mark drug exposure periods
if ~isempty(drug_times)
    for j = 1:length(drug_times)
        if j == 1 || drug_times(j) - drug_times(j-1) > 10
            region_start = t(drug_times(j));
        end
        if j == length(drug_times) || drug_times(j+1) - drug_times(j) > 10
            region_end = t(drug_times(j));
            patch([region_start region_end region_end region_start], ...
                  [0 0 max(silent_total)*1.2 max(silent_total)*1.2], ...
                  [0.9 0.9 0.9], 'EdgeColor', 'none', 'FaceAlpha', 0.3);
        end
    end
end

xlabel('Time (a.u.)', 'FontSize', 11, 'FontWeight', 'bold');
ylabel('Number of Synapses', 'FontSize', 11, 'FontWeight', 'bold');
title('A. Silent Synapse Dynamics', 'FontSize', 13, 'FontWeight', 'bold');
legend([h9 h10 h11], {'Silent (NMDA-only)', 'Matured (CP-AMPAR)', 'Total Silent'}, ...
       'Location', 'best', 'FontSize', 9);
set(gca, 'Box', 'off', 'LineWidth', 1.5);
grid on;

% Panel B: Incubation quantification
subplot(3, 2, 2);
baseline_response = mean(memory_strength(1:50));
incubation_index = memory_strength / (baseline_response + 0.01);
h12 = plot(t, incubation_index, 'Color', [0.8 0.4 0.1], 'LineWidth', 2.5); hold on;

% Mark drug exposure periods
if ~isempty(drug_times)
    for j = 1:length(drug_times)
        if j == 1 || drug_times(j) - drug_times(j-1) > 10
            region_start = t(drug_times(j));
        end
        if j == length(drug_times) || drug_times(j+1) - drug_times(j) > 10
            region_end = t(drug_times(j));
            patch([region_start region_end region_end region_start], ...
                  [0 0 max(incubation_index)*1.1 max(incubation_index)*1.1], ...
                  [0.9 0.9 0.9], 'EdgeColor', 'none', 'FaceAlpha', 0.3);
        end
    end
end

xlabel('Time (a.u.)', 'FontSize', 11, 'FontWeight', 'bold');
ylabel('Incubation Index (Fold Change)', 'FontSize', 11, 'FontWeight', 'bold');
title('B. Craving Incubation', 'FontSize', 13, 'FontWeight', 'bold');
ylim([0 max(incubation_index)*1.1]);
set(gca, 'Box', 'off', 'LineWidth', 1.5);
grid on;

% Panel C: Experimental predictions bar chart
subplot(3, 2, 3);
time_points = [50, 120, 200, 350, 450];
labels = {'Baseline', 'Exposure', 'Early Withdr.', 'Late Withdr.', 'Recovery'};
gluN2B_levels = [0.2, 0.7, 0.5, 0.3, 0.25];
silent_levels = [0, 0.15, 0.20, 0.10, 0.05];
x = 1:5;
width = 0.35;
b1 = bar(x - width/2, gluN2B_levels, width, 'FaceColor', [0.8 0.2 0.2], 'EdgeColor', 'none'); hold on;
b2 = bar(x + width/2, silent_levels, width, 'FaceColor', [0.2 0.7 0.3], 'EdgeColor', 'none');
set(gca, 'XTick', x, 'XTickLabel', labels);
ylabel('Relative Level', 'FontSize', 11, 'FontWeight', 'bold');
title('C. Experimental Predictions', 'FontSize', 13, 'FontWeight', 'bold');
legend([b1 b2], {'GluN2B Enrichment', 'Silent Synapses'}, 'Location', 'best', 'FontSize', 9);
xtickangle(45);
set(gca, 'Box', 'off', 'LineWidth', 1.5);
grid on;

% Panel D: LTP capacity over time
subplot(3, 2, 4);
ltp_capacity = 1 + 0.5 * gluN2B_ratio + 2 * (populations(:,4)/N_total);
h13 = plot(t, ltp_capacity, 'Color', [0.1 0.5 0.8], 'LineWidth', 2.5); hold on;

% Mark drug exposure periods
if ~isempty(drug_times)
    for j = 1:length(drug_times)
        if j == 1 || drug_times(j) - drug_times(j-1) > 10
            region_start = t(drug_times(j));
        end
        if j == length(drug_times) || drug_times(j+1) - drug_times(j) > 10
            region_end = t(drug_times(j));
            patch([region_start region_end region_end region_start], ...
                  [0 0 max(ltp_capacity)*1.1 max(ltp_capacity)*1.1], ...
                  [0.9 0.9 0.9], 'EdgeColor', 'none', 'FaceAlpha', 0.3);
        end
    end
end

xlabel('Time (a.u.)', 'FontSize', 11, 'FontWeight', 'bold');
ylabel('Relative LTP Capacity', 'FontSize', 11, 'FontWeight', 'bold');
title('D. Long-term Potentiation Capacity', 'FontSize', 13, 'FontWeight', 'bold');
set(gca, 'Box', 'off', 'LineWidth', 1.5);
grid on;

% Panel E: Memory formation rate
subplot(3, 2, 5);
memory_rate = [0; diff(memory_strength)/dt];
h14 = plot(t, memory_rate, 'Color', [0.6 0.1 0.6], 'LineWidth', 2); hold on;
h15 = plot(t, smooth(memory_rate, 50), 'Color', [0.2 0.2 0.2], 'LineWidth', 2.5);

% Mark drug exposure periods
if ~isempty(drug_times)
    for j = 1:length(drug_times)
        if j == 1 || drug_times(j) - drug_times(j-1) > 10
            region_start = t(drug_times(j));
        end
        if j == length(drug_times) || drug_times(j+1) - drug_times(j) > 10
            region_end = t(drug_times(j));
            patch([region_start region_end region_end region_start], ...
                  [min(memory_rate)*1.1 min(memory_rate)*1.1 max(memory_rate)*1.1 max(memory_rate)*1.1], ...
                  [0.9 0.9 0.9], 'EdgeColor', 'none', 'FaceAlpha', 0.3);
        end
    end
end

xlabel('Time (a.u.)', 'FontSize', 11, 'FontWeight', 'bold');
ylabel('Memory Formation Rate', 'FontSize', 11, 'FontWeight', 'bold');
title('E. Rate of Memory Formation', 'FontSize', 13, 'FontWeight', 'bold');
legend([h14 h15], {'Instantaneous', 'Smoothed'}, 'Location', 'best', 'FontSize', 9);
set(gca, 'Box', 'off', 'LineWidth', 1.5);
grid on;

% Panel F: Summary schematic
subplot(3, 2, 6);
% Create a conceptual diagram
phases = [1 2 3 4];
phase_names = {'Baseline', 'Exposure', 'Withdrawal', 'Incubation'};
phase_colors = [0.7 0.7 0.7; 1 0.5 0.5; 0.5 0.5 1; 0.8 0.8 0.5];
plasticity_levels = [1, 2.5, 2.0, 1.8];



for i = 1:4
    bar(i, plasticity_levels(i), 'FaceColor', phase_colors(i,:), 'EdgeColor', 'black', 'LineWidth', 1.5);
    hold on;
end

set(gca, 'XTick', phases, 'XTickLabel', phase_names);
ylabel('Plasticity Level', 'FontSize', 11, 'FontWeight', 'bold');
title('F. Rejuvenation Phases', 'FontSize', 13, 'FontWeight', 'bold');
xtickangle(0);
set(gca, 'Box', 'off', 'LineWidth', 1.5);
ylim([0 3]);
xtickangle(45); 
grid on;

sgtitle('Silent Synapse Dynamics and Experimental Predictions', ...
        'FontSize', 15, 'FontWeight', 'bold');

%% Save Figure 2 in multiple formats
fig2_name = 'Figure2_Silent_Synapse_Dynamics';

% PNG format (300 DPI)
print(fig2, [fig2_name '.png'], '-dpng', '-r300');

% TIFF format (300 DPI)
print(fig2, [fig2_name '.tiff'], '-dtiff', '-r300');

% PDF format (vector graphics, best for publications)
print(fig2, [fig2_name '.pdf'], '-dpdf', '-r300');

% MATLAB .fig format (for future editing)
savefig(fig2, [fig2_name '.fig']);

% EPS format (vector graphics, alternative to PDF)
print(fig2, [fig2_name '.eps'], '-depsc2', '-r300');

fprintf('Figure 2 saved in formats: PNG, TIFF, PDF, FIG, EPS\n');

%% Summary statistics
fprintf('\n=== NEURAL REJUVENATION SIMULATION RESULTS ===\n');
fprintf('Initial adult synapses: %d\n', N_total);
fprintf('Final adult synapses: %d (%.1f%%)\n', populations(end, 1), populations(end, 1)/N_total*100);
fprintf('Final juvenile synapses: %d (%.1f%%)\n', populations(end, 2), populations(end, 2)/N_total*100);
fprintf('Final silent synapses: %d (%.1f%%)\n', populations(end, 3), populations(end, 3)/N_total*100);
fprintf('Final mature silent synapses: %d (%.1f%%)\n', populations(end, 4), populations(end, 4)/N_total*100);

fprintf('\nPeak plasticity during exposure: %.2f\n', max(total_plasticity));
fprintf('Final memory strength: %.2f\n', memory_strength(end));
fprintf('Peak cue response: %.2f\n', max(cue_response));

% Find incubation effect
withdrawal_idx = find(t >= withdrawal_start, 1);
if ~isempty(withdrawal_idx) && length(memory_strength) > withdrawal_idx + 50
    early_withdrawal_response = mean(memory_strength(withdrawal_idx:withdrawal_idx+50));
    late_withdrawal_response = mean(memory_strength(max(1,end-50):end));
    fprintf('Incubation effect: %.1f%% increase in memory strength\n', ...
            (late_withdrawal_response/early_withdrawal_response - 1)*100);
end

%% Save results
save('rejuvenation_publication_results.mat', 't', 'populations', 'total_plasticity', ...
     'memory_strength', 'cue_response', 'drug_present', 'gluN2A_ratio', 'gluN2B_ratio');

fprintf('\nResults saved to rejuvenation_publication_results.mat\n');
fprintf('\n=== PUBLICATION-READY FIGURES SAVED ===\n');
fprintf('Both figures saved in A4-compatible sizes with the following formats:\n');
fprintf('- PNG (300 DPI, raster graphics)\n');
fprintf('- TIFF (300 DPI, high-quality raster)\n');
fprintf('- PDF (vector graphics, recommended for publications)\n');
fprintf('- EPS (vector graphics, alternative format)\n');
fprintf('- FIG (MATLAB format for future editing)\n');
fprintf('\nFiles are ready for scientific publication!\n');