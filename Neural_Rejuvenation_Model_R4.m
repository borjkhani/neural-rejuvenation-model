%% ========================================================================
% NEURAL REJUVENATION HYPOTHESIS - COMPLETE MANUSCRIPT CODE (REVISED R4)
% ========================================================================
% Population-Level Neural Rejuvenation Dynamics in Addiction:
% A Computational Framework for Understanding Developmental Plasticity Reactivation
%
% Authors: Mehdi Borjkhani, Hadi Borjkhani, Morteza A. Sharif
% Frontiers in Computational Neuroscience
%
% REVISION R4 - Key fixes addressing reviewer concerns:
% 1. PHASE-GATED maturation/pruning: only during withdrawal (1-D(t))
% 2. PHASE-GATED genesis: only during exposure D(t)
% 3. CARRYING CAPACITY (K_max) for silent synapse genesis
% 4. MEMORY SATURATION to prevent unbounded growth
% 5. FLUX-DRIVEN incubation (depends on maturation rate, not N_mature)
% 6. Explicit D(t) definition for intermittent exposures
% ========================================================================

clear all; close all; clc;

fprintf('=== Neural Rejuvenation Model - REVISED R4 ===\n');
fprintf('Key fixes: Phase-gating, carrying capacity, memory saturation\n\n');

%% ========================================================================
% PART 1: MODEL PARAMETERS AND SETUP
% ========================================================================

%% Time Scaling (1 time unit = 2 hours)
dt = 0.1;                    % Time step (= 12 minutes biological time)
t_total = 500;               % Total simulation (≈ 42 days)
t = 0:dt:t_total;
n_steps = length(t);

%% Drug Exposure Protocol - EXPLICITLY DEFINED D(t)
% D(t) is a binary pulse train: 5 pulses of width tau, separated by DeltaT
exposure_start = 100;        % t_start = 100 (Day 8)
n_exposures = 5;             % 5 exposure sessions
exposure_duration = 5;       % tau = 5 time units (10 hours each)
exposure_interval = 30;      % DeltaT = 30 time units (2.5 days between sessions)
withdrawal_start = exposure_start + (n_exposures-1) * exposure_interval + exposure_duration;

%% Initial Population
N_baseline = 1000;           % N_0 = 1000 baseline synapse count

%% Rate Constants (Table 1 in manuscript)
% PROCESS 1: Rejuvenation (receptor switching)
k_adult_to_juvenile = 0.08;  % time^-1 (0.04 h^-1 under time scaling)
k_juvenile_to_adult = 0.02;  % time^-1, recovery slower than induction

% PROCESS 2: Silent synapse dynamics (de novo generation)
k_silent_genesis = 15;       % syn/time (7.5 syn/hour under time scaling)
k_silent_maturation = 0.04;  % time^-1, maturation over days-weeks
k_silent_pruning = 0.01;     % time^-1, ~50-70% elimination rate

% NEW: Carrying capacity for silent synapses (prevents unbounded growth)
K_max = 500;                 % Maximum silent synapse capacity

%% Plasticity Weights (heuristic values based on receptor properties)
plasticity_adult = 1.0;      % Baseline (GluN2A-dominant)
plasticity_juvenile = 2.5;   % Enhanced Ca2+ dynamics (GluN2B)
plasticity_silent = 0.5;     % No functional AMPAR
plasticity_mature = 3.0;     % CP-AMPAR high conductance

%% Memory equation parameters
alpha_mem = 0.5;             % Exposure-phase memory formation rate
beta_mem = 0.1;              % Flux-driven incubation coefficient
M_max = 30;                  % Memory saturation level

%% Store baseline parameters for sensitivity analysis
baseline_params = [k_adult_to_juvenile, k_silent_genesis, k_silent_maturation];

%% ========================================================================
% PART 2: MAIN SIMULATION WITH PHASE-GATED EQUATIONS
% ========================================================================

fprintf('Running main cocaine simulation with phase-gated equations...\n');

% Initialize state variables
N_adult = N_baseline;
N_juvenile = 0;
N_silent = 0;
N_mature = 0;

% Initialize storage arrays
populations = zeros(n_steps, 4);
N_total_array = zeros(n_steps, 1);
drug_present = zeros(n_steps, 1);
total_plasticity = zeros(n_steps, 1);
memory_strength = zeros(n_steps, 1);
cue_response = zeros(n_steps, 1);

current_memory = 0;

