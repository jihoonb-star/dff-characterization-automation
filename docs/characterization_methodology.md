# Characterization Methodology

This document describes the timing-extraction and characterization methodology used by the DFF Characterization Automation framework.

## 1. Setup-Time Extraction

Setup-time characterization sweeps the configured setup-time variable while keeping hold time fixed.

For each sweep point, the framework evaluates CLK-to-Q delay.

The nominal CLK-to-Q delay is taken at the configured reference point:

```text
Reference Setup = 1 ns
```

The timing boundary is defined by:

```text
Threshold tCQ = Nominal tCQ × 1.005
```

The extraction flow is:

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

The crossing is linearly interpolated between the two surrounding sweep points.

The final setup-time value is reported in `ps`.

---

## 2. Hold-Time Extraction

Hold-time characterization uses the same CLK-to-Q degradation criterion.

The hold-time variable is swept while setup time is fixed.

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

The final hold-time value is reported in `ps`.

---

## 3. Additional Scalar Metrics

Additional ADE scalar outputs are collected through the ETC test.

Typical outputs include:

```text
POWER_CONSUMPTION
DELAY_CLK_TO_Q
Q_RISING_TIME
```

The ETC metric list is discovered dynamically from the ADE result database.

This allows scalar outputs to be added without changing the main cache-processing architecture.

ETC values are stored as raw ADE-evaluated scalar values. If a different display unit is required, scaling should be applied directly in the ADE/OCEAN output expression.

---

## 4. PVT Characterization

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

Therefore:

```text
5 Process Corners × 3 Temperatures × 3 Supply Voltages
= 45 PVT Conditions
```

For each PVT condition, the framework extracts:

- Setup time
- Hold time
- ETC scalar metrics

The PVT cache key is:

```text
Process | Temperature | VDD
```

---

## 5. Monte Carlo Characterization

Monte Carlo characterization supports configurable:

- Monte Carlo sample count
- Random seed
- Temperature conditions
- Supply-voltage conditions
- Monte Carlo model section

Each Monte Carlo sample is identified using:

```text
monteCarlo::param::sequence
```

The Monte Carlo cache key is:

```text
Sequence | Temperature | VDD
```

---

## 6. Monte Carlo Statistics

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
Python: statistics.stdev()
Excel equivalent: STDEV.S
Denominator: N - 1
```

Setup and Hold values are reported in `ps`.

ETC values remain in their raw ADE-evaluated units.

### Statistical Scope

The current Monte Carlo implementation pools the configured Monte Carlo samples and configured voltage/temperature conditions for each metric.

Therefore, the resulting sigma may include contributions from:

```text
Monte Carlo Variation
+
Deterministic VDD Shift
+
Deterministic Temperature Shift
```

It should not be interpreted as a single-voltage, single-temperature mismatch-only sigma unless the characterization is configured accordingly.

