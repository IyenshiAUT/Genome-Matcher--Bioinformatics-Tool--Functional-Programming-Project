-- | Utils.hs - Utility functions for DNA sequence processing
-- Demonstrates string processing and helper functions in Haskell

module Utils (
    parseDNAString,
    formatRisk
) where

import DataTypes
import Data.Char (toUpper)

-- | Parse raw DNA string into structured DNA type
-- Demonstrates: List processing, filtering, mapping, pattern matching
-- Input: Raw string like "ATCGATCG" or "atcg ATCG\n"
-- Output: Structured DNA sequence [A,T,C,G,A,T,C,G]
parseDNAString :: String -> DNA
parseDNAString raw = map charToBase $ filter (`elem` "ACGTacgt") raw
  where
    -- Local function demonstrating pattern matching and guards
    charToBase :: Char -> Base
    charToBase c
        | toUpper c == 'A' = A
        | toUpper c == 'C' = C
        | toUpper c == 'G' = G
        | toUpper c == 'T' = T
        | otherwise        = A -- Safe default fallback

-- | Format risk score for human-readable display
-- Demonstrates: Guards, pattern matching on numeric ranges
-- Used for converting numeric risk scores to descriptive labels
formatRisk :: Double -> String
formatRisk score
    | score > 50.0 = "CRITICAL RISK"
    | score > 20.0 = "High Risk"
    | score > 10.0 = "Medium Risk"
    | score > 5.0  = "Low Risk"
    | otherwise    = "Minimal Risk"