%% Main simulation loop with PHASE-GATED DYNAMICS
for i = 1:n_steps
    current_time = t(i);
    
    %% Determine D(t) - Drug exposure function (Equation 2)
    % D(t) = 1 if t is within any of the 5 exposure windows, else 0
    drug_exposure = 0;
    for exp = 1:n_exposures
        exp_start = exposure_start + (exp-1) * exposure_interval;
        exp_end = exp_start + exposure_duration;
        if current_time >= exp_start && current_time <= exp_end
            drug_exposure = 1;
            break;
        end
    end
    drug_present(i) = drug_exposure;
    D_t = drug_exposure;        % D(t)
    one_minus_D = 1 - D_t;      % (1-D(t))
    
    %% PROCESS 1: Rejuvenation dynamics (Equations 3-4)
    % Adult -> Juvenile: gated by D(t) (during exposure)
    % Juvenile -> Adult: gated by (1-D(t)) (during withdrawal)
    
    delta_adult_to_juv = k_adult_to_juvenile * N_adult * D_t * dt;
    delta_juv_to_adult = k_juvenile_to_adult * N_juvenile * one_minus_D * dt;
    
    N_adult = N_adult - delta_adult_to_juv + delta_juv_to_adult;
    N_juvenile = N_juvenile + delta_adult_to_juv - delta_juv_to_adult;
    
    % Ensure non-negative populations
    N_adult = max(0, N_adult);
    N_juvenile = max(0, N_juvenile);
    
    %% PROCESS 2: Silent synapse dynamics (Equations 5-6) - PHASE-GATED
    % Genesis: only during exposure, with carrying capacity
    % Maturation & Pruning: only during withdrawal
    
    % Genesis term with carrying capacity (Equation 5)
    genesis_term = k_silent_genesis * D_t * (1 - N_silent/K_max) * dt;
    genesis_term = max(0, genesis_term);  % Ensure non-negative
    
    % Maturation and pruning: ONLY during withdrawal (1-D(t)) factor
    maturation_term = one_minus_D * k_silent_maturation * N_silent * dt;
    pruning_term = one_minus_D * k_silent_pruning * N_silent * dt;
    
    % Update silent synapse population
    N_silent = N_silent + genesis_term - maturation_term - pruning_term;
    N_silent = max(0, N_silent);
    
    % Update mature synapse population (Equation 6)
    N_mature = N_mature + maturation_term;
    
    %% Calculate totals
    N_total = N_adult + N_juvenile + N_silent + N_mature;
    N_total_array(i) = N_total;
    
    %% Plasticity capacity (Equation 7)
    total_plasticity(i) = (N_adult * plasticity_adult + ...
                          N_juvenile * plasticity_juvenile + ...
                          N_silent * plasticity_silent + ...
                          N_mature * plasticity_mature) / N_baseline;
    
    %% Memory formation with saturation (Equation 8)
    saturation_factor = (1 - current_memory / M_max);
    saturation_factor = max(0, saturation_factor);  % Ensure non-negative
    
    if D_t == 1
        % During exposure: memory grows with plasticity
        memory_increment = alpha_mem * total_plasticity(i) * saturation_factor;
    else
        % During withdrawal: FLUX-DRIVEN incubation
        % Memory growth depends on maturation FLUX, not N_mature
        maturation_flux = k_silent_maturation * N_silent;  % This is the flux
        memory_increment = beta_mem * (maturation_flux / N_baseline) * saturation_factor;
    end
    current_memory = current_memory + memory_increment * dt;
    memory_strength(i) = current_memory;
    
    %% Cue response (for visualization)
    if mod(current_time, 50) < 2
        cue_response(i) = memory_strength(i) * total_plasticity(i) * 0.8;
    else
        cue_response(i) = 0;
    end
    
    %% Store populations
    populations(i, :) = [N_adult, N_juvenile, N_silent, N_mature];
end

%% Calculate NMDA receptor composition (Equation 9)
gluN2B_juvenile = populations(:,2);
gluN2B_silent = populations(:,3) * 0.8;     % Silent synapses are GluN2B-rich
gluN2B_mature = populations(:,4) * 0.3;     % Mature retain some GluN2B
total_gluN2B = gluN2B_juvenile + gluN2B_silent + gluN2B_mature;
gluN2B_ratio = total_gluN2B ./ (N_total_array + 0.001);
gluN2A_ratio = 1 - gluN2B_ratio;

%% Verify conservation for Process 1
N_functional = populations(:,1) + populations(:,2);
conservation_error = max(abs(N_functional - N_baseline));
fprintf('Process 1 conservation check: max error = %.2e (should be ~0)\n', conservation_error);

fprintf('Main simulation complete.\n');
fprintf('  Peak total synapses: %.0f (%.1f%% increase)\n', max(N_total_array), (max(N_total_array)/N_baseline-1)*100);
fprintf('  Final memory strength: %.2f (saturation at %.0f)\n', memory_strength(end), M_max);

%% ========================================================================
% PART 3: PARAMETER SENSITIVITY ANALYSIS
% ========================================================================

fprintf('\nRunning parameter sensitivity analysis...\n');

param_variations = [0.5, 0.75, 1.0, 1.25, 1.5];
param_names = {'k_{a→j}', 'k_{genesis}', 'k_{maturation}'};
n_params = 3;
n_vars = length(param_variations);

sensitivity_results = zeros(n_vars, n_params, 3);

