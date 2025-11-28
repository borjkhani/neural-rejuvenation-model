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

