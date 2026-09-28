# Post-Processing Optimization

This document describes the Maestro RDB post-processing optimization and benchmark methodology used by the DFF Characterization Automation framework.

## 1. Legacy Architecture

The original implementation repeatedly traversed:

```lisp
rdb->points()
```

Separate RDB scans were performed for:

- Setup conditions
- Hold conditions
- ETC conditions
- Process discovery
- Temperature discovery
- VDD discovery
- ETC metric discovery

As the characterization space increased, repeated RDB traversal became the dominant post-processing overhead.

---

## 2. Single-Pass Architecture

The optimized implementation performs one complete RDB traversal and stores the required characterization data in memory.

```text
Maestro RDB
    |
    v
Single Traversal
    |
    +--> Setup Cache
    |
    +--> Hold Cache
    |
    +--> ETC Cache
    |
    v
Cached Result Processing
    |
    v
CSV Export
```

After the cache is built, timing extraction and ETC retrieval are performed without repeatedly scanning the RDB.

### PVT Cache Key

```text
Process | Temperature | VDD
```

### Monte Carlo Cache Key

```text
Sequence | Temperature | VDD
```

---

## 3. Benchmark Methodology

The benchmark compares:

```text
Legacy Repeated RDB Traversal
vs.
Single-Pass Cached RDB Processing
```

The comparison focuses specifically on Maestro RDB post-processing.

The following are excluded from the Legacy vs. Single-Pass runtime comparison:

- Circuit simulation
- CSV I/O
- Python post-processing
- Excel generation

Both implementations process the same Maestro result database.

Correctness is verified using:

- Result counts
- Result checksums

Each benchmark was repeated three times.

The median Legacy and Single-Pass runtimes were used as representative values.

---

## 4. PVT Benchmark

The PVT benchmark contains:

```text
45 PVT Conditions
```

Three runs produced:

| Run | Legacy | Single-Pass | Speedup | Runtime Reduction |
|---|---:|---:|---:|---:|
| 1 | 1116 s | 9 s | 124.000× | 99.19% |
| 2 | 1130 s | 10 s | 113.000× | 99.12% |
| 3 | 1124 s | 9 s | 124.889× | 99.20% |

Representative median values:

```text
Legacy Median    : 1124 s
Single-Pass      : 9 s
Speedup          : 124.89×
Runtime Reduction: 99.20%
```

Equivalent runtime:

```text
Legacy      : 18 min 44 s
Single-Pass : 9 s
```

Result validation:

```text
Setup Results : 45
Hold Results  : 45
ETC Results   : 135

Result Counts : identical
Checksums     : identical
```

---

## 5. Monte Carlo Benchmark

Three benchmark runs produced:

| Run | Legacy | Single-Pass | Speedup | Runtime Reduction |
|---|---:|---:|---:|---:|
| 1 | 1686 s | 16 s | 105.375× | 99.05% |
| 2 | 1440 s | 13 s | 110.769× | 99.10% |
| 3 | 4860 s | 31 s | 156.774× | 99.36% |

Representative median values:

```text
Legacy Median    : 1686 s
Single-Pass      : 16 s
Speedup          : 105.38×
Runtime Reduction: 99.05%
```

Equivalent runtime:

```text
Legacy      : 28 min 06 s
Single-Pass : 16 s
```

Result validation:

```text
Setup Results : 40
Hold Results  : 40
ETC Results   : 120

Result Counts : identical
Checksums     : identical
```

The Legacy and Single-Pass implementations were evaluated on the same Maestro history for each benchmark run.

---

## 6. Benchmark Summary

| Characterization | Legacy | Single-Pass | Speedup | Runtime Reduction |
|---|---:|---:|---:|---:|
| PVT | 1124 s | 9 s | 124.89× | 99.20% |
| Monte Carlo | 1686 s | 16 s | 105.38× | 99.05% |

The optimization reduced representative post-processing runtime by more than 99% for both characterization flows while preserving identical result counts and checksums.

