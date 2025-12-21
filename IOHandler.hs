module IOHandler (
    loadReference,
    loadPatients
) where

import DataTypes
import Utils
import Control.Monad (forM)

-- Ref Reader: IO Action to read reference file
loadReference :: FilePath -> IO DNA
loadReference path = do
    putStrLn $ "Loading Reference Genome from " ++ path
    contents <- readFile path
    return (parseDNAString contents)

-- Patient Reader: Loop through file list
loadPatients :: [FilePath] -> IO [Patient]
loadPatients paths = forM paths $ \path -> do
    -- Error Handling/Status updates
    putStrLn $ "Loading patient data: " ++ path
    contents <- readFile path
    return (Patient path (parseDNAString contents))