-- | Main.hs - Entry point for the Genome Matcher Bioinformatics Tool
-- Group Members: [Your Names Here]
-- Course: Functional Programming
-- Project: Genome Matcher - DNA Mutation Analysis Tool

module Main where

import DataTypes
import Processing
import IOHandler
import Utils

-- | Main application entry point
-- Demonstrates functional programming concepts in bioinformatics
main :: IO ()
main = do
    putStrLn "=== Genome Matcher - Bioinformatics Tool ==="
    putStrLn "Functional Programming Project"
    putStrLn "DNA Mutation Analysis System\n"
    
    -- Setup demo data files
    putStrLn "Setting up demo DNA files..."
    setupDemoFiles
    
    -- Load reference genome (healthy DNA sequence)
    putStrLn "Loading reference genome..."
    reference <- loadReference "data/reference.dna"
    
    -- Load patient DNA samples for analysis
    putStrLn "Loading patient DNA samples..."
    patients <- loadPatients ["data/patient1.dna", "data/patient2.dna", "data/patient3.dna"]
    
    -- Perform parallel analysis of all patients
    putStrLn "\n=== ANALYSIS RESULTS ==="
    mapM_ (analyzeAndReport reference) patients
    
    putStrLn "\n=== Analysis Complete ==="
    putStrLn "Thank you for using Genome Matcher!"

-- | Analyze a single patient and report results
-- Demonstrates pure functional processing of genetic data
analyzeAndReport :: DNA -> Patient -> IO ()
analyzeAndReport reference patient = do
    let patientDNA = dnaSequence patient
    let mutations = diff reference patientDNA  -- Pure function
    let risk = riskScore mutations             -- Pure function
    let riskLevel = classifyRisk risk          -- Pure function
    
    putStrLn $ "\n--- Patient: " ++ patientId patient ++ " ---"
    putStrLn $ "Mutations found: " ++ show (length mutations)
    putStrLn $ "Risk score: " ++ show risk
    putStrLn $ "Risk level: " ++ show riskLevel
    putStrLn $ "Status: " ++ formatRisk risk
    
    -- Display mutation details if any found
    if not (null mutations)
    then do
        putStrLn "Detailed mutations:"
        mapM_ printMutation (take 3 mutations)  -- Show first 3 mutations
    else putStrLn "✓ No mutations detected - Patient is healthy"

-- | Pretty print mutation information
printMutation :: Mutation -> IO ()
printMutation (Mutation pos orig new sev) = 
    putStrLn $ "  Position " ++ show pos ++ ": " ++ show orig ++ " -> " ++ show new ++ " (" ++ show sev ++ ")"