for p = 1:n_params
    for v = 1:n_vars
        test_params = baseline_params;
        test_params(p) = baseline_params(p) * param_variations(v);
        
        [test_memory, test_juvenile_peak, test_mature] = run_sensitivity_simulation_R4(...
            test_params(1), test_params(2), test_params(3), ...
            k_juvenile_to_adult, k_silent_pruning, K_max, M_max, ...
            t, n_steps, dt, exposure_start, n_exposures, exposure_interval, ...
            exposure_duration, N_baseline, ...
            plasticity_adult, plasticity_juvenile, plasticity_silent, plasticity_mature, ...
            alpha_mem, beta_mem);
        
        sensitivity_results(v, p, 1) = test_memory;
        sensitivity_results(v, p, 2) = test_juvenile_peak;
        sensitivity_results(v, p, 3) = test_mature;
    end
end

baseline_memory = sensitivity_results(3, 1, 1);
sensitivity_normalized = sensitivity_results(:,:,1) / baseline_memory;

fprintf('Parameter sensitivity analysis complete.\n');

%% ========================================================================
% PART 4: NATURAL REWARD SIMULATION
% ========================================================================

fprintf('\nRunning natural reward comparison simulation...\n');

k_genesis_natural = 0;           % No silent synapse generation
k_a2j_natural = 0.008;           % 10% of cocaine effect

N_adult_nat = N_baseline;
N_juvenile_nat = 0;
N_silent_nat = 0;
N_mature_nat = 0;

populations_natural = zeros(n_steps, 4);
N_total_natural = zeros(n_steps, 1);
memory_natural = zeros(n_steps, 1);
plasticity_natural = zeros(n_steps, 1);
current_memory_nat = 0;

for i = 1:n_steps
    current_time = t(i);
    
    % Determine D(t)
    D_t = 0;
    for exp = 1:n_exposures
        exp_start = exposure_start + (exp-1) * exposure_interval;
        exp_end = exp_start + exposure_duration;
        if current_time >= exp_start && current_time <= exp_end
            D_t = 1;
            break;
        end
    end
    one_minus_D = 1 - D_t;
    
    % Process 1: Rejuvenation (reduced rate for natural rewards)
    delta_aj = k_a2j_natural * N_adult_nat * D_t * dt;
    delta_ja = k_juvenile_to_adult * N_juvenile_nat * one_minus_D * dt;
    N_adult_nat = max(0, N_adult_nat - delta_aj + delta_ja);
    N_juvenile_nat = max(0, N_juvenile_nat + delta_aj - delta_ja);
    
    % Process 2: No silent synapse genesis for natural rewards
    genesis = k_genesis_natural * D_t * (1 - N_silent_nat/K_max) * dt;
    mat_term = one_minus_D * k_silent_maturation * N_silent_nat * dt;
    prune_term = one_minus_D * k_silent_pruning * N_silent_nat * dt;
    N_silent_nat = max(0, N_silent_nat + genesis - mat_term - prune_term);
    N_mature_nat = N_mature_nat + mat_term;
    
    N_total_natural(i) = N_adult_nat + N_juvenile_nat + N_silent_nat + N_mature_nat;
    
    plasticity_natural(i) = (N_adult_nat * plasticity_adult + ...
                            N_juvenile_nat * plasticity_juvenile + ...
                            N_silent_nat * plasticity_silent + ...
                            N_mature_nat * plasticity_mature) / N_baseline;
    
    % Memory with saturation
    sat_factor = max(0, 1 - current_memory_nat / M_max);
    if D_t == 1
        current_memory_nat = current_memory_nat + alpha_mem * plasticity_natural(i) * sat_factor * dt;
    else
        mat_flux = k_silent_maturation * N_silent_nat;
        current_memory_nat = current_memory_nat + beta_mem * (mat_flux / N_baseline) * sat_factor * dt;
    end
    memory_natural(i) = current_memory_nat;
    
    populations_natural(i, :) = [N_adult_nat, N_juvenile_nat, N_silent_nat, N_mature_nat];
end

fprintf('Natural reward simulation complete.\n');
fprintf('  Final cocaine memory: %.2f\n', memory_strength(end));
fprintf('  Final natural reward memory: %.2f\n', memory_natural(end));
fprintf('  Ratio (cocaine/natural): %.1fx\n', memory_strength(end)/max(memory_natural(end), 0.01));

%% ========================================================================
% PART 5: FIGURE GENERATION
% ========================================================================

fprintf('\n=== Generating Publication Figures ===\n');

set(0, 'DefaultFigureColor', 'white');
set(0, 'DefaultAxesLineWidth', 1.5);
set(0, 'DefaultLineLineWidth', 2);
set(0, 'DefaultAxesFontSize', 11);
set(0, 'DefaultTextFontSize', 11);

A4_width = 8.27;
A4_height = 11.69;

drug_times = find(drug_present > 0);

