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
                styleHeader,
                "<h1>🧬 Genome Matcher Dashboard</h1>",
                "<p>Welcome to the Advanced Variant Screening Tool.</p>",
                "<div style='margin-top: 20px;'>",
                "<a class='btn' href='/analyze'>Run Analysis</a>",
                "</div>"
                ]

        -- [Task 3.3] Route Analyze: Trigger Logic
        get "/analyze" $ do
            -- [Task 3.5] Integration: Call pure functions from Processing.hs
            let results = map (analyzePatient ref) db
            
            html $ mconcat [
                styleHeader,
                "<h1>Analysis Results</h1>",
                "<div class='container'>",
                "<ul>",
                mconcat (map resultToHtml results),
                "</ul>",
                "</div>",
                "<a class='btn' href='/'>Back to Dashboard</a>"
                ]

-- [Task 3.4] HTML Helper: Convert Report to HTML list item
-- [Task 3.7] ADVANCED: Protein Display added to HTML
resultToHtml :: AnalysisReport -> Text
resultToHtml (pid, muts, score, prot) = 
    pack $ "<li class='card'>" ++
           "<h2>Patient File: " ++ pid ++ "</h2>" ++
           "<div class='stats'>" ++
           "<p><b>Mutations Found:</b> " ++ show (length muts) ++ "</p>" ++
           "<p><b>Risk Score:</b> " ++ show score ++ "</p>" ++
           "</div>" ++
           "<div class='protein-box'>" ++
           "<p><b>Synthesized Protein Chain:</b></p>" ++
           "<p class='protein'>" ++ show prot ++ "</p>" ++
           "</div>" ++
           "</li>"

-- [Task 3.6] Styling: Simple CSS
styleHeader :: Text
styleHeader = "<style>" ++
              "body { font-family: 'Segoe UI', sans-serif; background: #f4f4f9; padding: 40px; color: #333; }" ++
              "h1 { color: #2c3e50; text-align: center; }" ++
              ".container { max-width: 800px; margin: 0 auto; }" ++
              ".card { background: white; padding: 20px; margin: 20px 0; border-radius: 8px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); list-style: none; }" ++
              ".btn { display: inline-block; padding: 12px 24px; background: #3498db; color: white; text-decoration: none; border-radius: 5px; font-weight: bold; transition: background 0.3s; }" ++
              ".btn:hover { background: #2980b9; }" ++
              ".protein-box { background: #2c3e50; color: #ecf0f1; padding: 10px; border-radius: 4px; margin-top: 10px; }" ++
              ".protein { font-family: 'Courier New', monospace; letter-spacing: 1px; color: #e74c3c; font-weight: bold; }" ++
              ".stats { display: flex; gap: 20px; }" ++
              "</style>"
