# DFF Characterization Automation

Automated DFF characterization framework for Cadence Virtuoso ADE Explorer/Assembler using OCEAN/SKILL and Python.

This project automates DFF setup/hold timing characterization across PVT and Monte Carlo conditions, extracts additional scalar metrics from ADE, exports raw characterization data to CSV, and generates summarized Excel reports.

To reduce post-processing overhead, the framework uses a single-pass Maestro RDB caching architecture instead of repeatedly traversing the result database for every condition and metric.

---

## Overview

DFF characterization requires repeated simulation and result extraction across multiple process, voltage, temperature, and Monte Carlo conditions.

The automated flow implemented in this project is:

```text
Cadence Virtuoso ADE / Maestro
            |
            v
      OCEAN Automation
            |
            v
       Spectre Simulation
            |
            v
       Maestro RDB
            |
            v
   Single-Pass RDB Scan
            |
            v
     In-Memory Cache
            |
            v
        CSV Export
            |
            v
 Python Post-Processing
            |
            v
 Excel Characterization Report
```

The framework supports:

- Setup-time characterization
- Hold-time characterization
- Additional scalar metric extraction
- PVT characterization
- Monte Carlo characterization
- Automatic CSV export
- Automatic Excel report generation
- Post-processing runtime benchmarking
- Legacy repeated-scan vs. single-pass RDB processing comparison

---

## Project Structure

```text
dff-characterization-automation/
├── benchmark/
│   ├── benchmark_monte_postprocess.ocn
│   └── benchmark_pvt_postprocess.ocn
│
├── config/
│   ├── config.il
│   └── config.example.il
│
├── data/
│   └── raw/
│
├── logs/
│
├── ocean/
│   ├── dff_monte_characterization.ocn
│   └── dff_pvt_characterization.ocn
│
├── python/
│   ├── monte_summary.py
│   └── pvt_summary.py
│
├── results/
│
├── .gitignore
├── setup.csh
└── README.md
```

### Main Files

`ocean/dff_pvt_characterization.ocn`

- Executes PVT characterization
- Reads the Maestro result database
- Builds the PVT result cache
- Extracts Setup, Hold, and ETC results
- Exports raw CSV files
- Executes Python post-processing

`ocean/dff_monte_characterization.ocn`

- Executes Monte Carlo characterization
- Reads the Maestro result database
- Builds the Monte Carlo result cache
- Extracts Setup, Hold, and ETC results
- Exports raw CSV files
- Executes Python post-processing

`python/pvt_summary.py`

- Reads PVT CSV files
- Calculates summary statistics
- Generates `PVT_RESULT.xlsx`

`python/monte_summary.py`

- Reads Monte Carlo CSV files
- Calculates statistical results
- Generates `MONTE_RESULT.xlsx`

`benchmark/benchmark_pvt_postprocess.ocn`

- Compares legacy repeated RDB traversal with the optimized single-pass architecture for PVT results

`benchmark/benchmark_monte_postprocess.ocn`

- Compares legacy repeated RDB traversal with the optimized single-pass architecture for Monte Carlo results

`config/config.il`

- Contains local Cadence project, DUT, PDK, and characterization settings
- User-specific file
- Excluded from Git

`config/config.example.il`

- Public configuration template
- Contains example characterization settings without user-specific paths

---

## Characterization Methodology

### Setup Time

Setup-time characterization is performed by sweeping the setup-time variable while keeping the hold-time condition fixed.

For each sweep point, the CLK-to-Q delay is evaluated.

The nominal CLK-to-Q delay is obtained at the configured reference point:

```text
Reference Setup = 1 ns
```

The timing boundary is defined using a CLK-to-Q degradation criterion:

```text
Threshold tCQ
= Nominal tCQ × 1.005
```

The characterization algorithm:

```text
Setup Sweep
    |
    v
Extract CLK-to-Q at Each Sweep Point
    |
    v
Obtain Nominal CLK-to-Q at 1 ns
    |
    v
Calculate 1.005 × Nominal CLK-to-Q
    |
    v
Find Falling Threshold Crossing
    |
    v
Linear Interpolation
    |
    v
Setup Time
```

The threshold crossing is linearly interpolated between the two surrounding sweep points.

The final Setup result is reported in:

```text
ps
```

---

## Hold Time

