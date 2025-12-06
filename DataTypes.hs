{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DeriveAnyClass #-}

module DataTypes (
    Base(..),
    DNA,
    Mutation(..),
    RiskLevel(..),
    Patient(..),
    AnalysisReport,
    AminoAcid(..),
    Protein,
    MutationType(..),
    GeneRegion(..),
    MutationImpact(..),
    DetailedReport
) where

import Control.DeepSeq (NFData)
import GHC.Generics (Generic)

-- [Task 2.1] Core ADTs: Define Base, DNA, Mutation, and RiskLevel
-- The basic building block of DNA
data Base = A | C | G | T 
    deriving (Show, Eq, Read, Enum, Generic, NFData)

type DNA = [Base]

-- [Task 2.1] (Advanced Extension): Amino Acids for Protein Translation
-- Represents the 20 standard amino acids + STOP codon
data AminoAcid = 
      Phe | Leu | Ser | Tyr | Cys | Trp | Pro | His | Gln | Arg | Ile | Met | Thr | Asn | Lys | Val | Ala | Asp | Glu | Gly | STOP
    deriving (Show, Eq, Generic, NFData)

type Protein = [AminoAcid]

-- [Task 2.1] Representing a Genetic Mutation with severity
data Mutation = Mutation {
    position :: Int,
    original :: Base,
    current  :: Base,
    severity :: RiskLevel
} deriving (Show, Generic, NFData)

-- [Task 2.1] Risk Levels ordered by severity
data RiskLevel = Benign | Low | Medium | High | Critical
    deriving (Show, Eq, Ord, Generic, NFData)

-- [Task 2.2] Records: Define Patient and AnalysisReport type aliases
data Patient = Patient {
    patientId :: String,
    dnaSequence :: DNA
} deriving (Show)

-- [Task 2.2] (Advanced): Updated Report type to include Protein sequence
-- (Patient ID, List of Mutations, Risk Score, Protein Chain)
type AnalysisReport = (String, [Mutation], Double, Protein)

-- ADVANCED: Mutation Type Classification
data MutationType = 
    Substitution    -- Single base change (SNP)
    | Insertion     -- Base(s) added
    | Deletion      -- Base(s) removed
    | Silent        -- No protein change
    | Missense      -- Different amino acid
    | Nonsense      -- Creates stop codon
    deriving (Show, Eq)

-- ADVANCED: Gene Region Classification
data GeneRegion =
    Exon            -- Protein-coding region
    | Intron        -- Non-coding region
    | Promoter      -- Gene regulation region
    | UTR           -- Untranslated region
    | Intergenic    -- Between genes
    deriving (Show, Eq)

-- ADVANCED: Mutation Impact Assessment
data MutationImpact = MutationImpact {
    mutationType :: MutationType,
    geneRegion :: GeneRegion,
    proteinChange :: Maybe (AminoAcid, AminoAcid),  -- (original, new)
    clinicalSignificance :: String,
    recommendations :: [String]
} deriving (Show)

-- ADVANCED: Detailed Analysis Report
type DetailedReport = (String, [Mutation], Double, Protein, [MutationImpact], String)