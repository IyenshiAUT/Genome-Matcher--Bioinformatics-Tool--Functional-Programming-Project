module Processing (
    analyzePatient,
    findMutations,
    calculateRiskScore,
    visualizeDiff,
    dnaToProtein,
    analyzeMutationImpact,
    calculateMutationRate,
    classifyMutationType,
    getGeneRegion,
    generateClinicalReport
) where

import DataTypes

-- [Task 1.1] Define Type Signatures
-- The main pipeline function integrating all steps
analyzePatient :: DNA -> (String, DNA) -> AnalysisReport
analyzePatient refGenome (pid, pDna) =
    let
        -- [Task 1.2] Step 1: Find mutations (Recursion)
        muts = findMutations refGenome pDna
        -- [Task 1.4] Step 2: Calculate risk (Foldl)
        score = calculateRiskScore muts
        -- [Task 1.7] Step 3 (ADVANCED): Translate DNA to Protein
        prot = dnaToProtein pDna
    in
        (pid, muts, score, prot)

-- [Task 1.7] ADVANCED: Protein Translation Logic
-- Recursively processes the DNA list in chunks of 3 (Codons)
dnaToProtein :: DNA -> Protein
dnaToProtein [] = []
dnaToProtein (b1:b2:b3:rest) = codonLookup (b1, b2, b3) : dnaToProtein rest
dnaToProtein _ = [] -- Ignore trailing incomplete codons

-- [Task 1.8] ADVANCED: Codon Table (Pattern Matching)
-- Maps triplets of Bases to Amino Acids. This is the "Genetic Code".
codonLookup :: (Base, Base, Base) -> AminoAcid
codonLookup (T, T, T) = Phe
codonLookup (T, T, C) = Phe
codonLookup (T, T, A) = Leu
codonLookup (T, T, G) = Leu
codonLookup (C, T, _) = Leu -- Wildcard matching
codonLookup (A, T, T) = Ile
codonLookup (A, T, C) = Ile
codonLookup (A, T, A) = Ile
codonLookup (A, T, G) = Met -- Start Codon
codonLookup (G, T, _) = Val
codonLookup (T, C, _) = Ser
codonLookup (C, C, _) = Pro
codonLookup (A, C, _) = Thr
codonLookup (G, C, _) = Ala
codonLookup (T, A, T) = Tyr
codonLookup (T, A, C) = Tyr
codonLookup (T, A, A) = STOP
codonLookup (T, A, G) = STOP
codonLookup (C, A, T) = His
codonLookup (C, A, C) = His
codonLookup (C, A, A) = Gln
codonLookup (C, A, G) = Gln
codonLookup (A, A, T) = Asn
codonLookup (A, A, C) = Asn
codonLookup (A, A, A) = Lys
codonLookup (A, A, G) = Lys
codonLookup (G, A, T) = Asp
codonLookup (G, A, C) = Asp
codonLookup (G, A, A) = Glu
codonLookup (G, A, G) = Glu
codonLookup (T, G, T) = Cys
codonLookup (T, G, C) = Cys
codonLookup (T, G, A) = STOP
codonLookup (T, G, G) = Trp
codonLookup (C, G, _) = Arg
codonLookup (A, G, T) = Ser
codonLookup (A, G, C) = Ser
codonLookup (A, G, A) = Arg
codonLookup (A, G, G) = Arg
codonLookup (G, G, _) = Gly

-- [Task 1.2] Implement Recursion: Compare two lists index by index
findMutations :: DNA -> DNA -> [Mutation]
findMutations ref pat = go 0 ref pat
  where
    go _ [] [] = []
    go _ [] _  = []
    go _ _  [] = []
    go i (r:rs) (p:ps)
        | r == p    = go (i+1) rs ps -- Match found, continue
        -- [Task 1.3] Risk Logic: Call assessRisk inside the loop on mismatch
        | otherwise = Mutation i r p (assessRisk i r p) : go (i+1) rs ps

-- [Task 1.3] Risk Logic: Pattern Matching for specific business rules
assessRisk :: Int -> Base -> Base -> RiskLevel
assessRisk idx ref mut
    | idx < 5            = Critical -- Mutations at start are critical
    | ref == A && mut == T = High     -- Specific A->T mutation is dangerous
    | otherwise          = Low

-- [Task 1.4] Scoring Logic: Foldl to sum up severity scores
calculateRiskScore :: [Mutation] -> Double
calculateRiskScore mutations = foldl (\acc m -> acc + riskValue (severity m)) 0.0 mutations
  where
    riskValue Critical = 20.0
    riskValue High     = 10.0
    riskValue Medium   = 5.0
    riskValue Low      = 1.0
    riskValue Benign   = 0.0

-- [Task 1.5] Visualizer: Generate string with pointers
visualizeDiff :: DNA -> DNA -> String
visualizeDiff ref pat =
    let
        refStr = concatMap show ref
        patStr = concatMap show pat
        -- Create pointers: '^' where mismatch occurs
        pointers = zipWith (\r p -> if r == p then " " else "^") ref pat
    in
        unlines ["REF: " ++ refStr, "PAT: " ++ patStr, "     " ++ concat pointers]

