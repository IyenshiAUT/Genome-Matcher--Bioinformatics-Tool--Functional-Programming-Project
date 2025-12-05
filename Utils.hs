module Utils (
    parseDNAString,
    formatRisk,
    unpack
) where

import DataTypes
import Data.Char (toUpper)
import Data.Text (unpack)

-- [Task 2.3] Parser: Filter & Map raw strings to strict DNA types
-- | Purely converts a raw string "ATCG" into our strict [Base] type.
-- | Ignores newlines, spaces, or invalid characters.
parseDNAString :: String -> DNA
parseDNAString raw = map charToBase $ filter (`elem` "ACGTacgt") raw
  where
    charToBase c
        | toUpper c == 'A' = A
        | toUpper c == 'C' = C
        | toUpper c == 'G' = G
        | toUpper c == 'T' = T
        | otherwise        = A -- Default fallback safety

-- [Task 3.4 Dependency] Helper to format risk score for display
-- Used by Role 3 in the Frontend to show text labels
formatRisk :: Double -> String
formatRisk score
    | score > 50.0 = "CRITICAL RISK"
    | score > 20.0 = "High Risk"
    | otherwise    = "Low Risk"