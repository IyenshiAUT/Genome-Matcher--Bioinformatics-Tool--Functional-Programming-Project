{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE BangPatterns #-}

module Main (main) where

import Web.Scotty
import DataTypes
import Processing (analyzePatient, analyzeMultiplePatients)
import Utils (parseDNAString)
import Data.Text.Lazy (pack, Text)
import qualified Data.Text as T
import Control.Exception (try, SomeException, evaluate)
import Network.Wai.Middleware.Cors (simpleCors)
import Data.Aeson (Value(..), decode)
import qualified Data.Aeson.KeyMap as KM
import qualified Data.Vector as V
import System.CPUTime (getCPUTime)
import Text.Printf (printf)
import GHC.Conc (numCapabilities)

main :: IO ()
main = do
    putStrLn "Starting Genome Web Server on http://localhost:3000..."
    startServer

startServer :: IO ()
startServer = scotty 3000 $ do
    middleware simpleCors
    
    -- Route to display the main page with upload forms
    get "/" $ do
        html $ mconcat [
            styleHeader,
            "<div class='header-banner'>",
            "  <div class='dna-helix'>🧬</div>",
            "  <h1>Genome Matcher</h1>",
            "  <p class='subtitle'>Advanced Bioinformatics DNA Analysis Tool</p>",
            "</div>",
            "<div class='main-container'>",
            "<div class='upload-section'>",
            "  <div class='upload-box reference-box'>",
            "    <div class='box-header'>",
            "      <span class='step-number'>1</span>",
            "      <h3>Reference DNA File</h3>",
            "    </div>",
            "    <div class='file-input-wrapper'>",
            "      <input type='file' id='reference' accept='.txt,.fasta,.fa' class='file-input'>",
            "      <label for='reference' class='file-label'>📁 Choose Reference File</label>",
            "    </div>",
            "    <textarea id='refContent' placeholder='Reference DNA sequence will appear here...' class='dna-textarea' readonly></textarea>",
            "  </div>",
            "  <div class='upload-box patient-box'>",
            "    <div class='box-header'>",
            "      <span class='step-number'>2</span>",
            "      <h3>Patient DNA Files</h3>",
            "    </div>",
            "    <div class='file-input-wrapper'>",
            "      <input type='file' id='patients' accept='.txt,.fasta,.fa' multiple class='file-input'>",
            "      <label for='patients' class='file-label'>📁 Choose Patient Files (Multiple)</label>",
            "    </div>",
            "    <div id='patientFiles' class='patient-files-container'></div>",
            "  </div>",
            "</div>",
            "<div class='action-section'>",
            "  <div class='mode-toggle'>",
            "    <label class='toggle-label'>",
            "      <input type='checkbox' id='parallelMode' class='mode-checkbox'>",
            "      <span class='toggle-slider'></span>",
            "      <span class='toggle-text'>🚀 Parallel Processing (Multi-Core)</span>",
            "    </label>",
            "  </div>",
            "  <button onclick='analyzeFiles()' class='btn analyze-btn'>",
            "    <span class='btn-icon'>🔬</span>",
            "    <span>Analyze DNA Sequences</span>",
            "  </button>",
            "</div>",
            "<div id='results'></div>",
            "</div>",
            "<script>",
            "window.fileNames = [];",
            "function readFile(input, targetId) {",
            "  const file = input.files[0];",
            "  if (file) {",
            "    const reader = new FileReader();",
            "    reader.onload = function(e) {",
            "      document.getElementById(targetId).value = e.target.result;",
            "    };",
            "    reader.readAsText(file);",
            "  }",
            "}",
            "function readFiles(input) {",
            "  const container = document.getElementById('patientFiles');",
            "  container.innerHTML = '';",
            "  window.fileNames = [];",
            "  Array.from(input.files).forEach((file, index) => {",
            "    window.fileNames[index] = file.name;",
            "    const div = document.createElement('div');",
            "    div.innerHTML = `<h4>${file.name}</h4><textarea id='patient${index}' style='width: 100%; height: 60px;'></textarea>`;",
            "    container.appendChild(div);",
            "    const reader = new FileReader();",
            "    reader.onload = function(e) {",
            "      document.getElementById(`patient${index}`).value = e.target.result;",
            "    };",
            "    reader.readAsText(file);",
            "  });",
            "}",
            "function analyzeFiles() {",
            "  const refContent = document.getElementById('refContent').value;",
            "  const container = document.getElementById('patientFiles');",
            "  const patientTextareas = container.querySelectorAll('[id^=\"patient\"]');",
            "  console.log('Found', patientTextareas.length, 'patient textareas in container');",
            "  const patients = [];",
            "  patientTextareas.forEach((textarea) => {",
            "    const textareaId = parseInt(textarea.id.replace('patient', ''));",
            "    console.log('Processing textarea', textarea.id, 'with content length:', textarea.value?.length);",
            "    if (textarea.value && textarea.value.trim()) {",
            "      const fileName = window.fileNames && window.fileNames[textareaId] ? window.fileNames[textareaId] : `Patient ${textareaId+1}`;",
            "      console.log('Adding patient:', fileName);",
            "      patients.push({name: fileName, content: textarea.value.trim()});",
            "    }",
            "  });",
            "  console.log('Sending', patients.length, 'patients to analyze');",
            "  const parallelMode = document.getElementById('parallelMode').checked;",
            "  const endpoint = parallelMode ? '/analyze-batch' : '/analyze';",
            "  console.log('Using endpoint:', endpoint, '(Parallel:', parallelMode, ')');",
            "  fetch(endpoint, {",
            "    method: 'POST',",
            "    headers: {'Content-Type': 'application/json'},",
            "    body: JSON.stringify({reference: refContent, patients: patients})",
            "  }).then(response => response.text())",
            "    .then(html => document.getElementById('results').innerHTML = html)",
            "    .catch(error => document.getElementById('results').innerHTML = 'Error: ' + error);",
            "}",
            "console.log('Script executing...');",
            "function setupEventListeners() {",
            "  console.log('Setting up event listeners...');",
            "  const refInput = document.getElementById('reference');",
            "  const patientsInput = document.getElementById('patients');",
            "  if (refInput) {",
            "    console.log('Found reference input, adding listener');",
            "    refInput.addEventListener('change', function() {",
            "      console.log('Reference file input changed');",
            "      readFile(this, 'refContent');",
            "    });",
            "  } else {",
            "    console.error('Could not find reference input element');",
            "  }",
            "  if (patientsInput) {",
            "    console.log('Found patients input, adding listener');",
            "    patientsInput.addEventListener('change', function() {",
            "      console.log('Patient files input changed');",
            "      readFiles(this);",
            "    });",
            "  } else {",
            "    console.error('Could not find patients input element');",
            "  }",
            "}",
            "if (document.readyState === 'loading') {",
            "  document.addEventListener('DOMContentLoaded', setupEventListeners);",
            "} else {",
            "  setupEventListeners();",
            "}",
            "window.addEventListener('load', setupEventListeners);",
            "</script>"
            ]

    -- Route to handle JSON-based analysis (no file uploads)
    post "/analyze" $ do
        bodyData <- body
        case decode bodyData of
            Nothing -> html "<h1>Error: Invalid JSON data</h1>"
            Just jsonVal -> do
                result <- liftIO $ try $ do
                    let refContent = case jsonVal of
                            Object obj -> case KM.lookup "reference" obj of
                                Just (String txt) -> T.unpack txt
                                _ -> ""
                            _ -> ""
                    
                    let patientsData = case jsonVal of
                            Object obj -> case KM.lookup "patients" obj of
                                Just (Array arr) -> map extractPatient $ V.toList arr
                                _ -> []
                            _ -> []
                    
                    _ <- evaluate refContent
                    refDNA <- evaluate $ parseDNAString refContent
                    
                    patientResults <- mapM (\(name, content) -> do
                        pDNA <- evaluate $ parseDNAString content
                        evaluate (name, pDNA)
                        ) patientsData
                    
                    results <- evaluate $ map (analyzePatient refDNA) patientResults
                    return results

                case (result :: Either SomeException [AnalysisReport]) of
                    Left e -> html $ pack $ "<h1>Error during analysis: " ++ show e ++ "</h1>"
                    Right results -> 
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
    
    -- Batch analysis with parallel processing
    post "/analyze-batch" $ do
        bodyData <- body
        case decode bodyData of
            Nothing -> html "<h1>Error: Invalid JSON data</h1>"
            Just jsonVal -> do
                result <- liftIO $ try $ do
                    let refContent = case jsonVal of
                            Object obj -> case KM.lookup "reference" obj of
                                Just (String txt) -> T.unpack txt
                                _ -> ""
                            _ -> ""
                    
                    let patientsData = case jsonVal of
                            Object obj -> case KM.lookup "patients" obj of
                                Just (Array arr) -> map extractPatient $ V.toList arr
                                _ -> []
                            _ -> []
                    
                    _ <- evaluate refContent
                    refDNA <- evaluate $ parseDNAString refContent
                    
                    -- Create patient data pairs
                    patientDataList <- mapM (\(name, content) -> do
                        pDNA <- evaluate $ parseDNAString content
                        return (name, pDNA)
                        ) patientsData
                    
                    -- Get CPU count
                    cores <- return numCapabilities
                    
                    -- Measure parallel execution time
                    startTime <- getCPUTime
                    
                    -- PARALLEL PROCESSING: Use all CPU cores with parMap
                    let results = analyzeMultiplePatients refDNA patientDataList
                    _ <- evaluate results
                    
                    endTime <- getCPUTime
                    let timeDiff = fromIntegral (endTime - startTime) / 1000000000000 :: Double
                    
                    return (results, cores, timeDiff)

                case (result :: Either SomeException ([AnalysisReport], Int, Double)) of
                    Left e -> html $ pack $ "<h1>Error during analysis: " ++ show e ++ "</h1>"
                    Right (results, cores, execTime) -> 
                        html $ mconcat [
                            styleHeader,
                            "<h1>🚀 Parallel Batch Analysis Results</h1>",
                            "<div class='batch-info'>",
                            "<p class='info-text'>✨ Processed <strong>", pack (show (length results)), 
                            " patients</strong> using <strong>parallel processing</strong> across ", 
                            pack (show cores), " CPU cores</p>",
                            "<p class='perf-text'>⚡ Execution Time: <strong>", 
                            pack (printf "%.4f" execTime), " seconds</strong></p>",
                            "<p class='algo-text'>🔬 Algorithm: <code>parMap rdeepseq (analyzePatient refDNA) patients</code></p>",
                            "</div>",
                            "</div>",
                            "<div class='container'>",
                            "<ul>",
                            mconcat (map resultToHtml results),
                            "</ul>",
                            "</div>",
                            "<a class='btn' href='/'>Back to Dashboard</a>"
                            ]
  where
    extractPatient (Object obj) = 
        let name = case KM.lookup "name" obj of
                Just (String txt) -> T.unpack txt
                _ -> "unknown"
            content = case KM.lookup "content" obj of
                Just (String txt) -> T.unpack txt
                _ -> ""
        in (name, content)
    extractPatient _ = ("unknown", "")

-- ... (rest of the file remains the same)
-- HTML Helper: Convert Report to HTML list item
-- Protein Display added to HTML with enhanced statistics
resultToHtml :: AnalysisReport -> Text
resultToHtml (pid, muts, riskScore, prot) = 
    let
        mutCount = length muts
        criticalMuts = length $ filter (\m -> severity m == Critical) muts
        highMuts = length $ filter (\m -> severity m == High) muts
        riskCategory = if riskScore > 100 then "🔴 Critical" 
                       else if riskScore > 50 then "🟠 High"
                       else if riskScore > 20 then "🟡 Medium"
                       else "🟢 Low"
    in pack $ "<li class='card'>" ++
           "<div class='card-header'>" ++
           "<h2>🧬 " ++ pid ++ "</h2>" ++
           "<div class='risk-badge " ++ (if riskScore > 50 then "high-risk" else "low-risk") ++ "'>" ++ riskCategory ++ "</div>" ++
           "</div>" ++
           
           -- Main Statistics Grid
           "<div class='stats-grid'>" ++
           "<div class='stat-item'>" ++
           "<span class='stat-label'>🧬 Total Mutations</span>" ++
           "<span class='stat-value'>" ++ show mutCount ++ "</span>" ++
           "</div>" ++
           "<div class='stat-item'>" ++
           "<span class='stat-label'>⚠️ Risk Score</span>" ++
           "<span class='stat-value risk-score'>" ++ show riskScore ++ "</span>" ++
           "</div>" ++
           "<div class='stat-item'>" ++
           "<span class='stat-label'>🔴 Critical</span>" ++
           "<span class='stat-value critical-count'>" ++ show criticalMuts ++ "</span>" ++
           "</div>" ++
           "<div class='stat-item'>" ++
           "<span class='stat-label'>🟠 High Risk</span>" ++
           "<span class='stat-value high-count'>" ++ show highMuts ++ "</span>" ++
           "</div>" ++
           "</div>" ++
           
           -- Mutation Details Table
           (if mutCount > 0 then
           "<div class='mutation-details'>" ++
           "<h3>📊 Mutation Details</h3>" ++
           "<table class='mutation-table'>" ++
           "<tr><th>Position</th><th>Change</th><th>Severity</th><th>Type</th></tr>" ++
           concatMap formatMutation (take 10 muts) ++
           (if mutCount > 10 then "<tr><td colspan='4' class='more-mutations'>... and " ++ show (mutCount - 10) ++ " more mutations</td></tr>" else "") ++
           "</table>" ++
           "</div>"
           else "") ++
           
           -- Protein Section
           "<div class='protein-section'>" ++
           "<h3>🧪 Synthesized Protein Chain (" ++ show (length prot) ++ " amino acids)</h3>" ++
           "<div class='protein-chain'>" ++ formatProtein prot ++ "</div>" ++
           "</div>" ++
           
           -- Clinical Insights
           "<div class='clinical-insights'>" ++
           "<h3>💡 Clinical Insights</h3>" ++
           "<div class='insights-content'>" ++
           generateInsights riskScore mutCount criticalMuts highMuts ++
           "</div>" ++
           "</div>" ++
           
           "</li>"
  where
    formatProtein [] = "<span class='empty-protein'>No proteins synthesized</span>"
    formatProtein prots = concatMap formatAminoAcid prots
    formatAminoAcid amino = 
        let color = case amino of
                Met -> "amino-start"    -- Start codon
                STOP -> "amino-stop"    -- Stop codon
                _ -> "amino-acid"
        in "<span class='" ++ color ++ "'>" ++ show amino ++ "</span>"
    
    formatMutation m = 
        "<tr>" ++
        "<td>" ++ show (position m) ++ "</td>" ++
        "<td>" ++ show (original m) ++ " → " ++ show (current m) ++ "</td>" ++
        "<td><span class='severity-badge " ++ severityClass (severity m) ++ "'>" ++ show (severity m) ++ "</span></td>" ++
        "<td>Substitution</td>" ++
        "</tr>"
    
    severityClass Critical = "sev-critical"
    severityClass High = "sev-high"
    severityClass Medium = "sev-medium"
    severityClass Low = "sev-low"
    severityClass Benign = "sev-benign"
    
    generateInsights score mutCount critical high
        | score > 100 = 
            "<div class='insight critical-insight'>" ++
            "<strong>⚠️ Critical Risk Detected:</strong> " ++ show critical ++ " critical mutations found. " ++
            "Immediate genetic counseling and clinical follow-up recommended." ++
            "</div>"
        | score > 50 = 
            "<div class='insight high-insight'>" ++
            "<strong>🟠 Elevated Risk:</strong> " ++ show (critical + high) ++ " significant mutations detected. " ++
            "Regular monitoring and preventive care advised." ++
            "</div>"
        | score > 20 =
            "<div class='insight medium-insight'>" ++
            "<strong>🟡 Moderate Findings:</strong> " ++ show mutCount ++ " mutations detected with moderate risk. " ++
            "Standard screening protocols recommended." ++
            "</div>"
        | otherwise =
            "<div class='insight low-insight'>" ++
            "<strong>🟢 Low Risk Profile:</strong> Genetic profile shows minimal concerning variations. " ++
            "Routine health maintenance sufficient." ++
            "</div>"

-- [Task 3.6] Styling: Simple CSS
styleHeader :: Text
styleHeader = pack $ "<style>" ++
              "* { margin: 0; padding: 0; box-sizing: border-box; }" ++
              "body { font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); min-height: 100vh; padding: 0; color: #333; }" ++
              "@keyframes fadeIn { from { opacity: 0; transform: translateY(20px); } to { opacity: 1; transform: translateY(0); } }" ++
              "@keyframes pulse { 0%, 100% { transform: scale(1); } 50% { transform: scale(1.05); } }" ++
              "@keyframes rotate { from { transform: rotate(0deg); } to { transform: rotate(360deg); } }" ++
              ".header-banner { background: rgba(255,255,255,0.1); backdrop-filter: blur(10px); padding: 40px 20px; text-align: center; border-bottom: 3px solid rgba(255,255,255,0.2); animation: fadeIn 0.6s ease-out; }" ++
              ".dna-helix { font-size: 4em; margin-bottom: 10px; animation: rotate 3s linear infinite; display: inline-block; }" ++
              "h1 { color: white; font-size: 2.5em; font-weight: 700; text-shadow: 2px 2px 8px rgba(0,0,0,0.3); margin-bottom: 10px; letter-spacing: 1px; }" ++
              ".subtitle { color: rgba(255,255,255,0.95); font-size: 1.1em; font-weight: 300; }" ++
              ".main-container { max-width: 1200px; margin: 0 auto; padding: 40px 20px; }" ++
              ".upload-section { display: grid; grid-template-columns: 1fr 1fr; gap: 30px; margin-bottom: 30px; }" ++
              "@media (max-width: 768px) { .upload-section { grid-template-columns: 1fr; } }" ++
              ".upload-box { background: white; padding: 30px; border-radius: 16px; box-shadow: 0 10px 30px rgba(0,0,0,0.15); animation: fadeIn 0.8s ease-out; transition: transform 0.3s, box-shadow 0.3s; }" ++
              ".upload-box:hover { transform: translateY(-5px); box-shadow: 0 15px 40px rgba(0,0,0,0.2); }" ++
              ".reference-box { border-top: 4px solid #3498db; }" ++
              ".patient-box { border-top: 4px solid #e74c3c; }" ++
              ".box-header { display: flex; align-items: center; gap: 15px; margin-bottom: 20px; }" ++
              ".step-number { background: linear-gradient(135deg, #667eea, #764ba2); color: white; width: 40px; height: 40px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight: bold; font-size: 1.2em; }" ++
              ".box-header h3 { color: #2c3e50; font-size: 1.3em; font-weight: 600; }" ++
              ".file-input-wrapper { position: relative; margin-bottom: 15px; }" ++
              ".file-input { opacity: 0; position: absolute; z-index: -1; }" ++
              ".file-label { display: block; padding: 15px 20px; background: linear-gradient(135deg, #667eea, #764ba2); color: white; border-radius: 10px; text-align: center; cursor: pointer; transition: all 0.3s; font-weight: 500; }" ++
              ".file-label:hover { transform: scale(1.02); box-shadow: 0 5px 15px rgba(102, 126, 234, 0.4); }" ++
              ".dna-textarea { width: 100%; height: 120px; border: 2px solid #e9ecef; border-radius: 8px; padding: 12px; font-family: 'Courier New', monospace; font-size: 0.9em; resize: vertical; transition: border-color 0.3s; background: #f8f9fa; }" ++
              ".dna-textarea:focus { border-color: #667eea; outline: none; box-shadow: 0 0 10px rgba(102, 126, 234, 0.2); }" ++
              ".patient-files-container { margin-top: 15px; }" ++
              ".patient-files-container > div { background: #f8f9fa; padding: 15px; border-radius: 8px; margin-bottom: 10px; border-left: 3px solid #e74c3c; }" ++
              ".patient-files-container h4 { color: #2c3e50; margin-bottom: 10px; font-size: 1em; }" ++
              ".patient-files-container textarea { height: 80px; background: white; }" ++
              ".action-section { text-align: center; margin: 40px 0; }" ++
              
              -- Toggle Switch CSS
              ".mode-toggle { margin-bottom: 20px; display: flex; justify-content: center; }" ++
              ".toggle-label { display: flex; align-items: center; gap: 15px; cursor: pointer; background: white; padding: 15px 25px; border-radius: 50px; box-shadow: 0 5px 15px rgba(0,0,0,0.1); transition: all 0.3s; }" ++
              ".toggle-label:hover { box-shadow: 0 8px 20px rgba(0,0,0,0.15); transform: translateY(-2px); }" ++
              ".mode-checkbox { display: none; }" ++
              ".toggle-slider { width: 50px; height: 26px; background: #ccc; border-radius: 34px; position: relative; transition: 0.3s; }" ++
              ".toggle-slider::before { content: ''; position: absolute; height: 20px; width: 20px; left: 3px; bottom: 3px; background: white; border-radius: 50%; transition: 0.3s; }" ++
              ".mode-checkbox:checked + .toggle-slider { background: linear-gradient(135deg, #667eea, #764ba2); }" ++
              ".mode-checkbox:checked + .toggle-slider::before { transform: translateX(24px); }" ++
              ".toggle-text { font-weight: 600; color: #2c3e50; font-size: 1.05em; }" ++
              
              ".batch-info { text-align: center; background: rgba(255,255,255,0.2); backdrop-filter: blur(10px); padding: 25px; border-radius: 12px; margin-bottom: 30px; border: 2px solid rgba(255,255,255,0.3); }" ++
              ".info-text { color: white; font-size: 1.3em; font-weight: 500; margin-bottom: 12px; }" ++
              ".perf-text { color: #ffeb3b; font-size: 1.2em; font-weight: 600; margin-bottom: 10px; text-shadow: 0 2px 4px rgba(0,0,0,0.3); }" ++
              ".algo-text { color: rgba(255,255,255,0.9); font-size: 1em; margin-top: 10px; }" ++
              ".algo-text code { background: rgba(0,0,0,0.3); padding: 5px 12px; border-radius: 6px; font-family: 'Courier New', monospace; color: #4fc3f7; font-weight: 600; }" ++
              
              ".analyze-btn { display: inline-flex; align-items: center; gap: 12px; padding: 18px 40px; background: linear-gradient(135deg, #667eea, #764ba2); color: white; border: none; border-radius: 50px; font-size: 1.2em; font-weight: 600; cursor: pointer; transition: all 0.3s; box-shadow: 0 8px 20px rgba(102, 126, 234, 0.3); }" ++
              ".analyze-btn:hover { transform: translateY(-3px); box-shadow: 0 12px 30px rgba(102, 126, 234, 0.5); animation: pulse 1s infinite; }" ++
              ".analyze-btn:active { transform: translateY(-1px); }" ++
              ".btn-icon { font-size: 1.3em; }" ++
              "#results { margin-top: 50px; }" ++
              "#results h1 { color: white; font-size: 2em; margin-bottom: 30px; text-align: center; }" ++
              ".container { max-width: 1200px; margin: 0 auto; }" ++
              ".card { background: white; padding: 30px; margin: 20px 0; border-radius: 16px; box-shadow: 0 10px 30px rgba(0,0,0,0.15); list-style: none; border-left: 6px solid #3498db; animation: fadeIn 0.6s ease-out; transition: transform 0.3s; }" ++
              ".card:hover { transform: translateX(5px); }" ++
              ".card-header h2 { margin: 0 0 20px 0; color: #2c3e50; font-size: 1.6em; font-weight: 700; }" ++
              ".stats-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin: 25px 0; }" ++
              ".stat-item { background: linear-gradient(135deg, #f8f9fa, #e9ecef); padding: 20px; border-radius: 12px; display: flex; justify-content: space-between; align-items: center; transition: transform 0.2s; }" ++
              ".stat-item:hover { transform: scale(1.03); }" ++
              ".stat-label { font-weight: 600; color: #495057; font-size: 1em; }" ++
              ".stat-value { font-weight: bold; font-size: 1.5em; color: #667eea; }" ++
              ".protein-section { margin-top: 25px; background: #f8f9fa; padding: 20px; border-radius: 12px; }" ++
              ".protein-section h3 { color: #2c3e50; margin-bottom: 15px; font-size: 1.2em; font-weight: 600; }" ++
              ".protein-chain { background: linear-gradient(135deg, #2c3e50, #34495e); color: #ecf0f1; padding: 20px; border-radius: 10px; min-height: 60px; display: flex; flex-wrap: wrap; gap: 8px; align-items: center; }" ++
              ".amino-acid { background: linear-gradient(135deg, #e74c3c, #c0392b); color: white; padding: 6px 12px; border-radius: 6px; font-family: 'Courier New', monospace; font-size: 0.95em; font-weight: bold; box-shadow: 0 2px 5px rgba(0,0,0,0.2); transition: transform 0.2s; }" ++
              ".amino-acid:hover { transform: scale(1.1); }" ++
              ".empty-protein { color: #95a5a6; font-style: italic; }" ++
              ".btn { display: inline-block; padding: 15px 30px; background: linear-gradient(135deg, #667eea, #764ba2); color: white; text-decoration: none; border-radius: 50px; font-weight: 600; transition: all 0.3s; border: none; cursor: pointer; margin-top: 30px; font-size: 1.1em; box-shadow: 0 5px 15px rgba(102, 126, 234, 0.3); }" ++
              ".btn:hover { transform: translateY(-2px); box-shadow: 0 8px 20px rgba(102, 126, 234, 0.5); }" ++
              
              -- Advanced Features CSS
              ".card-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; }" ++
              ".risk-badge { padding: 8px 16px; border-radius: 20px; font-size: 0.9em; font-weight: 600; }" ++
              ".high-risk { background: linear-gradient(135deg, #e74c3c, #c0392b); color: white; }" ++
              ".low-risk { background: linear-gradient(135deg, #27ae60, #229954); color: white; }" ++
              
              ".stats-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 15px; margin: 25px 0; }" ++
              ".critical-count { color: #e74c3c !important; }" ++
              ".high-count { color: #f39c12 !important; }" ++
              ".risk-score { color: #667eea !important; font-size: 1.8em !important; }" ++
              
              ".mutation-details { margin-top: 25px; background: #f8f9fa; padding: 20px; border-radius: 12px; }" ++
              ".mutation-details h3 { color: #2c3e50; margin-bottom: 15px; font-size: 1.2em; }" ++
              ".mutation-table { width: 100%; border-collapse: collapse; background: white; border-radius: 8px; overflow: hidden; }" ++
              ".mutation-table th { background: linear-gradient(135deg, #667eea, #764ba2); color: white; padding: 12px; text-align: left; font-weight: 600; }" ++
              ".mutation-table td { padding: 10px 12px; border-bottom: 1px solid #e9ecef; }" ++
              ".mutation-table tr:hover { background: #f8f9fa; }" ++
              ".more-mutations { text-align: center; font-style: italic; color: #6c757d; background: #f8f9fa !important; }" ++
              
              ".severity-badge { padding: 4px 12px; border-radius: 12px; font-size: 0.85em; font-weight: 600; }" ++
              ".sev-critical { background: #e74c3c; color: white; }" ++
              ".sev-high { background: #f39c12; color: white; }" ++
              ".sev-medium { background: #f1c40f; color: #333; }" ++
              ".sev-low { background: #3498db; color: white; }" ++
              ".sev-benign { background: #27ae60; color: white; }" ++
              
              ".amino-start { background: linear-gradient(135deg, #27ae60, #229954); color: white; padding: 6px 12px; border-radius: 6px; font-family: 'Courier New', monospace; font-size: 0.95em; font-weight: bold; box-shadow: 0 2px 5px rgba(0,0,0,0.2); }" ++
              ".amino-stop { background: linear-gradient(135deg, #e74c3c, #c0392b); color: white; padding: 6px 12px; border-radius: 6px; font-family: 'Courier New', monospace; font-size: 0.95em; font-weight: bold; box-shadow: 0 2px 5px rgba(0,0,0,0.2); }" ++
              
              ".clinical-insights { margin-top: 25px; }" ++
              ".clinical-insights h3 { color: #2c3e50; margin-bottom: 15px; font-size: 1.2em; font-weight: 600; }" ++
              ".insights-content { background: white; padding: 20px; border-radius: 12px; border-left: 4px solid #667eea; }" ++
              ".insight { padding: 15px; border-radius: 8px; margin-bottom: 10px; }" ++
              ".critical-insight { background: linear-gradient(135deg, #fee, #fdd); border-left: 4px solid #e74c3c; }" ++
              ".high-insight { background: linear-gradient(135deg, #fff4e5, #ffe8cc); border-left: 4px solid #f39c12; }" ++
              ".medium-insight { background: linear-gradient(135deg, #fffbea, #fff9db); border-left: 4px solid #f1c40f; }" ++
              ".low-insight { background: linear-gradient(135deg, #e8f8f5, #d4efdf); border-left: 4px solid #27ae60; }" ++
              ".insight strong { display: block; margin-bottom: 8px; font-size: 1.05em; }" ++
              
              "</style>"