colors_pop = [0.2 0.4 0.8;   % Adult - blue
              0.8 0.2 0.2;   % Juvenile - red
              0.2 0.7 0.3;   % Silent - green
              0.7 0.2 0.7];  % Mature - purple

%% FIGURE 1: Core Neural Rejuvenation Dynamics
fig1 = figure('Position', [50, 50, 800, 1000], 'Color', 'white');
set(fig1, 'Units', 'inches');
set(fig1, 'Position', [0.5, 0.5, A4_width, A4_height*0.85]);
set(fig1, 'PaperUnits', 'inches');
set(fig1, 'PaperSize', [A4_width, A4_height*0.85]);
set(fig1, 'PaperPosition', [0, 0, A4_width, A4_height*0.85]);

% Panel A: Drug exposure timeline
subplot(3, 2, 1);
yyaxis left
h_cue = stem(t(cue_response > 0), cue_response(cue_response > 0), 'g', 'LineWidth', 2, 'MarkerSize', 6);
ylabel('Cue Response Strength', 'FontSize', 11, 'FontWeight', 'bold');
set(gca, 'YColor', [0.2 0.7 0.3]);
ylim([0 max(cue_response)*1.2]);

yyaxis right
drug_timeline = zeros(size(t));
drug_timeline(drug_present > 0) = 1;
h_drug = area(t, drug_timeline, 'FaceColor', [0.8 0.3 0.3], 'EdgeColor', 'none', 'FaceAlpha', 0.6);
ylabel('Drug Exposure D(t)', 'FontSize', 11, 'FontWeight', 'bold');
set(gca, 'YColor', [0.8 0.3 0.3], 'YTick', [0 1], 'YTickLabel', {'Off', 'On'});
ylim([0 1.2]);

xlabel('Time (a.u.)', 'FontSize', 11, 'FontWeight', 'bold');
title('A. Drug Exposure & Cue Responses', 'FontSize', 13, 'FontWeight', 'bold');
set(gca, 'Box', 'off', 'LineWidth', 1.5);