Hold-time characterization uses the same timing degradation method.

The hold-time variable is swept while the setup-time condition is fixed.

The algorithm:

```text
Hold Sweep
    |
    v
Extract CLK-to-Q at Each Sweep Point
    |
    v
Obtain Nominal CLK-to-Q at Reference Point
    |
    v
Calculate 1.005 × Nominal CLK-to-Q
    |
    v
Find Falling Threshold Crossing
    |
    v
Linear Interpolation
    |
    v
Hold Time
```

The final Hold result is also reported in:

```text
ps
```

---

## Additional Scalar Metrics

Additional scalar measurements are collected through the ETC test.

Typical ETC outputs include:

```text
POWER_CONSUMPTION
DELAY_CLK_TO_Q
Q_RISING_TIME
```

The ETC output list is discovered dynamically from the ADE result database.

This allows additional scalar ADE outputs to be included without modifying the main post-processing architecture.

ETC values are stored as raw ADE evaluated scalar values.

If a different output unit is required, scaling should be applied directly in the ADE/OCEAN output expression.

---

## PVT Characterization

The reference PVT configuration uses:

```text
Process:
TT
FF
SS
SF
FS

Temperature:
-40 °C
27 °C
150 °C

VDD:
4.5 V
5.0 V
5.5 V
```

The complete PVT characterization therefore contains:

```text
5 Process Corners
×
3 Temperatures
×
3 Supply Voltages

= 45 PVT Conditions
```

For each PVT condition, the framework extracts:

- Setup time
- Hold time
- ETC scalar metrics

---

## PVT Cache Architecture

The original implementation repeatedly traversed the Maestro result database using:

```lisp
rdb->points()
```

Separate RDB scans were previously performed for:

- Setup conditions
- Hold conditions
- ETC conditions
- Process discovery
- Temperature discovery
- VDD discovery
- ETC metric discovery

As the characterization space increased, repeated RDB traversal became the dominant post-processing overhead.

The optimized architecture performs only one complete RDB traversal:

```text
               Maestro RDB
                    |
                    v
             Single Traversal
                    |
        +-----------+-----------+
        |           |           |
        v           v           v
   Setup Cache  Hold Cache   ETC Cache
        |           |           |
        +-----------+-----------+
                    |
                    v
         Cached Result Processing
                    |
                    v
                CSV Export
```

The PVT cache key is:

```text
Process | Temperature | VDD
```

After the cache has been built, Setup, Hold, and ETC calculations are performed using the cached data without repeatedly scanning the Maestro RDB.

---

## Monte Carlo Characterization

Monte Carlo characterization supports configurable:

- Monte Carlo sample count
- Random seed
- Temperature conditions
- Supply-voltage conditions
- Monte Carlo model section

Each Monte Carlo sample is identified from:

```text
monteCarlo::param::sequence
```

The Monte Carlo cache key is:

```text
Sequence | Temperature | VDD
```

The one-pass architecture is:

```text
              Monte Carlo RDB
                     |
                     v
              Single Traversal
                     |
        +------------+------------+
        |            |            |
        v            v            v
   Setup Cache   Hold Cache    ETC Cache
        |            |            |
        +------------+------------+
                     |
                     v
          Cached Result Processing
                     |
                     v
                 CSV Export
```

---

## Monte Carlo Statistics

The generated Monte Carlo report includes:

```text
N
Mean
1-Sigma
Minimum
Maximum
```

`1-Sigma` is calculated using the sample standard deviation:

```text
Python:
statistics.stdev()

Equivalent Excel Function:
STDEV.S

Denominator:
N - 1
```

Setup and Hold values are reported in `ps`.

ETC values remain in their raw ADE evaluated units.

### Statistical Scope

The current Monte Carlo implementation pools the configured Monte Carlo samples and configured voltage/temperature conditions for each metric.

Therefore, the resulting sigma may contain contributions from:

```text
Monte Carlo Variation
+
Deterministic VDD Shift
+
Deterministic Temperature Shift
```

It should therefore not be interpreted as a single-voltage, single-temperature mismatch-only sigma unless the characterization is configured accordingly.

---

## Python Post-Processing

Raw simulation data is exported from OCEAN as CSV files.

Python performs the statistical analysis and Excel report generation.

The raw CSV files are treated as read-only inputs.

The general flow is:

```text
Raw CSV
   |
   v
Python CSV Reader
   |
   v
In-Memory Statistics
   |
   v
Workbook Generation
   |
   v
Formatted Excel Report
```

The implementation uses:

```text
Python 3
openpyxl
statistics
```

---

## Output Files

### PVT Raw Data

```text
data/raw/SETUP_TIME_PVT.csv
data/raw/HOLD_TIME_PVT.csv
data/raw/ETC_PVT.csv
```

### Monte Carlo Raw Data

```text
data/raw/SETUP_TIME_MONTE.csv
data/raw/HOLD_TIME_MONTE.csv
data/raw/ETC_MONTE.csv
```

### Excel Reports

```text
results/PVT_RESULT.xlsx
results/MONTE_RESULT.xlsx
```

### Logs

```text
logs/pvt_ocean.log
logs/pvt_python.log

logs/monte_ocean.log
logs/monte_python.log

logs/pvt_postprocess_benchmark.log
logs/monte_postprocess_benchmark.log
```

---

## PVT Excel Report

The generated PVT workbook contains:

```text
SETUP
HOLD
ETC
```

Summary information includes:

```text
MIN
MIN CONDITION
MAX
MAX CONDITION
MEAN
```

This allows worst-case and best-case operating conditions to be identified directly from the generated report.

---

## Monte Carlo Excel Report

The generated Monte Carlo workbook summarizes each metric using:

```text
Metric
Unit
N
Mean
1-Sigma
Min
Max
```

The report is automatically generated after completion of the Monte Carlo OCEAN flow.

---

## Post-Processing Benchmark

The primary optimization target was repeated Maestro RDB traversal.

Two implementations were compared:

```text
Legacy
=
Repeated RDB traversal for individual conditions and metrics

Single-Pass
=
One complete RDB traversal followed by cached processing
```

Circuit simulation time, CSV I/O, Python processing, and Excel generation were excluded from the Legacy vs. Single-Pass post-processing comparison.

Both implementations process the same simulation result database.

Correctness was verified using:

- Result counts
- Result checksums

Each benchmark was repeated three times.

The median Legacy and Single-Pass runtimes were used as the representative benchmark values.

---

## PVT Benchmark Results

The PVT benchmark uses:

```text
45 PVT Conditions
```

Final median result:

| Method | Median Runtime |
|---|---:|
| Legacy | 1124 s |
| Single-Pass | 9 s |

Equivalent runtime:

```text
Legacy:
18 min 44 s

Single-Pass:
9 s
```

Performance improvement:

```text
Speedup:
124.89×

Runtime Reduction:
99.20%
```

Result validation:

```text
Legacy Setup Results      : 45
Single-Pass Setup Results : 45

Legacy Hold Results       : 45
Single-Pass Hold Results  : 45

Legacy ETC Results        : 135
Single-Pass ETC Results   : 135

Result Counts Match       : True
Checksum Match            : True
```

Replacing repeated per-condition RDB traversal with a single-pass caching architecture reduced the median PVT post-processing runtime from 1,124 seconds to 9 seconds while preserving identical result counts and checksums.

---

## Monte Carlo Benchmark Results

Final median result:

| Method | Median Runtime |
|---|---:|
| Legacy | 1686 s |
| Single-Pass | 16 s |

Equivalent runtime:

```text
Legacy:
28 min 06 s

Single-Pass:
16 s
```

Performance improvement:

```text
Speedup:
105.38×

Runtime Reduction:
99.05%
```

Result validation:

```text
Legacy Setup Results      : 40
Single-Pass Setup Results : 40

Legacy Hold Results       : 40
Single-Pass Hold Results  : 40

Legacy ETC Results        : 120
Single-Pass ETC Results   : 120

Result Counts Match       : True
Checksum Match            : True
```

The Legacy and Single-Pass implementations were evaluated using the same Maestro history for each benchmark run.

The optimized implementation preserved identical result counts and checksums while reducing the representative Monte Carlo post-processing runtime from 1,686 seconds to 16 seconds.

---

## Benchmark Summary

| Characterization | Legacy | Single-Pass | Speedup | Runtime Reduction |
|---|---:|---:|---:|---:|
| PVT | 1124 s | 9 s | 124.89× | 99.20% |
| Monte Carlo | 1686 s | 16 s | 105.38× | 99.05% |

