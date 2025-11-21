# Genome Matcher - Bioinformatics DNA Analysis Tool

A Haskell-based bioinformatics tool for comparing DNA sequences to identify mutations and calculate genetic risk scores. This project demonstrates functional programming principles applied to real-world scientific computing problems.

## 🧬 Overview

The Genome Matcher processes DNA sequences to identify genetic variations by comparing patient samples against a reference genome. It's designed to mimic tools used in medical research for mutation detection and genetic analysis.

### Key Features

- **DNA Sequence Comparison**: Compare patient DNA against reference genomes
- **Mutation Detection**: Identify substitutions, insertions, and deletions
- **Risk Assessment**: Calculate health risk scores based on mutation patterns
- **Concurrent Processing**: Parallel analysis of multiple patient files
- **Functional Design**: Pure functions for reliable, testable bioinformatics algorithms

## 🔬 Scientific Background

DNA sequences consist of four nucleotide bases (A, C, G, T). Mutations occur when these bases change, potentially affecting protein synthesis and health outcomes. This tool helps identify such variations for research and diagnostic purposes.

## 🏗️ Architecture

The project follows a clean functional architecture with clear separation of concerns:

```
├── DataTypess.hs      # Core data types and structures
├── IOHandler.hs       # File I/O operations
├── Processing.hs      # Pure mutation analysis algorithms
├── Utils.hs          # Utility functions
├── Main.hs           # Application entry point
└── Frontend/         # User interface components
```

### Data Types

```haskell
-- Core DNA representation
data Base = A | C | G | T
type DNA = [Base]

-- Mutation detection
data Mutation = Substitution 
  { pos :: Int
  , original :: Base
  , new :: Base
  }

-- Analysis results
data AnalysisResult = AnalysisResult
  { patientId :: String
  , mutations :: [Mutation]
  , riskScore :: Double
  }
```

## 🚀 Getting Started

### Prerequisites

- [Haskell Stack](https://docs.haskellstack.org/en/stable/README/)
- GHC (Glasgow Haskell Compiler)

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd genome-matcher
```

2. Initialize Stack project:
```bash
stack init
```

3. Build the project:
```bash
stack build
```

### Running the Application

1. **Basic Analysis**:
```bash
stack run
```

2. **With Custom Data**:
```bash
stack run -- --reference data/reference.dna --patients data/patients/
```

### Building and Testing

- **Build**: `stack build` or use VS Code task "haskell build"
- **Clean Build**: `stack clean && stack build` or use "haskell clean & build"
- **Run Tests**: `stack test` or use "haskell test"
- **Watch Mode**: `stack build --file-watch` or use "haskell watch"

## 📁 Data Format

### DNA Files (.dna)

DNA sequence files should contain nucleotide sequences in plain text format:

```
ATCGATCGATCGATCG
GCTAGCTAGCTAGCTA
TTAACCGGTTAACCGG
```

### Directory Structure

```
data/
├── reference.dna           # Reference genome
└── patients/              # Patient samples
    ├── patient_001.dna
    ├── patient_002.dna
    └── ...
```

## ⚡ Core Algorithms

### Mutation Detection

The `diff` function compares two DNA sequences position by position:

```haskell
diff :: DNA -> DNA -> [Mutation]
```

Uses functional programming techniques:
- `zip` for parallel sequence traversal
- List comprehensions for mutation filtering
- Recursion for sequence alignment

### Risk Scoring

The `riskScore` function calculates health risk based on mutation patterns:

```haskell
riskScore :: [Mutation] -> Double
```

Considers:
- Mutation frequency
- Position significance
- Base change severity

### Concurrent Processing

Patient files are processed in parallel using Haskell's concurrency primitives:
- Each patient analysis is independent
- Results are collected and aggregated
- Optimal CPU utilization for large datasets

## 🔧 Configuration

### Mutation Scoring Weights

Customize mutation impact scoring in `Processing.hs`:

```haskell
-- Example scoring weights
substitutionWeight :: Base -> Base -> Double
substitutionWeight A T = 0.8  -- High impact
substitutionWeight C G = 0.3  -- Low impact
-- ... other combinations
```

### Analysis Parameters

Adjust analysis sensitivity:

```haskell
-- Minimum risk threshold for reporting
minRiskThreshold :: Double
minRiskThreshold = 0.1

-- Maximum sequence length for analysis
maxSequenceLength :: Int
maxSequenceLength = 10000
```

## 📊 Output Format

Analysis results are provided in multiple formats:

### Console Output
```
Patient Analysis Results
========================
Patient ID: patient_001
Mutations Found: 3
Risk Score: 0.45

Detailed Mutations:
- Position 42: A → T (Score: 0.2)
- Position 127: G → C (Score: 0.15)
- Position 203: C → A (Score: 0.1)
```

### JSON Export
```json
{
  "patientId": "patient_001",
  "mutations": [
    {"position": 42, "from": "A", "to": "T", "score": 0.2}
  ],
  "totalRiskScore": 0.45,
  "analysisDate": "2025-11-21T10:30:00Z"
}
```

## 🧪 Example Usage

### Basic Mutation Detection

```haskell
-- Load sequences
reference <- readDNA "data/reference.dna"
patient <- readDNA "data/patients/patient_001.dna"

-- Find mutations
let mutations = diff reference patient
let risk = riskScore mutations

-- Display results
putStrLn $ "Risk Score: " ++ show risk
mapM_ print mutations
```

### Batch Processing

```haskell
-- Process multiple patients concurrently
patientFiles <- listDirectory "data/patients/"
results <- mapConcurrently analyzePatient patientFiles

-- Generate summary report
let highRiskPatients = filter ((> 0.5) . riskScore) results
generateReport highRiskPatients
```

## 🔬 Scientific Applications

This tool can be adapted for various bioinformatics applications:

1. **Genetic Disease Research**: Identify disease-associated mutations
2. **Pharmacogenomics**: Analyze drug response variations
3. **Population Genetics**: Study genetic diversity and evolution
4. **Cancer Research**: Detect somatic mutations in tumor samples
5. **Agricultural Genomics**: Analyze crop genetic variations

## 📚 Educational Value

This project demonstrates key functional programming concepts:

- **Pure Functions**: Reliable, testable mutation detection algorithms
- **Immutable Data**: Safe concurrent processing of genetic data
- **Higher-Order Functions**: Flexible analysis pipelines
- **Type Safety**: Compile-time guarantees for genetic data integrity
- **Lazy Evaluation**: Efficient processing of large genomic datasets

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/new-analysis`)
3. Commit your changes (`git commit -am 'Add new analysis method'`)
4. Push to the branch (`git push origin feature/new-analysis`)
5. Open a Pull Request

### Development Guidelines

- Follow Haskell style conventions
- Add type signatures for all top-level functions
- Include unit tests for new algorithms
- Document complex bioinformatics logic
- Use meaningful variable names for genetic concepts

## 📖 References

- [Bioinformatics Algorithms](https://www.bioinformaticsalgorithms.org/)
- [Haskell for Bioinformatics](https://hackage.haskell.org/package/bio)
- [NCBI Sequence Analysis](https://www.ncbi.nlm.nih.gov/tools/)
- [Functional Programming in Biology](https://journals.plos.org/ploscompbiol/)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.


---

**Note**: This is an educational project for demonstrating functional programming concepts. For production bioinformatics analysis, please use established, peer-reviewed tools and consult with domain experts.