text(50, 0.5, 'Baseline', 'FontSize', 9, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
text(160, 0.5, 'Exposure', 'FontSize', 9, 'FontWeight', 'bold', 'HorizontalAlignment', 'center', 'Color', [0.8 0.3 0.3]);
text(300, 0.5, 'Withdrawal', 'FontSize', 9, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
text(450, 0.5, 'Incubation', 'FontSize', 9, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');

% Panel B: Population dynamics
subplot(3, 2, 2);
h1 = plot(t, populations(:,1), 'Color', colors_pop(1,:), 'LineWidth', 2.5); hold on;
h2 = plot(t, populations(:,2), 'Color', colors_pop(2,:), 'LineWidth', 2.5);
h3 = plot(t, populations(:,3), 'Color', colors_pop(3,:), 'LineWidth', 2.5);
h4 = plot(t, populations(:,4), 'Color', colors_pop(4,:), 'LineWidth', 2.5);
h5 = plot(t, N_total_array, 'k--', 'LineWidth', 1.5);
add_drug_shading(t, drug_times, max(N_total_array)*1.1);

xlabel('Time (a.u.)', 'FontSize', 11, 'FontWeight', 'bold');
ylabel('Number of Synapses', 'FontSize', 11, 'FontWeight', 'bold');
title('B. Synapse Population Dynamics', 'FontSize', 13, 'FontWeight', 'bold');
legend([h1 h2 h3 h4 h5], {'Adult (GluN2A)', 'Juvenile (GluN2B)', 'Silent', ...
       'Matured (CP-AMPAR)', 'Total'}, 'Location', 'best', 'FontSize', 9);
set(gca, 'Box', 'off', 'LineWidth', 1.5);
grid on;

% Panel C: NMDA receptor composition
subplot(3, 2, 3);
h6 = plot(t, gluN2A_ratio, 'Color', [0.2 0.4 0.8], 'LineWidth', 2.5); hold on;
h7 = plot(t, gluN2B_ratio, 'Color', [0.8 0.2 0.2], 'LineWidth', 2.5);
add_drug_shading(t, drug_times, 1.1);

xlabel('Time (a.u.)', 'FontSize', 11, 'FontWeight', 'bold');
ylabel('Receptor Subunit Ratio', 'FontSize', 11, 'FontWeight', 'bold');
title('C. NMDA Receptor Rejuvenation', 'FontSize', 13, 'FontWeight', 'bold');
legend([h6 h7], {'GluN2A (Adult)', 'GluN2B (Juvenile + Silent)'}, 'Location', 'best', 'FontSize', 9);
ylim([0 1]);
set(gca, 'Box', 'off', 'LineWidth', 1.5);
grid on;

% Panel D: Memory formation with saturation line
subplot(3, 2, 4);
plot(t, memory_strength, 'Color', [0.5 0.1 0.5], 'LineWidth', 2.5); hold on;
plot([0 t_total], [M_max M_max], 'k--', 'LineWidth', 1.5);
add_drug_shading(t, drug_times, M_max*1.1);

xlabel('Time (a.u.)', 'FontSize', 11, 'FontWeight', 'bold');
ylabel('Memory Strength', 'FontSize', 11, 'FontWeight', 'bold');
title('D. Memory Formation & Incubation', 'FontSize', 13, 'FontWeight', 'bold');
legend({'Memory M(t)', 'Saturation M_{max}'}, 'Location', 'southeast', 'FontSize', 9);
set(gca, 'Box', 'off', 'LineWidth', 1.5);
grid on;

% Panel E: Plasticity capacity
subplot(3, 2, 5);
plot(t, total_plasticity, 'Color', [0.1 0.5 0.3], 'LineWidth', 2.5); hold on;
add_drug_shading(t, drug_times, max(total_plasticity)*1.1);

xlabel('Time (a.u.)', 'FontSize', 11, 'FontWeight', 'bold');
ylabel('Plasticity Capacity', 'FontSize', 11, 'FontWeight', 'bold');
title('E. Enhanced Plasticity Window', 'FontSize', 13, 'FontWeight', 'bold');
set(gca, 'Box', 'off', 'LineWidth', 1.5);
grid on;

% Panel F: Plasticity levels
subplot(3, 2, 6);
synapse_types = {'Adult', 'Juvenile', 'Silent', 'Matured'};
plasticity_weights = [plasticity_adult, plasticity_juvenile, plasticity_silent, plasticity_mature];
for i = 1:4
    bar(i, plasticity_weights(i), 'FaceColor', colors_pop(i,:), 'EdgeColor', 'k', 'LineWidth', 1.5);
    hold on;
end
set(gca, 'XTick', 1:4, 'XTickLabel', synapse_types);
ylabel('Plasticity Level', 'FontSize', 11, 'FontWeight', 'bold');
title('F. Synapse Type Plasticity', 'FontSize', 13, 'FontWeight', 'bold');
xtickangle(45);
set(gca, 'Box', 'off', 'LineWidth', 1.5);
grid on;

sgtitle('Neural Rejuvenation Hypothesis: Population-Level Dynamics (R4 - Phase-Gated)', ...
        'FontSize', 14, 'FontWeight', 'bold');

print(fig1, 'Figure1_Neural_Rejuvenation_Dynamics_REVISED.png', '-dpng', '-r300');
print(fig1, 'Figure1_Neural_Rejuvenation_Dynamics_REVISED.pdf', '-dpdf', '-r300');
savefig(fig1, 'Figure1_Neural_Rejuvenation_Dynamics_REVISED.fig');
fprintf('Figure 1 saved.\n');

%% FIGURE 2: Silent Synapse Dynamics
fig2 = figure('Position', [100, 50, 800, 1000], 'Color', 'white');
set(fig2, 'Units', 'inches');
set(fig2, 'Position', [1, 0.5, A4_width, A4_height*0.85]);
set(fig2, 'PaperUnits', 'inches');
set(fig2, 'PaperSize', [A4_width, A4_height*0.85]);
set(fig2, 'PaperPosition', [0, 0, A4_width, A4_height*0.85]);

% Panel A: Silent synapse dynamics
subplot(3, 2, 1);
total_silent = populations(:,3) + populations(:,4);
h9 = plot(t, populations(:,3), 'Color', colors_pop(3,:), 'LineWidth', 2.5); hold on;
h10 = plot(t, populations(:,4), 'Color', colors_pop(4,:), 'LineWidth', 2.5);
h11 = plot(t, total_silent, 'k--', 'LineWidth', 1.5);
plot([0 t_total], [K_max K_max], 'g:', 'LineWidth', 1.5);
add_drug_shading(t, drug_times, K_max*1.2);

xlabel('Time (a.u.)', 'FontSize', 11, 'FontWeight', 'bold');
ylabel('Number of Synapses', 'FontSize', 11, 'FontWeight', 'bold');
title('A. Silent Synapse Dynamics (Phase-Gated)', 'FontSize', 13, 'FontWeight', 'bold');
legend([h9 h10 h11], {'Silent (NMDA-only)', 'Matured (CP-AMPAR)', 'Total Silent'}, ...
       'Location', 'best', 'FontSize', 9);
set(gca, 'Box', 'off', 'LineWidth', 1.5);
grid on;

% Panel B: Incubation index
subplot(3, 2, 2);
baseline_response = mean(memory_strength(1:50)) + 0.01;
incubation_index = (memory_strength + 1) / (baseline_response + 1);
plot(t, incubation_index, 'Color', [0.8 0.4 0.1], 'LineWidth', 2.5); hold on;
add_drug_shading(t, drug_times, max(incubation_index)*1.1);

xlabel('Time (a.u.)', 'FontSize', 11, 'FontWeight', 'bold');
ylabel('Incubation Index (Fold Change)', 'FontSize', 11, 'FontWeight', 'bold');
title('B. Craving Incubation', 'FontSize', 13, 'FontWeight', 'bold');
set(gca, 'Box', 'off', 'LineWidth', 1.5);
grid on;

% Panel C: Experimental predictions
subplot(3, 2, 3);
time_points = [50, 150, 250, 400, 480];
phase_labels = {'Baseline', 'Exposure', 'Early Withdr.', 'Late Withdr.', 'Recovery'};

gluN2B_levels = zeros(1, 5);
silent_levels = zeros(1, 5);
for tp = 1:5
    [~, idx] = min(abs(t - time_points(tp)));
    gluN2B_levels(tp) = gluN2B_ratio(idx);
    silent_levels(tp) = (populations(idx, 3) + populations(idx, 4)) / N_baseline;
end

x = 1:5;
width = 0.35;
b1 = bar(x - width/2, gluN2B_levels, width, 'FaceColor', [0.8 0.2 0.2], 'EdgeColor', 'none'); hold on;
b2 = bar(x + width/2, silent_levels, width, 'FaceColor', [0.2 0.7 0.3], 'EdgeColor', 'none');
set(gca, 'XTick', x, 'XTickLabel', phase_labels);
ylabel('Relative Level', 'FontSize', 11, 'FontWeight', 'bold');
title('C. Experimental Predictions', 'FontSize', 13, 'FontWeight', 'bold');
legend([b1 b2], {'GluN2B Enrichment', 'Silent Synapses'}, 'Location', 'northeast', 'FontSize', 9);
xtickangle(45);
set(gca, 'Box', 'off', 'LineWidth', 1.5);
grid on;

% Panel D: LTP capacity
subplot(3, 2, 4);
ltp_capacity = 1 + 0.5 * gluN2B_ratio + 2 * (populations(:,4)/N_baseline);
plot(t, ltp_capacity, 'Color', [0.1 0.5 0.8], 'LineWidth', 2.5); hold on;
add_drug_shading(t, drug_times, max(ltp_capacity)*1.1);

xlabel('Time (a.u.)', 'FontSize', 11, 'FontWeight', 'bold');
ylabel('Relative LTP Capacity', 'FontSize', 11, 'FontWeight', 'bold');
title('D. Long-term Potentiation Capacity', 'FontSize', 13, 'FontWeight', 'bold');
set(gca, 'Box', 'off', 'LineWidth', 1.5);
grid on;

% Panel E: Memory formation rate
subplot(3, 2, 5);
memory_rate = [0; diff(memory_strength)/dt];
h14 = plot(t, memory_rate, 'Color', [0.6 0.1 0.6], 'LineWidth', 1.5); hold on;
h15 = plot(t, smooth(memory_rate, 50), 'Color', [0.2 0.2 0.2], 'LineWidth', 2.5);
add_drug_shading(t, drug_times, max(memory_rate)*1.1);

xlabel('Time (a.u.)', 'FontSize', 11, 'FontWeight', 'bold');
ylabel('Memory Formation Rate', 'FontSize', 11, 'FontWeight', 'bold');
title('E. Rate of Memory Formation (Flux-Driven)', 'FontSize', 13, 'FontWeight', 'bold');
legend([h14 h15], {'Instantaneous', 'Smoothed'}, 'Location', 'best', 'FontSize', 9);
set(gca, 'Box', 'off', 'LineWidth', 1.5);
grid on;

% Panel F: Dynamic population
subplot(3, 2, 6);
plot(t, N_total_array, 'Color', [0.3 0.3 0.3], 'LineWidth', 2.5); hold on;
plot(t, ones(size(t))*N_baseline, 'r--', 'LineWidth', 2);
add_drug_shading(t, drug_times, max(N_total_array)*1.05);

xlabel('Time (a.u.)', 'FontSize', 11, 'FontWeight', 'bold');
ylabel('Total Synapse Count', 'FontSize', 11, 'FontWeight', 'bold');
title('F. Dynamic Population Size', 'FontSize', 13, 'FontWeight', 'bold');
legend({'Total N(t)', 'Baseline N_0'}, 'Location', 'southeast', 'FontSize', 9);
set(gca, 'Box', 'off', 'LineWidth', 1.5);
grid on;

sgtitle('Silent Synapse Dynamics and Experimental Predictions', ...
        'FontSize', 14, 'FontWeight', 'bold');

print(fig2, 'Figure2_Silent_Synapse_Dynamics_FINAL.png', '-dpng', '-r300');
print(fig2, 'Figure2_Silent_Synapse_Dynamics_FINAL.pdf', '-dpdf', '-r300');
savefig(fig2, 'Figure2_Silent_Synapse_Dynamics_FINAL.fig');
fprintf('Figure 2 saved.\n');

%% FIGURE 3: Model Validation
fig3 = figure('Position', [150, 50, 800, 700], 'Color', 'white');
set(fig3, 'Units', 'inches');
set(fig3, 'Position', [1.5, 0.5, A4_width, A4_height*0.6]);
set(fig3, 'PaperUnits', 'inches');
set(fig3, 'PaperSize', [A4_width, A4_height*0.6]);
set(fig3, 'PaperPosition', [0, 0, A4_width, A4_height*0.6]);

% Panel A: Sensitivity analysis
subplot(2, 2, 1);
colors_sens = [0.2 0.4 0.8; 0.8 0.2 0.2; 0.2 0.7 0.3];
markers = {'o', 's', 'd'};

for p = 1:3
    normalized = sensitivity_results(:, p, 1) / sensitivity_results(3, p, 1);
    plot(param_variations, normalized, ['-' markers{p}], 'Color', colors_sens(p,:), ...
         'LineWidth', 2, 'MarkerSize', 8, 'MarkerFaceColor', colors_sens(p,:));
    hold on;
end
plot([0.4 1.6], [1 1], 'k--', 'LineWidth', 1.5);

xlabel('Parameter Multiplier', 'FontSize', 11, 'FontWeight', 'bold');
ylabel('Relative Final Memory', 'FontSize', 11, 'FontWeight', 'bold');
title('A. Parameter Sensitivity Analysis', 'FontSize', 13, 'FontWeight', 'bold');
legend([param_names, {'Baseline'}], 'Location', 'northwest', 'FontSize', 9);
xlim([0.4 1.6]);
set(gca, 'Box', 'off', 'LineWidth', 1.5);
grid on;

% Panel B: Plasticity across phases
subplot(2, 2, 2);
phase_times = [50, 150, 300, 450];
phase_names_short = {'Baseline', 'Exposure', 'Withdrawal', 'Incubation'};
phase_colors = [0.7 0.7 0.7; 1 0.5 0.5; 0.5 0.5 1; 0.8 0.8 0.5];

plasticity_by_phase = zeros(1, 4);
for p = 1:4
    [~, idx] = min(abs(t - phase_times(p)));
    plasticity_by_phase(p) = total_plasticity(idx);
end

for i = 1:4
    bar(i, plasticity_by_phase(i), 'FaceColor', phase_colors(i,:), ...
        'EdgeColor', 'black', 'LineWidth', 1.5);
    hold on;
end
set(gca, 'XTick', 1:4, 'XTickLabel', phase_names_short);
ylabel('Plasticity Capacity', 'FontSize', 11, 'FontWeight', 'bold');
title('B. Plasticity Across Phases', 'FontSize', 13, 'FontWeight', 'bold');
xtickangle(45);
ylim([0 max(plasticity_by_phase)*1.3]);
set(gca, 'Box', 'off', 'LineWidth', 1.5);
grid on;

% Panel C: Cocaine vs Natural Reward - Memory
subplot(2, 2, 3);
plot(t, memory_strength, 'Color', [0.8 0.2 0.2], 'LineWidth', 2.5); hold on;
plot(t, memory_natural, 'Color', [0.2 0.6 0.2], 'LineWidth', 2.5);
plot([0 t_total], [M_max M_max], 'k:', 'LineWidth', 1);
add_drug_shading(t, drug_times, M_max*1.1);

xlabel('Time (a.u.)', 'FontSize', 11, 'FontWeight', 'bold');
ylabel('Memory Strength', 'FontSize', 11, 'FontWeight', 'bold');
title('C. Cocaine vs Natural Reward: Memory', 'FontSize', 13, 'FontWeight', 'bold');
legend({'Cocaine', 'Natural Reward', 'M_{max}'}, 'Location', 'northwest', 'FontSize', 10);
set(gca, 'Box', 'off', 'LineWidth', 1.5);
grid on;

% Panel D: Cocaine vs Natural Reward - Population
subplot(2, 2, 4);
plot(t, N_total_array, 'Color', [0.8 0.2 0.2], 'LineWidth', 2.5); hold on;
plot(t, N_total_natural, 'Color', [0.2 0.6 0.2], 'LineWidth', 2.5);
plot(t, ones(size(t))*N_baseline, 'k--', 'LineWidth', 1.5);
add_drug_shading(t, drug_times, max(N_total_array)*1.05);

xlabel('Time (a.u.)', 'FontSize', 11, 'FontWeight', 'bold');
ylabel('Total Synapse Count', 'FontSize', 11, 'FontWeight', 'bold');
title('D. Cocaine vs Natural Reward: Population', 'FontSize', 13, 'FontWeight', 'bold');
legend({'Cocaine', 'Natural Reward', 'Baseline'}, 'Location', 'east', 'FontSize', 9);
set(gca, 'Box', 'off', 'LineWidth', 1.5);
grid on;

sgtitle('Figure 3: Model Validation and Natural Reward Comparison', ...
        'FontSize', 14, 'FontWeight', 'bold');

print(fig3, 'Figure3_Model_Validation.png', '-dpng', '-r300');
print(fig3, 'Figure3_Model_Validation.pdf', '-dpdf', '-r300');
savefig(fig3, 'Figure3_Model_Validation.fig');
fprintf('Figure 3 saved.\n');

%% ========================================================================
% PART 6: SAVE RESULTS
% ========================================================================

save('Neural_Rejuvenation_Results_R4.mat', ...
     't', 'dt', 'populations', 'N_total_array', 'total_plasticity', ...
     'memory_strength', 'cue_response', 'drug_present', ...
     'gluN2A_ratio', 'gluN2B_ratio', ...
     'sensitivity_results', 'param_variations', ...
     'populations_natural', 'N_total_natural', 'memory_natural', ...
     'N_baseline', 'K_max', 'M_max', 'exposure_start', 'withdrawal_start');

fprintf('\n=== SIMULATION COMPLETE (R4) ===\n');
fprintf('Key model features:\n');
fprintf('  - Phase-gated maturation/pruning (withdrawal only)\n');
fprintf('  - Phase-gated genesis (exposure only)\n');
fprintf('  - Carrying capacity K_max = %d\n', K_max);
fprintf('  - Memory saturation M_max = %d\n', M_max);
fprintf('  - Flux-driven incubation (not N_mature-driven)\n\n');

fprintf('=== KEY RESULTS SUMMARY ===\n');
fprintf('%-35s %s\n', 'Metric', 'Value');
fprintf('%-35s %s\n', repmat('-', 1, 35), repmat('-', 1, 15));
fprintf('%-35s %.0f\n', 'Baseline synapses:', N_baseline);
fprintf('%-35s %.0f (%.1f%%)\n', 'Peak total synapses (cocaine):', max(N_total_array), (max(N_total_array)/N_baseline-1)*100);
fprintf('%-35s %.2f / %.0f\n', 'Final memory (cocaine) / M_max:', memory_strength(end), M_max);
fprintf('%-35s %.2f\n', 'Final memory (natural):', memory_natural(end));
fprintf('%-35s %.1fx\n', 'Cocaine/Natural ratio:', memory_strength(end)/max(memory_natural(end), 0.01));

%% ========================================================================
% HELPER FUNCTIONS
% ========================================================================

function add_drug_shading(t, drug_times, y_max)
    if isempty(drug_times)
        return;
    end
    
    j = 1;
    while j <= length(drug_times)
        region_start = t(drug_times(j));
        while j < length(drug_times) && drug_times(j+1) - drug_times(j) <= 10
            j = j + 1;
        end
        region_end = t(drug_times(j));
        
        patch([region_start region_end region_end region_start], ...
              [0 0 y_max y_max], ...
              [0.9 0.9 0.9], 'EdgeColor', 'none', 'FaceAlpha', 0.3);
        j = j + 1;
    end
end

function [final_memory, peak_juvenile, final_mature] = run_sensitivity_simulation_R4(...
    k_a2j, k_genesis, k_mat, k_j2a, k_prune, K_max, M_max, ...
    t, n_steps, dt, exp_start, n_exp, exp_int, exp_dur, N_base, ...
    p_adult, p_juv, p_sil, p_mat, alpha_mem, beta_mem)
    
    N_a = N_base; N_j = 0; N_s = 0; N_m = 0;
    memory = 0;
    peak_juv = 0;
    
    for i = 1:n_steps
        curr_t = t(i);
        
        % Determine D(t)
        D_t = 0;
        for e = 1:n_exp
            e_start = exp_start + (e-1) * exp_int;
            e_end = e_start + exp_dur;
            if curr_t >= e_start && curr_t <= e_end
                D_t = 1;
                break;
            end
        end
        one_minus_D = 1 - D_t;
        
        % Process 1: Rejuvenation
        d_aj = k_a2j * N_a * D_t * dt;
        d_ja = k_j2a * N_j * one_minus_D * dt;
        N_a = max(0, N_a - d_aj + d_ja);
        N_j = max(0, N_j + d_aj - d_ja);
        
        peak_juv = max(peak_juv, N_j);
        
        % Process 2: Silent synapses (phase-gated)
        genesis = k_genesis * D_t * (1 - N_s/K_max) * dt;
        genesis = max(0, genesis);
        d_mat = one_minus_D * k_mat * N_s * dt;
        d_prune = one_minus_D * k_prune * N_s * dt;
        N_s = max(0, N_s + genesis - d_mat - d_prune);
        N_m = N_m + d_mat;
        
        % Plasticity
        plasticity = (N_a*p_adult + N_j*p_juv + N_s*p_sil + N_m*p_mat) / N_base;
        
        % Memory with saturation
        sat_factor = max(0, 1 - memory / M_max);
        if D_t == 1
            memory = memory + alpha_mem * plasticity * sat_factor * dt;
        else
            mat_flux = k_mat * N_s;
            memory = memory + beta_mem * (mat_flux / N_base) * sat_factor * dt;
        end
    end
    
    final_memory = memory;
    peak_juvenile = peak_juv;
    final_mature = N_m;
end
