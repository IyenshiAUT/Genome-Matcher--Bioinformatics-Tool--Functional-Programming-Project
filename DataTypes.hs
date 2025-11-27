module DataTypes (
    Base(..),
    DNA,
    Mutation(..),
    RiskLevel(..),
    Patient(..),
    AnalysisReport,
    AminoAcid(..),
    Protein
) where

-- [Task 2.1] Core ADTs: Define Base, DNA, Mutation, and RiskLevel
-- The basic building block of DNA
data Base = A | C | G | T 
    deriving (Show, Eq, Read, Enum)

type DNA = [Base]

-- [Task 2.1] (Advanced Extension): Amino Acids for Protein Translation
-- Represents the 20 standard amino acids + STOP codon
data AminoAcid = 
      Phe | Leu | Ser | Tyr | Cys | Trp | Pro | His | Gln | Arg | Ile | Met | Thr | Asn | Lys | Val | Ala | Asp | Glu | Gly | STOP
    deriving (Show, Eq)

type Protein = [AminoAcid]

-- [Task 2.1] Representing a Genetic Mutation with severity
data Mutation = Mutation {
    position :: Int,
    original :: Base,
    current  :: Base,
    severity :: RiskLevel
} deriving (Show)

-- [Task 2.1] Risk Levels ordered by severity
data RiskLevel = Benign | Low | Medium | High | Critical
    deriving (Show, Eq, Ord)

-- [Task 2.2] Records: Define Patient and AnalysisReport type aliases
data Patient = Patient {
    patientId :: String,
    dnaSequence :: DNA
} deriving (Show)

-- [Task 2.2] (Advanced): Updated Report type to include Protein sequence
-- (Patient ID, List of Mutations, Risk Score, Protein Chain)
type AnalysisReport = (String, [Mutation], Double, Protein)
