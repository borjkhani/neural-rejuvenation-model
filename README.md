# Neural Rejuvenation Model: Population-Level Dynamics in Addiction

[![MATLAB](https://img.shields.io/badge/MATLAB-R2023a+-blue.svg)](https://www.mathworks.com/products/matlab.html)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A computational framework for understanding population-level neural rejuvenation dynamics in addiction, implementing Nestler's neural rejuvenation hypothesis through synaptic population modeling.

## Overview

This repository contains MATLAB code implementing a mathematical model that tracks synaptic population dynamics during simulated drug exposure and withdrawal. The model demonstrates how coordinated population-level transitions could account for key experimental observations in addiction neuroscience, including:

- **Adult-to-juvenile synaptic conversion** (GluN2A → GluN2B NMDA receptor switching)
- **Silent synapse generation** during drug exposure
- **Silent synapse maturation** through CP-AMPA receptor recruitment during withdrawal
- **Incubation of craving** phenomenon

## Recent Revisions (R4)

The R4 version addresses key biological realism and mathematical consistency concerns:

| Revision | Description |
|----------|-------------|
| **Phase-gated maturation/pruning** | Maturation and pruning occur only during withdrawal, gated by (1-D(t)) |
| **Phase-gated genesis** | Silent synapse generation occurs only during drug exposure, gated by D(t) |
| **Carrying capacity** | K_max parameter prevents unbounded silent synapse growth |
| **Memory saturation** | M_max parameter prevents unbounded memory growth |
| **Flux-driven incubation** | Memory growth during withdrawal depends on maturation flux rate, not accumulated mature synapse count |
| **Explicit D(t) definition** | Clear binary pulse train for intermittent drug exposure protocol |

## Scientific Background

The neural rejuvenation hypothesis proposes that drugs of abuse reopen developmental plasticity mechanisms within the brain's reward circuitry. This framework, developed by Dong & Nestler (2014), suggests that:

1. Drug exposure shifts NMDA receptor composition from adult-like (GluN2A-dominant) to juvenile-like (GluN2B-enriched) states
2. Silent synapses containing only NMDA receptors are generated during drug exposure
3. During withdrawal, silent synapses mature by recruiting calcium-permeable AMPA receptors
4. This maturation process drives progressive craving intensification (incubation)

Our computational model extends this framework to population-level dynamics, demonstrating how coordinated synaptic transformations might collectively contribute to addiction pathophysiology.

## Model Architecture

### Synaptic Populations

The model tracks four discrete synaptic populations:

| Population | Description | NMDA Composition | AMPA Status | Plasticity Weight |
|------------|-------------|------------------|-------------|-------------------|
| Adult | Mature synapses | GluN2A-dominant | Functional | 1.0 |
| Juvenile | Rejuvenated synapses | GluN2B-enriched | Functional | 2.5 |
| Silent | Newly generated | GluN2B-enriched | Absent | 0.5 |
| Matured | Matured silent | GluN2B-enriched | CP-AMPAR | 3.0 |

### Phase-Gated State Transitions

**During Drug Exposure (D(t) = 1):**
```
Adult → Juvenile    (rate: k_adult_to_juvenile)
Genesis → Silent    (rate: k_silent_genesis, with carrying capacity)
```

**During Withdrawal (D(t) = 0):**
```
Juvenile → Adult    (rate: k_juvenile_to_adult)
Silent → Matured    (rate: k_silent_maturation)
Silent → Eliminated (rate: k_silent_pruning)
```

### Mathematical Formulation

**Drug Exposure Function (Equation 2):**
```
D(t) = 1 if t ∈ [t_start + (i-1)·ΔT, t_start + (i-1)·ΔT + τ] for any i ∈ {1,...,5}
D(t) = 0 otherwise
```

**Process 1: Rejuvenation Dynamics (Equations 3-4):**
```
dN_adult/dt = -k_a→j · N_adult · D(t) + k_j→a · N_juvenile · (1-D(t))
dN_juvenile/dt = k_a→j · N_adult · D(t) - k_j→a · N_juvenile · (1-D(t))
```

**Process 2: Silent Synapse Dynamics (Equations 5-6):**
```
dN_silent/dt = k_genesis · D(t) · (1 - N_silent/K_max) 
              - k_mat · N_silent · (1-D(t)) 
              - k_prune · N_silent · (1-D(t))

dN_mature/dt = k_mat · N_silent · (1-D(t))
```

**Memory Formation with Saturation (Equation 8):**
```
During exposure (D(t)=1):
  dM/dt = α · Π(t) · (1 - M/M_max)

During withdrawal (D(t)=0):
  dM/dt = β · (k_mat · N_silent / N_0) · (1 - M/M_max)
```

### Model Parameters

| Parameter | Symbol | Value | Biological Interpretation |
|-----------|--------|-------|---------------------------|
| Adult→Juvenile rate | k_a→j | 0.08 time⁻¹ | Receptor switching rate |
| Juvenile→Adult rate | k_j→a | 0.02 time⁻¹ | Recovery rate (slower than induction) |
| Silent genesis rate | k_genesis | 15 syn/time | De novo synapse generation |
| Silent maturation rate | k_mat | 0.04 time⁻¹ | CP-AMPAR recruitment |
| Silent pruning rate | k_prune | 0.01 time⁻¹ | ~50-70% elimination |
| Carrying capacity | K_max | 500 | Maximum silent synapse capacity |
| Memory saturation | M_max | 30 | Maximum memory strength |
| Exposure memory coefficient | α | 0.5 | Memory formation during exposure |
| Incubation coefficient | β | 0.1 | Flux-driven incubation rate |

### Time Scaling

One time unit corresponds to approximately 2 hours of biological time:
- dt = 0.1 (≈ 12 minutes)
- t_total = 500 (≈ 42 days)

### Simulation Protocol

| Parameter | Value | Description |
|-----------|-------|-------------|
| `dt` | 0.1 | Time step (≈ 12 minutes biological) |
| `t_total` | 500 | Total simulation time (≈ 42 days) |
| `exposure_start` | 100 | When drug exposure begins (Day 8) |
| `n_exposures` | 5 | Number of exposure sessions |
| `exposure_interval` | 30 | Time between exposures (≈ 2.5 days) |
| `exposure_duration` | 5 | Duration of each exposure (≈ 10 hours) |

### Functional Indices

**Total Plasticity Capacity (Equation 7):**
```matlab
Π(t) = (N_adult × 1.0 + N_juvenile × 2.5 + N_silent × 0.5 + N_mature × 3.0) / N_0
```

**NMDA Receptor Composition (Equation 9):**
```matlab
GluN2B_total = N_juvenile + 0.8×N_silent + 0.3×N_mature
R_2B(t) = GluN2B_total / N_total
R_2A(t) = 1 - R_2B(t)
```

## Installation

### Requirements

- MATLAB R2023a or later
- No additional toolboxes required

### Setup

```bash
git clone https://github.com/borjkhani/neural-rejuvenation-model.git
cd neural-rejuvenation-model
```

## Usage

### Running the Simulation

Simply run the main script in MATLAB:

```matlab
% Run the complete simulation with publication-quality figures
run('Neural_Rejuvenation_Model_R4.m')
```

The script will:
1. Run the main cocaine simulation with phase-gated equations
2. Perform parameter sensitivity analysis
3. Run natural reward comparison simulation
4. Generate Figure 1: Core Neural Rejuvenation Dynamics (6 panels)
5. Generate Figure 2: Silent Synapse Dynamics (6 panels)
6. Generate Figure 3: Model Validation (4 panels)
7. Save figures in multiple formats (PNG, PDF, FIG)
8. Save results to `Neural_Rejuvenation_Results_R4.mat`
9. Print summary statistics to console

### Modifying Parameters

Edit the parameters section at the beginning of the script:

```matlab
%% Time Scaling (1 time unit = 2 hours)
dt = 0.1;                    % Time step (= 12 minutes biological time)
t_total = 500;               % Total simulation (≈ 42 days)

%% Drug Exposure Protocol
exposure_start = 100;        % t_start = 100 (Day 8)
n_exposures = 5;             % 5 exposure sessions
exposure_duration = 5;       % τ = 5 time units (10 hours each)
exposure_interval = 30;      % ΔT = 30 time units (2.5 days between sessions)

%% Rate Constants
k_adult_to_juvenile = 0.08;  % Rate of adult→juvenile conversion
k_juvenile_to_adult = 0.02;  % Rate of juvenile→adult recovery
k_silent_genesis = 15;       % Silent synapse generation (syn/time)
k_silent_maturation = 0.04;  % Rate of silent→mature conversion
k_silent_pruning = 0.01;     % Rate of silent synapse elimination

%% Capacity Parameters
K_max = 500;                 % Maximum silent synapse capacity
M_max = 30;                  % Memory saturation level

%% Memory Parameters
alpha_mem = 0.5;             % Exposure-phase memory formation rate
beta_mem = 0.1;              % Flux-driven incubation coefficient

%% Plasticity Weights
plasticity_adult = 1.0;      % Baseline (GluN2A-dominant)
plasticity_juvenile = 2.5;   % Enhanced Ca²⁺ dynamics (GluN2B)
plasticity_silent = 0.5;     % No functional AMPAR
plasticity_mature = 3.0;     % CP-AMPAR high conductance
```

## Output Files

### Figures

The simulation generates publication-quality figures in multiple formats:

| File | Description |
|------|-------------|
| `Figure1_Neural_Rejuvenation_Dynamics_REVISED.*` | Core dynamics (6-panel figure) |
| `Figure2_Silent_Synapse_Dynamics_FINAL.*` | Silent synapse analysis (6-panel figure) |
| `Figure3_Model_Validation.*` | Sensitivity analysis and natural reward comparison (4-panel figure) |

**Figure 1 Panels:**
- A: Drug Exposure & Cue Responses
- B: Synapse Population Dynamics
- C: NMDA Receptor Rejuvenation
- D: Memory Formation & Incubation (with saturation)
- E: Enhanced Plasticity Window
- F: Synapse Type Plasticity

**Figure 2 Panels:**
- A: Silent Synapse Dynamics (Phase-Gated)
- B: Craving Incubation
- C: Experimental Predictions
- D: Long-term Potentiation Capacity
- E: Rate of Memory Formation (Flux-Driven)
- F: Dynamic Population Size

**Figure 3 Panels:**
- A: Parameter Sensitivity Analysis
- B: Plasticity Across Phases
- C: Cocaine vs Natural Reward: Memory
- D: Cocaine vs Natural Reward: Population

### Data

Results are saved to `Neural_Rejuvenation_Results_R4.mat`:

```matlab
% Variables saved:
t                    % Time vector
dt                   % Time step
populations          % [N_adult, N_juvenile, N_silent, N_mature] over time
N_total_array        % Total synapse count over time
total_plasticity     % Plasticity capacity over time
memory_strength      % Memory strength over time
cue_response         % Cue-induced responses over time
drug_present         % Drug exposure indicator D(t) (0 or 1)
gluN2A_ratio         % GluN2A receptor ratio over time
gluN2B_ratio         % GluN2B receptor ratio over time
sensitivity_results  % Parameter sensitivity analysis results
param_variations     % Parameter multipliers tested
populations_natural  % Natural reward population dynamics
N_total_natural      % Natural reward total synapse count
memory_natural       % Natural reward memory strength
N_baseline           % Baseline synapse count (1000)
K_max                % Carrying capacity
M_max                % Memory saturation level
exposure_start       % Start time of exposures
withdrawal_start     % Start time of withdrawal
```

### Console Output

The script prints comprehensive summary statistics:

```
=== Neural Rejuvenation Model - REVISED R4 ===
Key fixes: Phase-gating, carrying capacity, memory saturation

Running main cocaine simulation with phase-gated equations...
Process 1 conservation check: max error = X.XXe-XX (should be ~0)
Main simulation complete.
  Peak total synapses: XXXX (XX.X% increase)
  Final memory strength: XX.XX (saturation at 30)

Running parameter sensitivity analysis...
Parameter sensitivity analysis complete.

Running natural reward comparison simulation...
Natural reward simulation complete.
  Final cocaine memory: XX.XX
  Final natural reward memory: X.XX
  Ratio (cocaine/natural): XX.Xx

=== KEY RESULTS SUMMARY ===
Metric                              Value
----------------------------------- ---------------
Baseline synapses:                  1000
Peak total synapses (cocaine):      XXXX (XX.X%)
Final memory (cocaine) / M_max:     XX.XX / 30
Final memory (natural):             X.XX
Cocaine/Natural ratio:              XX.Xx
```

## File Structure

```
neural-rejuvenation-model/
├── README.md                                    # This file
├── LICENSE                                      # MIT License
├── Neural_Rejuvenation_Model_R4.m               # Main simulation script (revised)
├── figures/                                     # Generated figures (after running)
│   ├── Figure1_Neural_Rejuvenation_Dynamics_REVISED.*
│   ├── Figure2_Silent_Synapse_Dynamics_FINAL.*
│   └── Figure3_Model_Validation.*
└── results/
    └── Neural_Rejuvenation_Results_R4.mat
```

## Key Results

### Simulation Outputs

The model produces the following characteristic outputs:

1. **Synaptic Population Dynamics**
   - Adult synapses decrease during exposure, partially recover during withdrawal
   - Juvenile synapses peak during active exposure periods
   - Silent synapses accumulate during exposure (phase-gated, with carrying capacity)
   - Matured synapses emerge only during withdrawal (phase-gated)

2. **NMDA Receptor Composition**
   - GluN2A ratio decreases during exposure
   - GluN2B ratio increases (including contributions from silent and mature synapses)
   - Partial recovery toward adult-like ratios during withdrawal

3. **Functional Indices**
   - Memory strength shows continuous enhancement with saturation
   - Plasticity capacity peaks during exposure, remains elevated during withdrawal
   - Flux-driven incubation during withdrawal

4. **Natural Reward Comparison**
   - Cocaine produces substantially stronger memory than natural rewards
   - No silent synapse generation for natural rewards
   - Reduced rejuvenation rate (10% of cocaine effect)

### Conservation Laws

The model maintains two key conservation properties:

1. **Process 1 (Rejuvenation)**: N_adult + N_juvenile = N_baseline (constant)
2. **Process 2 (Silent Synapses)**: Dynamic population with bounded growth (K_max)

### Therapeutic Windows

The model identifies four distinct intervention phases:

| Phase | Time (a.u.) | Dominant Process | Potential Target |
|-------|-------------|------------------|------------------|
| Baseline | 0-100 | Normal function | Prevention |
| Exposure | 100-225 | Rejuvenation + Genesis | GluN2B antagonists, Genesis blockers |
| Early Withdrawal | 225-350 | Silent synapse maturation | Maturation blockers |
| Late Withdrawal | 350-500 | Incubation | CP-AMPAR antagonists |

## Model Predictions

The computational framework generates testable predictions:

1. **Phase-gated dynamics**: Maturation and pruning should be suppressed during active drug exposure
2. **Carrying capacity**: Silent synapse population should plateau at a maximum level
3. **Flux-driven incubation**: Memory strengthening correlates with maturation flux rate, not accumulated mature synapse count
4. **Memory saturation**: Craving intensification should show saturation behavior over extended withdrawal
5. **Cocaine vs natural rewards**: Drugs of abuse produce stronger, more persistent memory due to silent synapse generation

## Limitations

- Deterministic dynamics (no stochastic variability)
- Abstract time units (approximately calibrated to 2 hours per unit)
- Simplified molecular mechanisms (first-order kinetics)
- No explicit transcriptional regulation
- No spatial organization or circuit-level interactions
- Parameters chosen for demonstration rather than fitted to experimental data
- Two-process model (rejuvenation and silent synapse dynamics) treated semi-independently

## Citation

If you use this code in your research, please cite:

```bibtex
@article{Borjkhani2025neural,
  title={Population-Level Neural Rejuvenation Dynamics in Addiction: 
         A Computational Framework for Understanding Developmental 
         Plasticity Reactivation},
  author={Borjkhani, Mehdi and Borjkhani, Hadi and Sharif, Morteza A.},
  journal={Frontiers in Computational Neuroscience},
  year={2025},
  doi={10.xxxx/xxxxx}
}
```

## Key References

- Dong Y, Nestler EJ. (2014). The neural rejuvenation hypothesis of cocaine addiction. *Trends Pharmacol Sci*, 35(8):374-383.

- Huang YH et al. (2009). In vivo cocaine experience generates silent synapses. *Neuron*, 63(1):40-47.

- Lee BR et al. (2013). Maturation of silent synapses in amygdala-accumbens projection contributes to incubation of cocaine craving. *Nat Neurosci*, 16(11):1644-1651.

- Gray JA et al. (2011). Distinct modes of AMPA receptor suppression at developing synapses by GluN2A and GluN2B. *Neuron*, 71(6):1085-1101.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contact

**Mehdi Borjkhani**  
International Centre for Translational Eye Research (ICTER)  
Institute of Physical Chemistry, Polish Academy of Sciences  
Warsaw, Poland

Email: mborjkhani@ichf.edu.pl

## Acknowledgments

We thank the International Centre for Translational Eye Research (ICTER) for computational resources and support.

---

*This computational framework is intended for research purposes and provides theoretical insights into neural rejuvenation mechanisms. The model generates testable hypotheses that should be validated through targeted experimental studies.*



# OLD
# neural-rejuvenation-model

# Neural Rejuvenation Model: Population-Level Dynamics in Addiction

[![MATLAB](https://img.shields.io/badge/MATLAB-R2023a+-blue.svg)](https://www.mathworks.com/products/matlab.html)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A computational framework for understanding population-level neural rejuvenation dynamics in addiction, implementing Nestler's neural rejuvenation hypothesis through synaptic population modeling.

## Overview

This repository contains MATLAB code implementing a mathematical model that tracks synaptic population dynamics during simulated drug exposure and withdrawal. The model demonstrates how coordinated population-level transitions could account for key experimental observations in addiction neuroscience, including:

- **Adult-to-juvenile synaptic conversion** (GluN2A → GluN2B NMDA receptor switching)
- **Silent synapse generation** during drug exposure
- **Silent synapse maturation** through CP-AMPA receptor recruitment during withdrawal
- **Incubation of craving** phenomenon

## Scientific Background

The neural rejuvenation hypothesis proposes that drugs of abuse reopen developmental plasticity mechanisms within the brain's reward circuitry. This framework, developed by Dong & Nestler (2014), suggests that:

1. Drug exposure shifts NMDA receptor composition from adult-like (GluN2A-dominant) to juvenile-like (GluN2B-enriched) states
2. Silent synapses containing only NMDA receptors are generated during drug exposure
3. During withdrawal, silent synapses mature by recruiting calcium-permeable AMPA receptors
4. This maturation process drives progressive craving intensification (incubation)

Our computational model extends this framework to population-level dynamics, demonstrating how coordinated synaptic transformations might collectively contribute to addiction pathophysiology.

## Model Architecture

### Synaptic Populations

The model tracks four discrete synaptic populations within a fixed population of 1000 synapses:

| Population | Description | NMDA Composition | AMPA Status | Plasticity Weight |
|------------|-------------|------------------|-------------|-------------------|
| Adult | Mature synapses | GluN2A-dominant | Functional | 1.0 |
| Juvenile | Rejuvenated synapses | GluN2B-enriched | Functional | 2.5 |
| Silent | Newly generated | GluN2B-enriched | Absent | 0.5 |
| Matured | Matured silent | GluN2B-enriched | CP-AMPAR | 3.0 |

### State Transitions

**During Drug Exposure (Rejuvenation Phase):**
```
Adult → Juvenile    (rate: k_adult_to_juvenile)
Juvenile → Silent   (rate: k_silent_generation)
```

**During Withdrawal (Maturation Phase):**
```
Juvenile → Adult    (rate: k_juvenile_to_adult)
Silent → Matured    (rate: k_silent_maturation)
Silent → Eliminated (rate: k_silent_pruning)
```

### Model Parameters

| Parameter | Value | Description |
|-----------|-------|-------------|
| `k_adult_to_juvenile` | 0.08 | Adult to juvenile conversion rate |
| `k_silent_generation` | 0.03 | Silent synapse generation rate |
| `k_juvenile_to_adult` | 0.02 | Juvenile to adult recovery rate |
| `k_silent_maturation` | 0.04 | Silent synapse maturation rate |
| `k_silent_pruning` | 0.01 | Silent synapse elimination rate |

### Simulation Protocol

| Parameter | Value | Description |
|-----------|-------|-------------|
| `dt` | 0.1 | Time step (arbitrary units) |
| `t_total` | 500 | Total simulation time |
| `exposure_start` | 100 | When drug exposure begins |
| `n_exposures` | 5 | Number of exposure sessions |
| `exposure_interval` | 30 | Time between exposures |
| `exposure_duration` | 5 | Duration of each exposure |

### Functional Indices

**Total Plasticity Capacity:**
```matlab
total_plasticity = (N_adult × 1.0 + N_juvenile × 2.5 + N_silent × 0.5 + N_mature_silent × 3.0) / N_total
```

**Memory Formation:**
```matlab
% During drug exposure:
memory_increment = 0.5 × total_plasticity

% During withdrawal (incubation):
incubation_factor = N_mature_silent / N_total
memory_increment = 0.1 × incubation_factor
```

**NMDA Receptor Composition:**
```matlab
gluN2A_ratio = N_adult / (N_adult + N_juvenile + 0.001)
gluN2B_ratio = N_juvenile / (N_adult + N_juvenile + 0.001)
```

**Cue-Induced Response:**
```matlab
cue_response = memory_strength × total_plasticity × 0.8  % During cue presentation
```

## Installation

### Requirements

- MATLAB R2023a or later
- No additional toolboxes required

### Setup

```bash
git clone https://github.com/borjkhani/neural-rejuvenation-model.git
cd neural-rejuvenation-model
```

## Usage

### Running the Simulation

Simply run the main script in MATLAB:

```matlab
% Run the complete simulation with publication-quality figures
run('neural_rejuvenation_model.m')
```

The script will:
1. Run the complete simulation (500 time units)
2. Generate Figure 1: Core Rejuvenation Dynamics (6 panels)
3. Generate Figure 2: Silent Synapse Dynamics (6 panels)
4. Save figures in multiple formats (PNG, TIFF, PDF, EPS, FIG)
5. Save results to `rejuvenation_publication_results.mat`
6. Print summary statistics to console

### Modifying Parameters

Edit the parameters section at the beginning of the script:

```matlab
%% Simulation Parameters
dt = 0.1;                    % Time step (arbitrary units)
t_total = 500;               % Total simulation time

% Drug exposure protocol
exposure_start = 100;        % When drug exposure begins
exposure_duration = 50;      % Duration of repeated exposures
n_exposures = 5;             % Number of exposure sessions
exposure_interval = 30;      % Time between exposures

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
```

## Output Files

### Figures

The simulation generates publication-quality figures in multiple formats:

| File | Description |
|------|-------------|
| `Figure1_Neural_Rejuvenation_Dynamics.png/tiff/pdf/eps/fig` | Core dynamics (6-panel figure) |
| `Figure2_Silent_Synapse_Dynamics.png/tiff/pdf/eps/fig` | Silent synapse analysis (6-panel figure) |

**Figure 1 Panels:**
- A: Drug Exposure & Cue Responses
- B: Synapse Population Dynamics
- C: NMDA Receptor Rejuvenation
- D: Memory Formation & Incubation
- E: Enhanced Plasticity Window
- F: Rejuvenation Process (schematic)

**Figure 2 Panels:**
- A: Silent Synapse Dynamics
- B: Craving Incubation
- C: Experimental Predictions
- D: Long-term Potentiation Capacity
- E: Rate of Memory Formation
- F: Rejuvenation Phases

### Data

Results are saved to `rejuvenation_publication_results.mat`:

```matlab
% Variables saved:
t                 % Time vector
populations       % [N_adult, N_juvenile, N_silent, N_mature_silent] over time
total_plasticity  % Plasticity capacity over time
memory_strength   % Memory strength over time
cue_response      % Cue-induced responses over time
drug_present      % Drug exposure indicator (0 or 1)
gluN2A_ratio      % GluN2A receptor ratio over time
gluN2B_ratio      % GluN2B receptor ratio over time
```

### Console Output

The script prints summary statistics:

```
=== NEURAL REJUVENATION SIMULATION RESULTS ===
Initial adult synapses: 1000
Final adult synapses: XXX (XX.X%)
Final juvenile synapses: XXX (XX.X%)
Final silent synapses: XXX (XX.X%)
Final mature silent synapses: XXX (XX.X%)

Peak plasticity during exposure: X.XX
Final memory strength: XX.XX
Peak cue response: XX.XX
Incubation effect: XX.X% increase in memory strength
```

## File Structure

```
neural-rejuvenation-model/
├── README.md                              # This file
├── LICENSE                                # MIT License
├── neural_rejuvenation_model.m            # Main simulation script
├── figures/                               # Generated figures (after running)
│   ├── Figure1_Neural_Rejuvenation_Dynamics.*
│   └── Figure2_Silent_Synapse_Dynamics.*
└── results/
    └── rejuvenation_publication_results.mat
```

## Key Results

### Simulation Outputs

The model produces the following characteristic outputs:

1. **Synaptic Population Dynamics**
   - Adult synapses decrease during exposure, partially recover during withdrawal
   - Juvenile synapses peak during active exposure periods
   - Silent synapses accumulate during exposure
   - Matured synapses emerge and stabilize during withdrawal

2. **NMDA Receptor Composition**
   - GluN2A ratio decreases from ~80% to ~20% during exposure
   - GluN2B ratio increases correspondingly
   - Partial recovery toward adult-like ratios during withdrawal

3. **Functional Indices**
   - Memory strength shows continuous enhancement
   - Plasticity capacity peaks during exposure, remains elevated during withdrawal
   - Cue responses demonstrate progressive incubation

### Therapeutic Windows

The model identifies four distinct intervention phases:

| Phase | Time (a.u.) | Dominant Process | Potential Target |
|-------|-------------|------------------|------------------|
| Baseline | 0-100 | Normal function | Prevention |
| Exposure | 100-250 | Rejuvenation | GluN2B antagonists |
| Early Withdrawal | 250-350 | Silent synapse maturation | Maturation blockers |
| Late Withdrawal | 350-500 | Incubation | CP-AMPAR antagonists |

## Model Predictions

The computational framework generates testable predictions:

1. **Coordinated population transitions**: Synchronized conversion across large synaptic populations
2. **Biphasic silent synapse dynamics**: Generation during exposure, competitive maturation during withdrawal
3. **Persistent plasticity elevation**: Enhanced capacity throughout withdrawal
4. **Progressive incubation**: Memory strengthening driven by silent synapse maturation

## Limitations

- Deterministic dynamics (no stochastic variability)
- Abstract time units (not calibrated to specific biological durations)
- Simplified molecular mechanisms (first-order kinetics)
- No explicit transcriptional regulation
- No spatial organization or circuit-level interactions
- Parameters chosen for demonstration rather than fitted to experimental data

## Citation

If you use this code in your research, please cite:

```bibtex
@article{Borjkhani2025neural,
  title={Population-Level Neural Rejuvenation Dynamics in Addiction: 
         A Computational Framework for Understanding Developmental 
         Plasticity Reactivation},
  author={Borjkhani, Mehdi and Borjkhani, Hadi and Sharif, Morteza A.},
  journal={[Journal Name]},
  year={2025},
  doi={10.xxxx/xxxxx}
}
```

## Key References

- Dong Y, Nestler EJ. (2014). The neural rejuvenation hypothesis of cocaine addiction. *Trends Pharmacol Sci*, 35(8):374-383.

- Huang YH et al. (2009). In vivo cocaine experience generates silent synapses. *Neuron*, 63(1):40-47.

- Lee BR et al. (2013). Maturation of silent synapses in amygdala-accumbens projection contributes to incubation of cocaine craving. *Nat Neurosci*, 16(11):1644-1651.

- Gray JA et al. (2011). Distinct modes of AMPA receptor suppression at developing synapses by GluN2A and GluN2B. *Neuron*, 71(6):1085-1101.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contact

**Mehdi Borjkhani**  
International Centre for Translational Eye Research (ICTER)  
Institute of Physical Chemistry, Polish Academy of Sciences  
Warsaw, Poland

Email: mborjkhani@ichf.edu.pl

## Acknowledgments

We thank the International Centre for Translational Eye Research (ICTER) for computational resources and support.

---

*This computational framework is intended for research purposes and provides theoretical insights into neural rejuvenation mechanisms. The model generates testable hypotheses that should be validated through targeted experimental studies.*

