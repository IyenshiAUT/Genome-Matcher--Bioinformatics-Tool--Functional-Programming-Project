module IOHandler (
loadReference,
loadPatients,
setupDemoFiles
) where

import System.IO
import DataTypes
import Utils
import Control.Monad (forM)

-- [Task 2.4] Ref Reader: IO Action to read reference file
loadReference :: FilePath -> IO DNA
loadReference path = do
putStrLn $ "Loading Reference Genome from " ++ path
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
-- This creates the environment for the project to run
setupDemoFiles :: IO ()
setupDemoFiles = do
putStrLn "Generating demo DNA files..."

-- Task 4.1: Baseline Data
writeFile "reference.dna" "ATCGATCGATCGATCGAAAA"

-- Task 4.2: Healthy Case
writeFile "patient1.dna"  "ATCGATCGATCGATCGAAAA"

-- Task 4.3: Critical Case (First base changed T instead of A)
writeFile "patient2.dna"  "TTCGATCGATCGATCGAAAA"

-- Task 4.4: High Risk Case (A->T mutation in middle)
writeFile "patient3.dna"  "ATCGATCGTTCGATCGAAAA"

putStrLn "Demo files created."