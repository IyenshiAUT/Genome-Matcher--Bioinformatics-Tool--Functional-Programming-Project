-- | Processing.hs - Core mutation analysis algorithms
-- Demonstrates pure functional programming in bioinformatics
-- Key FP concepts: Pure functions, recursion, list processing, higher-order functions

module Processing (
    diff,
    riskScore,
    analyzePatient,
    translateToProtein,
    classifyRisk
) where

import DataTypes

-- | Compare two DNA sequences to identify mutations
-- Demonstrates: Recursion, pattern matching, list processing
-- This is a PURE function - no side effects, same input always gives same output
diff :: DNA -> DNA -> [Mutation]
diff reference patient = findMutations 0 reference patient
  where
    -- Recursive function with accumulator pattern
    findMutations :: Int -> DNA -> DNA -> [Mutation]
    findMutations _ [] [] = []                    -- Base case: both sequences empty
    findMutations _ [] _  = []                    -- Base case: reference shorter
    findMutations _ _ []  = []                    -- Base case: patient shorter
    findMutations pos (r:rs) (p:ps)
      | r == p    = findMutations (pos + 1) rs ps              -- No mutation, continue
      | otherwise = mutation : findMutations (pos + 1) rs ps   -- Mutation found
      where
        mutation = Mutation pos r p (determineSeverity r p)

-- | Calculate overall risk score from list of mutations
-- Demonstrates: Higher-order functions (map), folding, mathematical operations
riskScore :: [Mutation] -> Double
riskScore [] = 0.0
riskScore mutations = totalScore / fromIntegral (length mutations)
  where
    totalScore = sum (map mutationScore mutations)  -- map and sum are higher-order functions
    
    -- Score individual mutations based on base change impact
    mutationScore :: Mutation -> Double
    mutationScore (Mutation _ orig new sev) = 
        baseChangeScore orig new + severityBonus sev
    
    -- Different base changes have different biological impacts
    baseChangeScore :: Base -> Base -> Double
    baseChangeScore A T = 15.0  -- Purine to Pyrimidine (high impact)
    baseChangeScore T A = 15.0  -- Pyrimidine to Purine (high impact)
    baseChangeScore A C = 12.0  -- Different chemical properties
    baseChangeScore C A = 12.0
    baseChangeScore G C = 8.0   -- Similar chemical properties
    baseChangeScore C G = 8.0
    baseChangeScore G T = 10.0
    baseChangeScore T G = 10.0
    baseChangeScore A G = 6.0   -- Purine to Purine (lower impact)
    baseChangeScore G A = 6.0
    baseChangeScore C T = 4.0   -- Pyrimidine to Pyrimidine (lowest impact)
    baseChangeScore T C = 4.0
    baseChangeScore _ _ = 5.0    -- Default case
    
    -- Additional scoring based on severity classification
    severityBonus :: RiskLevel -> Double
    severityBonus Critical = 20.0
    severityBonus High     = 15.0
    severityBonus Medium   = 10.0
    severityBonus Low      = 5.0
    severityBonus Benign   = 0.0

-- | Determine mutation severity based on biological knowledge
-- Demonstrates: Pattern matching, decision logic
determineSeverity :: Base -> Base -> RiskLevel
determineSeverity orig new
    | (orig == A && new == T) || (orig == T && new == A) = High     -- High impact transitions
    | (orig == G && new == C) || (orig == C && new == G) = Medium   -- Medium impact
    | (orig == A && new == G) || (orig == G && new == A) = Low      -- Conservative changes
    | (orig == C && new == T) || (orig == T && new == C) = Low      -- Common mutations
    | otherwise = Medium                                             -- Default

-- | Classify overall risk based on numerical score
-- Demonstrates: Guards, threshold-based classification
classifyRisk :: Double -> RiskLevel
classifyRisk score
    | score > 25.0 = Critical
    | score > 15.0 = High
    | score > 8.0  = Medium
    | score > 3.0  = Low
    | otherwise    = Benign

-- | Comprehensive patient analysis function
-- Demonstrates: Function composition, pure functional pipeline
analyzePatient :: DNA -> Patient -> AnalysisReport
analyzePatient reference patient = 
    let mutations = diff reference (dnaSequence patient)
        risk = riskScore mutations
        protein = translateToProtein (dnaSequence patient)
    in (patientId patient, mutations, risk, protein)