The results demonstrate that repeated Maestro RDB traversal was the primary post-processing bottleneck.

Caching the required characterization data after a single RDB traversal reduced post-processing runtime by more than 99% for both characterization flows.

---

## Configuration

The repository contains:

```text
config/config.example.il
```

as a reusable configuration template.

Create the local configuration file with:

```bash
cp config/config.example.il config/config.il
```

Then modify `config/config.il` for the local Cadence and PDK environment.

Typical user-specific settings include:

```text
DFF_PROJECT_DIR
DFF_LIBRARY
DFF_CELL

DFF_TOP_MODEL_FILE
DFF_TOP_MODEL_SECTION

DFF_MODEL_FILE
DFF_PVT_MODEL_SECTIONS
DFF_PRE_SIMU_SECTION
DFF_MONTE_MODEL_SECTION
```

Characterization parameters are also configurable, including:

```text
Clock Frequency
Load Capacitance
Nominal VDD

Setup Sweep
Hold Sweep

Timing Reference
Timing Degradation Criterion

PVT Temperatures
PVT Supply Voltages
PVT Model Sections

Monte Carlo Temperatures
Monte Carlo Supply Voltages
Monte Carlo Sample Count
Monte Carlo Seed
```

The local `config/config.il` file is excluded from Git because it may contain user-specific simulation paths and proprietary PDK paths.

---

## Environment Setup

The project uses the environment variable:

```text
DFF_CHAR_ROOT
```

to identify the repository root.

From the project root:

```csh
source setup.csh
```

The environment variable can be checked from the Virtuoso CIW:

```lisp
getShellEnvVar("DFF_CHAR_ROOT")
```

---

## Running PVT Characterization

After configuring the environment, launch Virtuoso from the same shell.

Then execute the PVT characterization script from the Virtuoso CIW:

```lisp
load(
    strcat(
        getShellEnvVar("DFF_CHAR_ROOT")
        "/ocean/dff_pvt_characterization.ocn"
    )
)
```

The automated flow performs:

```text
PVT Simulation
      |
      v
Maestro RDB Read
      |
      v
Single-Pass Cache Build
      |
      v
Setup / Hold / ETC Extraction
      |
      v
CSV Export
      |
      v
Python Post-Processing
      |
      v
PVT_RESULT.xlsx
```

---

## Running Monte Carlo Characterization

Execute the Monte Carlo characterization script from the Virtuoso CIW:

```lisp
load(
    strcat(
        getShellEnvVar("DFF_CHAR_ROOT")
        "/ocean/dff_monte_characterization.ocn"
    )
)
```

The automated flow performs:

```text
Monte Carlo Simulation
        |
        v
  Maestro RDB Read
        |
        v
Single-Pass Cache Build
        |
        v
Setup / Hold / ETC Extraction
        |
        v
      CSV Export
        |
        v
Python Post-Processing
        |
        v
 MONTE_RESULT.xlsx
```

---

## Benchmark Scripts

PVT benchmark:

```text
benchmark/benchmark_pvt_postprocess.ocn
```

Monte Carlo benchmark:

```text
benchmark/benchmark_monte_postprocess.ocn
```

The benchmark scripts compare:

```text
Legacy Repeated RDB Traversal

vs.

Single-Pass Cached RDB Processing
```

The comparison focuses specifically on Maestro RDB post-processing performance.

---

## Requirements

The project was developed using:

```text
Cadence Virtuoso ADE Explorer / Assembler
Spectre
OCEAN / SKILL
Python 3
openpyxl
csh / tcsh
```

A compatible Cadence environment and appropriate process model files are required.

PDK files, proprietary model files, and proprietary Cadence simulation databases are not included in this repository.

---

## Git-Ignored Files

User-specific and generated files are excluded from Git.

The current `.gitignore` excludes:

```text
config/config.il

data/raw/*.csv

logs/*.log

results/*.xlsx
```

This keeps the repository focused on the reusable automation framework rather than local environment information and generated characterization data.

---

## Design Principle

The core optimization principle of this project is:

> Read the expensive Maestro result database once, cache the required characterization data in memory, and perform subsequent characterization analysis using the cached representation.

This approach preserves characterization results while substantially reducing post-processing runtime for both PVT and Monte Carlo flows.