-- ADVANCED: Mutation Impact Analysis
analyzeMutationImpact :: Mutation -> DNA -> DNA -> MutationImpact
analyzeMutationImpact mut refDNA patDNA =
    let
        mutType = classifyMutationType mut refDNA patDNA
        region = getGeneRegion (position mut)
        protChange = getProteinChange mut refDNA patDNA
        clinical = getClinicalSignificance mut mutType
        recs = getRecommendations mut mutType clinical
    in
        MutationImpact mutType region protChange clinical recs

-- Classify mutation type based on DNA changes
classifyMutationType :: Mutation -> DNA -> DNA -> MutationType
classifyMutationType mut refDNA patDNA =
    let pos = position mut
        refCodon = getCodon pos refDNA
        patCodon = getCodon pos patDNA
        refAA = if length refCodon == 3 then codonLookup (refCodon !! 0, refCodon !! 1, refCodon !! 2) else STOP
        patAA = if length patCodon == 3 then codonLookup (patCodon !! 0, patCodon !! 1, patCodon !! 2) else STOP
    in
        if refAA == patAA then Silent
        else if patAA == STOP then Nonsense
        else if refAA /= patAA then Missense
        else Substitution

-- Get codon containing position
getCodon :: Int -> DNA -> [Base]
getCodon pos dna = 
    let codonStart = (pos `div` 3) * 3
    in take 3 $ drop codonStart dna

-- Get protein change if any
getProteinChange :: Mutation -> DNA -> DNA -> Maybe (AminoAcid, AminoAcid)
getProteinChange mut refDNA patDNA =
    let pos = position mut
        refCodon = getCodon pos refDNA
        patCodon = getCodon pos patDNA
    in if length refCodon == 3 && length patCodon == 3
       then Just (codonLookup (refCodon !! 0, refCodon !! 1, refCodon !! 2),
                  codonLookup (patCodon !! 0, patCodon !! 1, patCodon !! 2))
       else Nothing

-- Determine gene region (simplified model)
getGeneRegion :: Int -> GeneRegion
getGeneRegion pos
    | pos < 10 = Promoter        -- First 10 bases = promoter
    | pos `mod` 10 < 7 = Exon    -- 70% exons
    | otherwise = Intron          -- 30% introns

-- Get clinical significance
getClinicalSignificance :: Mutation -> MutationType -> String
getClinicalSignificance mut mutType =
    case (severity mut, mutType) of
        (Critical, Nonsense) -> "Pathogenic - High Disease Risk"
        (Critical, _) -> "Likely Pathogenic"
        (High, Nonsense) -> "Pathogenic"
        (High, Missense) -> "Likely Pathogenic"
        (Medium, _) -> "Uncertain Significance"
        (Low, Silent) -> "Benign"
        _ -> "Likely Benign"

-- Generate recommendations based on mutation
getRecommendations :: Mutation -> MutationType -> String -> [String]
getRecommendations mut mutType clinical =
    case severity mut of
        Critical -> ["Immediate genetic counseling recommended",
                     "Consider targeted therapy options",
                     "Family screening advised"]
        High -> ["Genetic counseling recommended",
                 "Regular monitoring required",
                 "Discuss preventive measures"]
        Medium -> ["Follow-up testing in 6 months",
                   "Monitor for symptoms"]
        _ -> ["Routine screening sufficient"]

-- Calculate mutation rate (mutations per base)
calculateMutationRate :: [Mutation] -> Int -> Double
calculateMutationRate mutations genomeLength =
    fromIntegral (length mutations) / fromIntegral genomeLength

-- Generate comprehensive clinical report
generateClinicalReport :: String -> [Mutation] -> Double -> Protein -> DNA -> DNA -> String
generateClinicalReport patientId muts score prot refDNA patDNA =
    let
        mutCount = length muts
        mutRate = calculateMutationRate muts (length refDNA)
        impacts = map (\m -> analyzeMutationImpact m refDNA patDNA) muts
        pathogenic = length $ filter (\i -> "Pathogenic" `isInfixOf` clinicalSignificance i) impacts
        highRisk = length $ filter (\m -> severity m >= High) muts
        
        summary = "CLINICAL GENOMICS REPORT\n" ++
                  "Patient ID: " ++ patientId ++ "\n" ++
                  "Total Mutations: " ++ show mutCount ++ "\n" ++
                  "Mutation Rate: " ++ show (mutRate * 100) ++ "%\n" ++
                  "Risk Score: " ++ show score ++ "\n" ++
                  "Pathogenic Variants: " ++ show pathogenic ++ "\n" ++
                  "High Risk Mutations: " ++ show highRisk ++ "\n" ++
                  "Protein Length: " ++ show (length prot) ++ " amino acids"
    in summary
  where
    isInfixOf needle haystack = any (== needle) (words haystack)