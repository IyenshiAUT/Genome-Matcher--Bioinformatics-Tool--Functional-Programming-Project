-- | IOHandler.hs - File I/O operations for DNA sequence data
-- Demonstrates I/O operations, error handling, and file processing in Haskell
-- Key concepts: IO monad, file operations, list processing

module IOHandler (
    loadReference,
    loadPatients,
    setupDemoFiles
) where

import System.IO
import DataTypes
import Utils
import Control.Monad (forM)

-- | Load reference genome from file
-- Demonstrates: IO operations, file reading, function composition
loadReference :: FilePath -> IO DNA
loadReference path = do
    putStrLn $ "Loading reference genome from: " ++ path
    contents <- readFile path
    return (parseDNAString contents)

-- [Task 2.5] Patient Reader: Loop through file list
loadPatients :: [FilePath] -> IO [Patient]
loadPatients paths = forM paths $ \path -> do
    -- [Task 2.6] Error Handling/Status updates
    putStrLn $ "Loading patient data: " ++ path
    contents <- readFile path
    return (Patient path (parseDNAString contents))

-- [Task 4.1, 4.2, 4.3, 4.4] Setup Dummy/Test Data Files
-- Running this ensures the project works immediately
setupDemoFiles :: IO ()
setupDemoFiles = do
    putStrLn "Generating demo DNA files..."
    
    -- Task 4.1: Baseline Data
    writeFile "data/reference.dna" "ATCGATCGATCGATCGAAAA"
    
    -- Task 4.2: Healthy Case
    writeFile "data/patient1.dna"  "ATCGATCGATCGATCGAAAA" 
    
    -- Task 4.3: Critical Case (First base changed T instead of A)
    writeFile "data/patient2.dna"  "TTCGATCGATCGATCGAAAA" 
    
    -- Task 4.4: High Risk Case (A->T mutation in middle)
    writeFile "data/patient3.dna"  "ATCGATCGTTCGATCGAAAA" 
    
    putStrLn "Demo files created in data/ directory."