-- | Translate DNA sequence to protein (simplified genetic code)
-- Demonstrates: List processing, chunking, mapping biological processes
-- Note: This is a simplified version of the actual genetic code
translateToProtein :: DNA -> Protein
translateToProtein dna = map translateCodon (chunksOf3 dna)
  where
    -- Split DNA into codons (groups of 3 bases)
    chunksOf3 :: [a] -> [[a]]
    chunksOf3 [] = []
    chunksOf3 [x] = [[x]]           -- Handle incomplete codon
    chunksOf3 [x,y] = [[x,y]]       -- Handle incomplete codon
    chunksOf3 (x:y:z:rest) = [x,y,z] : chunksOf3 rest
    
    -- Simplified codon to amino acid translation
    -- In reality, this uses a 64-codon genetic code table
    translateCodon :: [Base] -> AminoAcid
    translateCodon [A,T,G] = Met    -- Start codon
    translateCodon [T,A,A] = STOP   -- Stop codon
    translateCodon [T,A,G] = STOP   -- Stop codon
    translateCodon [T,G,A] = STOP   -- Stop codon
    translateCodon [G,C,_] = Ala    -- GC* codes for Alanine
    translateCodon [T,T,T] = Phe    -- TTT codes for Phenylalanine
    translateCodon [T,T,C] = Phe    -- TTC codes for Phenylalanine
    translateCodon _       = Gly    -- Default to Glycine
    baseScore T A = 15.0
    baseScore C G = 5.0   -- Medium impact
    baseScore G C = 5.0
    baseScore A C = 10.0
    baseScore A G = 8.0
    baseScore T C = 12.0
    baseScore T G = 10.0
    baseScore C A = 10.0
    baseScore C T = 12.0
    baseScore G A = 8.0
    baseScore G T = 10.0
    baseScore _ _ = 7.0    -- Default
    
    severityMultiplier Critical = 5.0
    severityMultiplier High     = 3.0
    severityMultiplier Medium   = 2.0
    severityMultiplier Low      = 1.0
    severityMultiplier Benign   = 0.5

-- [Task 2.1] Determine mutation severity based on base change
determineSeverity :: Base -> Base -> RiskLevel
determineSeverity A T = High     -- Purine to Pyrimidine
determineSeverity T A = High
determineSeverity C G = Medium   -- Pyrimidine switch
determineSeverity G C = Medium
determineSeverity A C = Critical -- Cross-category changes
determineSeverity A G = Low      -- Purine switch
determineSeverity T C = Critical
determineSeverity T G = High
determineSeverity C A = Critical
determineSeverity C T = High
determineSeverity G A = Low
determineSeverity G T = High
determineSeverity _ _ = Benign

-- [Task 3.1] Complete patient analysis
analyzePatient :: DNA -> Patient -> AnalysisReport
analyzePatient reference patient = 
    let mutations = diff reference (dnaSequence patient)
        risk = riskScore mutations
        protein = translateToProtein (dnaSequence patient)
    in (patientId patient, mutations, risk, protein)

-- [Task 2.1 Advanced] Genetic code translation
translateToProtein :: DNA -> Protein
translateToProtein dna = map translateCodon (codons dna)
  where
    codons [] = []
    codons [_] = []
    codons [_, _] = []
    codons (a:b:c:rest) = [a,b,c] : codons rest
    
    translateCodon [T,T,T] = Phe
    translateCodon [T,T,C] = Phe
    translateCodon [T,T,A] = Leu
    translateCodon [T,T,G] = Leu
    translateCodon [T,C,T] = Ser
    translateCodon [T,C,C] = Ser
    translateCodon [T,C,A] = Ser
    translateCodon [T,C,G] = Ser
    translateCodon [T,A,T] = Tyr
    translateCodon [T,A,C] = Tyr
    translateCodon [T,A,A] = STOP
    translateCodon [T,A,G] = STOP
    translateCodon [T,G,T] = Cys
    translateCodon [T,G,C] = Cys
    translateCodon [T,G,A] = STOP
    translateCodon [T,G,G] = Trp
    -- Add more codons as needed
    translateCodon _ = Ala  -- Default for incomplete genetic code

-- [Task 3.2] Risk classification
classifyRisk :: Double -> RiskLevel
classifyRisk score
  | score >= 50.0 = Critical
  | score >= 30.0 = High
  | score >= 15.0 = Medium
  | score >= 5.0  = Low
  | otherwise     = Benign