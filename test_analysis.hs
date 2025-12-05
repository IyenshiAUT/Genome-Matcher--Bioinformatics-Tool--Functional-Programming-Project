-- Test script to verify analysis functionality
import DataTypes
import Processing
import Utils

-- Test data
refDNA = parseDNAString "ATGCGATCGATCGATCGTAGCTAGCTAGCAATCGATCGATCGATCGTAGCTAGCTAG"
patDNA1 = parseDNAString "ATGCGATCGATCGATCGTAGCTACCTAGCAATCGATCGATCGATCGTAGCTAGCTAG" -- mutation at position 21: G->C
patDNA2 = parseDNAString "ATGCGATCGATCGATCGTAGCTAGCTTGCAATCGATCGATCGATCGTAGCTAGCTAG" -- mutation at position 25: A->T

main :: IO ()
main = do
    putStrLn "Testing DNA Analysis..."
    
    let result1 = analyzePatient refDNA ("Patient1", patDNA1)
    let result2 = analyzePatient refDNA ("Patient2", patDNA2)
    
    putStrLn $ "Patient 1 Result: " ++ show result1
    putStrLn $ "Patient 2 Result: " ++ show result2
    
    putStrLn "\nMutation details:"
    let (_, muts1, score1, _) = result1
    let (_, muts2, score2, _) = result2
    
    putStrLn $ "Patient 1 mutations: " ++ show muts1
    putStrLn $ "Patient 1 score: " ++ show score1
    putStrLn $ "Patient 2 mutations: " ++ show muts2  
    putStrLn $ "Patient 2 score: " ++ show score2