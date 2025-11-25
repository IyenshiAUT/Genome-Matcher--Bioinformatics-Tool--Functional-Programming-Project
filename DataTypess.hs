{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE OverloadedStrings #-}


module DataTypess where

import Data.Time (UTCTime)
import GHC.Generics (Generic)
import Data.Aeson (ToJSON, FromJSON)

-- | Represents the four DNA nucleotide bases
data Base = A | C | G | T
    deriving (Eq, Ord, Show, Read, Enum, Bounded, Generic)

instance ToJSON Base
instance FromJSON Base

-- | DNA sequence represented as a list of bases
type DNA = [Base]

-- | Position in a DNA sequence (0-indexed)
type Position = Int

-- | Patient identifier
type PatientId = String

-- | File path for DNA sequence files
type FilePath' = String

-- | Different types of mutations that can occur in DNA
data MutationType = 
    SubstitutionType    -- Single base substitution
    | InsertionType     -- Base insertion
    | DeletionType      -- Base deletion
    deriving (Eq, Show, Generic)

instance ToJSON MutationType
instance FromJSON MutationType

-- | Represents a single mutation in a DNA sequence
data Mutation = 
    Substitution 
        { pos :: Position
        , original :: Base
        , new :: Base
        }
    | Insertion
        { pos :: Position
        , inserted :: Base
        }
    | Deletion
        { pos :: Position
        , deleted :: Base
        }
    deriving (Eq, Show, Generic)

instance ToJSON Mutation
instance FromJSON Mutation

-- | Get the mutation type from a Mutation
getMutationType :: Mutation -> MutationType
getMutationType (Substitution _ _ _) = SubstitutionType
getMutationType (Insertion _ _) = InsertionType
getMutationType (Deletion _ _) = DeletionType

-- | Get the position of any mutation
getMutationPos :: Mutation -> Position
getMutationPos (Substitution p _ _) = p
getMutationPos (Insertion p _) = p
getMutationPos (Deletion p _) = p

-- | Risk score represented as a double between 0.0 and 1.0
type RiskScore = Double

-- | Analysis configuration parameters
data AnalysisConfig = AnalysisConfig
    { minRiskThreshold :: RiskScore      -- Minimum risk threshold for reporting
    , maxSequenceLength :: Int           -- Maximum sequence length to analyze
    , substitutionWeight :: Double       -- Weight for substitution mutations
    , insertionWeight :: Double          -- Weight for insertion mutations
    , deletionWeight :: Double           -- Weight for deletion mutations
    , enableParallelProcessing :: Bool   -- Whether to use parallel processing
    } deriving (Eq, Show, Generic)

instance ToJSON AnalysisConfig
instance FromJSON AnalysisConfig

-- | Default analysis configuration
defaultConfig :: AnalysisConfig
defaultConfig = AnalysisConfig
    { minRiskThreshold = 0.1
    , maxSequenceLength = 10000
    , substitutionWeight = 1.0
    , insertionWeight = 1.2
    , deletionWeight = 1.1
    , enableParallelProcessing = True
    }

-- | Comprehensive analysis result for a single patient
data AnalysisResult = AnalysisResult
    { patientId :: PatientId
    , mutations :: [Mutation]
    , riskScore :: RiskScore
    , analysisDate :: UTCTime
    , referenceLength :: Int
    , patientLength :: Int
    , mutationCount :: Int
    , highRiskMutations :: [Mutation]    -- Mutations above risk threshold
    } deriving (Eq, Show, Generic)

instance ToJSON AnalysisResult
instance FromJSON AnalysisResult

-- | Summary statistics for batch analysis
data BatchSummary = BatchSummary
    { totalPatientsAnalyzed :: Int
    , averageRiskScore :: RiskScore
    , highRiskPatients :: [PatientId]
    , totalMutationsFound :: Int
    , analysisStartTime :: UTCTime
    , analysisEndTime :: UTCTime
    } deriving (Eq, Show, Generic)

instance ToJSON BatchSummary
instance FromJSON BatchSummary

-- | Error types that can occur during analysis
data AnalysisError = 
    FileNotFound FilePath'
    | InvalidDNASequence String
    | SequenceTooLong Int
    | EmptySequence FilePath'
    | ParseError String
    | IOError String
    deriving (Eq, Show)

-- | Result type for operations that can fail
type AnalysisIO a = Either AnalysisError a

-- | Mutation severity levels
data MutationSeverity = Low | Medium | High | Critical
    deriving (Eq, Ord, Show, Enum, Bounded, Generic)

instance ToJSON MutationSeverity
instance FromJSON MutationSeverity

-- | Enhanced mutation with severity assessment
data MutationWithSeverity = MutationWithSeverity
    { mutation :: Mutation
    , severity :: MutationSeverity
    , impactScore :: Double
    , description :: String
    } deriving (Eq, Show, Generic)

instance ToJSON MutationWithSeverity
instance FromJSON MutationWithSeverity

-- | Patient information structure
data Patient = Patient
    { patientIdentifier :: PatientId
    , patientFilePath :: FilePath'
    , patientSequence :: Maybe DNA     -- Lazy loading - Nothing until loaded
    } deriving (Eq, Show)

-- | Reference genome information
data ReferenceGenome = ReferenceGenome
    { referenceId :: String
    , referenceFilePath :: FilePath'
    , referenceSequence :: DNA
    , referenceMetadata :: ReferenceMetadata
    } deriving (Eq, Show)

-- | Metadata for reference genome
data ReferenceMetadata = ReferenceMetadata
    { organism :: String
    , version :: String
    , chromosomeInfo :: String
    , buildDate :: UTCTime
    , description :: String
    } deriving (Eq, Show, Generic)

instance ToJSON ReferenceMetadata
instance FromJSON ReferenceMetadata

-- | Analysis session information
data AnalysisSession = AnalysisSession
    { sessionId :: String
    , sessionConfig :: AnalysisConfig
    , referenceGenome :: ReferenceGenome
    , patients :: [Patient]
    , results :: [AnalysisResult]
    , sessionStartTime :: UTCTime
    } deriving (Eq, Show)

-- | Alignment result between two sequences
data AlignmentResult = AlignmentResult
    { alignmentScore :: Double
    , alignedReference :: DNA
    , alignedPatient :: DNA
    , alignmentLength :: Int
    , identicalBases :: Int
    , similarity :: Double             -- Percentage similarity
    } deriving (Eq, Show, Generic)

instance ToJSON AlignmentResult
instance FromJSON AlignmentResult

-- | Progress tracking for long-running analyses
data AnalysisProgress = AnalysisProgress
    { processedPatients :: Int
    , totalPatients :: Int
    , currentPatientId :: Maybe PatientId
    , estimatedTimeRemaining :: Maybe Int  -- Seconds
    , progressPercentage :: Double
    } deriving (Eq, Show, Generic)

instance ToJSON AnalysisProgress
instance FromJSON AnalysisProgress

-- | Export format options
data ExportFormat = JSON | CSV | TXT | XML
    deriving (Eq, Show, Enum, Bounded)

-- | Report generation options
data ReportOptions = ReportOptions
    { exportFormat :: ExportFormat
    , includeDetailedMutations :: Bool
    , includeStatistics :: Bool
    , includeLowRiskMutations :: Bool
    , outputFilePath :: FilePath'
    } deriving (Eq, Show)