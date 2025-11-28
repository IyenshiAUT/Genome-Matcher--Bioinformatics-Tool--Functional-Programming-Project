-- | DataTypes.hs - Core data types for genetic analysis
-- Demonstrates Algebraic Data Types (ADTs) and type safety in Haskell

module DataTypes (
    -- * Core DNA Types
    Base(..),
    DNA,
    -- * Mutation Analysis Types
    Mutation(..),
    RiskLevel(..),
    -- * Patient Management Types
    Patient(..),
    AnalysisReport,
    -- * Protein Analysis Types (Advanced)
    AminoAcid(..),
    Protein
) where

-- | DNA Base representation using Algebraic Data Types (ADT)
-- Demonstrates: Sum types, pattern matching, type safety
data Base = A | C | G | T 
    deriving (Show, Eq, Read, Enum)

-- | DNA sequence as a list of bases
-- Demonstrates: Type aliases, list processing
type DNA = [Base]

-- | Amino acid representation for protein synthesis
-- Demonstrates: Complex ADTs with multiple constructors
data AminoAcid = 
      Phe | Leu | Ser | Tyr | Cys | Trp | Pro | His | Gln | Arg 
    | Ile | Met | Thr | Asn | Lys | Val | Ala | Asp | Glu | Gly 
    | STOP
    deriving (Show, Eq)

-- | Protein sequence as a list of amino acids
type Protein = [AminoAcid]

-- | Genetic mutation representation using Record Syntax
-- Demonstrates: Product types, record syntax, named fields
data Mutation = Mutation {
    position :: Int,        -- Position in DNA sequence
    original :: Base,       -- Original base in reference
    current  :: Base,       -- Mutated base in patient
    severity :: RiskLevel   -- Calculated severity level
} deriving (Show)

-- | Risk assessment levels with ordering
-- Demonstrates: Ordered ADTs, deriving type classes
data RiskLevel = Benign | Low | Medium | High | Critical
    deriving (Show, Eq, Ord)

-- | Patient information using Record Syntax
-- Demonstrates: Records, encapsulation of related data
data Patient = Patient {
    patientId :: String,    -- Patient identifier
    dnaSequence :: DNA      -- Patient's DNA sequence
} deriving (Show)

-- | Analysis report as a tuple
-- Demonstrates: Product types, tuple usage
-- Format: (Patient ID, Mutations Found, Risk Score, Protein Sequence)
type AnalysisReport = (String, [Mutation], Double, Protein)
