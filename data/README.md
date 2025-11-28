# Genome Matcher - Bioinformatics DNA Analysis Tool

**Group Members:** [Add your names here]  
**Course:** Functional Programming  
**Project Title:** Genome Matcher - DNA Mutation Analysis System

## 🧬 Problem Description

In the field of bioinformatics, analyzing DNA sequences to identify genetic mutations is crucial for medical research and diagnosis. The **Genome Matcher** simulates a real-world scenario where:

1. **Medical researchers** need to compare patient DNA samples against a reference genome
2. **Genetic counselors** require risk assessment based on identified mutations
3. **Healthcare systems** need automated analysis of multiple patient samples

**Real-World Scenario:**
You are a bioinformatics specialist at a medical research facility. You receive DNA samples from patients suspected of having genetic disorders. Your job is to:

- Compare each patient's DNA against a healthy reference genome
- Identify mutations (changes in DNA bases: A, C, G, T)
- Calculate risk scores based on mutation severity
- Generate reports for medical staff

This tool demonstrates how **functional programming principles** can be applied to solve complex scientific computing problems with **reliability**, **type safety**, and **mathematical precision**.

## 🚀 Instructions to Run the Program

### Prerequisites

- GHC (Glasgow Haskell Compiler) installed
- Windows PowerShell or Command Prompt

### Step 1: Compile the Program

```bash
cd "d:\8th_Semester\Functional Programming\Project"
ghc --make Main.hs -o genome-matcher
```

### Step 2: Run the Application

```bash
.\genome-matcher.exe
```

### Alternative: Console Version

```bash
ghc --make MainConsole.hs -o genome-matcher-console
.\genome-matcher-console.exe
```

## 📊 Sample Input/Output

### Input Files (Auto-generated)

The program creates these test files automatically:

**reference.dna** (Healthy genome):

```
ATCGATCGATCGATCGAAAA
```

**patient1.dna** (Healthy patient):

```
ATCGATCGATCGATCGAAAA
```

**patient2.dna** (Critical mutation):

```
TTCGATCGATCGATCGAAAA
```

### Sample Output

```
=== Genome Matcher - Bioinformatics Tool ===
Functional Programming Project
DNA Mutation Analysis System

Setting up demo DNA files...
Creating demonstration DNA files...
  ✓ Created reference.dna (baseline healthy genome)
  ✓ Created patient1.dna (healthy - no mutations)
  ✓ Created patient2.dna (critical mutation at position 0)
  ✓ Created patient3.dna (multiple mutations)

=== ANALYSIS RESULTS ===

--- Patient: patient1.dna ---
Mutations found: 0
Risk score: 0.0
Risk level: Benign
Status: Minimal Risk
✓ No mutations detected - Patient is healthy

--- Patient: patient2.dna ---
Mutations found: 1
Risk score: 30.0
Risk level: Critical
Status: CRITICAL RISK
Detailed mutations:
  Position 0: A -> T (High)

--- Patient: patient3.dna ---
Mutations found: 2
Risk score: 19.5
Risk level: High
Status: High Risk
Detailed mutations:
  Position 9: A -> T (High)
  Position 19: A -> T (High)
```

## 💡 Functional Programming Concepts Used

### 1. **Algebraic Data Types (ADTs)**

```haskell
-- Sum types for DNA bases
data Base = A | C | G | T

-- Product types with record syntax
data Mutation = Mutation {
    position :: Int,
    original :: Base,
    current  :: Base,
    severity :: RiskLevel
}
```

**Why:** Provides type safety and ensures invalid DNA bases cannot be created.

### 2. **Pure Functions**

```haskell
-- No side effects - same input always produces same output
diff :: DNA -> DNA -> [Mutation]
riskScore :: [Mutation] -> Double
```

**Why:** Mathematical reliability, easier testing, and parallel processing.

### 3. **Higher-Order Functions**

```haskell
-- map applies function to each element
totalScore = sum (map mutationScore mutations)

-- forM applies monadic action to each element
patients <- forM paths $ \path -> loadPatientFile path
```

**Why:** Code reusability and abstraction over iteration patterns.

### 4. **Recursion**

```haskell
-- Recursive DNA comparison
findMutations :: Int -> DNA -> DNA -> [Mutation]
findMutations pos (r:rs) (p:ps)
  | r == p    = findMutations (pos + 1) rs ps
  | otherwise = mutation : findMutations (pos + 1) rs ps
```

**Why:** Natural fit for list processing and mathematical induction.

### 5. **Pattern Matching**

```haskell
-- Exhaustive case analysis
determineSeverity :: Base -> Base -> RiskLevel
determineSeverity A T = High
determineSeverity T A = High
determineSeverity _ _ = Medium
```

**Why:** Compiler-checked completeness and clear logic flow.

### 6. **Type Safety**

```haskell
-- Compiler prevents mixing incompatible types
type DNA = [Base]          -- Can only contain valid bases
type Protein = [AminoAcid] -- Can only contain valid amino acids
```

**Why:** Catches errors at compile-time rather than runtime.

### 7. **Immutability**

```haskell
-- Data structures cannot be modified after creation
let mutations = diff reference patientDNA  -- Creates new list
let updatedRisk = riskScore mutations      -- Doesn't modify original
```

**Why:** Thread safety, easier debugging, and mathematical reasoning.

### 8. **Function Composition**

```haskell
-- Combine simple functions to build complex operations
analyzePatient reference patient =
    let mutations = diff reference (dnaSequence patient)
        risk = riskScore mutations
        protein = translateToProtein (dnaSequence patient)
    in (patientId patient, mutations, risk, protein)
```

**Why:** Builds complex behavior from simple, testable components.

### 9. **Monadic I/O**

```haskell
-- Controlled side effects in IO monad
loadReference :: FilePath -> IO DNA
loadReference path = do
    contents <- readFile path
    return (parseDNAString contents)
```

**Why:** Separates pure computation from side effects.

### 10. **List Comprehensions & Processing**

```haskell
-- Declarative data processing
parseDNAString raw = map charToBase $ filter (`elem` "ACGT") raw
```

**Why:** Expressive and concise data transformations.

## 🔬 Educational Value

This project demonstrates how **functional programming** excels in **scientific computing**:

- **Mathematical Correctness**: Pure functions provide predictable, testable algorithms
- **Type Safety**: Prevents invalid genetic data from causing runtime errors
- **Concurrency**: Immutable data enables safe parallel patient analysis
- **Composability**: Small, focused functions combine to solve complex problems
- **Domain Modeling**: ADTs naturally represent biological concepts

## 🏗️ Project Structure

```
├── Main.hs          # Application entry point
├── DataTypes.hs     # Core ADTs and type definitions
├── Processing.hs    # Pure mutation analysis algorithms
├── IOHandler.hs     # File I/O operations
├── Utils.hs         # Utility functions
├── README.md        # This documentation
└── data/            # Demo DNA data files
    ├── reference.dna      # Reference genome
    ├── patient1.dna       # Healthy patient
    ├── patient2.dna       # Critical mutation
    └── patient3.dna       # Multiple mutations
```

---

_This project showcases functional programming's power in solving real-world bioinformatics challenges with mathematical precision and type safety._

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
  "mutations": [{ "position": 42, "from": "A", "to": "T", "score": 0.2 }],
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
