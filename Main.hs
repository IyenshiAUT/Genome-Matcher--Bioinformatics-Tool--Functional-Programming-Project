{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE BangPatterns #-}

module Main (main) where

import Web.Scotty
import DataTypes
import Processing (analyzePatient)
import Utils (parseDNAString)
import Data.Text.Lazy (pack, Text)
import qualified Data.Text as T
import Control.Exception (try, SomeException, evaluate)
import Network.Wai.Middleware.Cors (simpleCors)
import Data.Aeson (Value(..), decode, (.:))
import qualified Data.Aeson.KeyMap as KM
import qualified Data.Vector as V

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
            "<h1>🧬 Genome Matcher</h1>",
            "<p>Upload a reference DNA file and one or more patient DNA files to analyze.</p>",
            "<div class='upload-box'>",
            "   <h3>1. Select Reference DNA File</h3>",
            "   <input type='file' id='reference' accept='.txt,.fasta,.fa'>",
            "   <textarea id='refContent' placeholder='Reference DNA content will appear here...' style='width: 100%; height: 100px; margin-top: 10px;'></textarea>",
            "</div>",
            "<div class='upload-box'>",
            "   <h3>2. Select Patient DNA Files</h3>", 
            "   <input type='file' id='patients' accept='.txt,.fasta,.fa' multiple>",
            "   <div id='patientFiles'></div>",
            "</div>",
            "<button onclick='analyzeFiles()' class='btn'>Analyze Files</button>",
            "<div id='results'></div>",
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
            "  fetch('/analyze', {",
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
-- [Task 3.4] HTML Helper: Convert Report to HTML list item
-- [Task 3.7] ADVANCED: Protein Display added to HTML
resultToHtml :: AnalysisReport -> Text
resultToHtml (pid, muts, score, prot) = 
    pack $ "<li class='card'>" ++
           "<div class='card-header'>" ++
           "<h2>🧬 " ++ pid ++ "</h2>" ++
           "</div>" ++
           "<div class='stats-grid'>" ++
           "<div class='stat-item'>" ++
           "<span class='stat-label'>🧬 Mutations Found:</span>" ++
           "<span class='stat-value'>" ++ show (length muts) ++ "</span>" ++
           "</div>" ++
           "<div class='stat-item'>" ++
           "<span class='stat-label'>⚠️ Risk Score:</span>" ++
           "<span class='stat-value'>" ++ show score ++ "</span>" ++
           "</div>" ++
           "</div>" ++
           "<div class='protein-section'>" ++
           "<h3>🧪 Synthesized Protein Chain</h3>" ++
           "<div class='protein-chain'>" ++ formatProtein prot ++ "</div>" ++
           "</div>" ++
           "</li>"
  where
    formatProtein [] = "<span class='empty-protein'>No proteins synthesized</span>"
    formatProtein prots = concatMap formatAminoAcid prots
    formatAminoAcid amino = "<span class='amino-acid'>" ++ show amino ++ "</span>"

-- [Task 3.6] Styling: Simple CSS
styleHeader :: Text
styleHeader = pack $ "<style>" ++
              "body { font-family: 'Segoe UI', sans-serif; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); min-height: 100vh; padding: 20px; color: #333; }" ++
              "h1 { color: white; text-align: center; text-shadow: 2px 2px 4px rgba(0,0,0,0.3); margin-bottom: 30px; }" ++
              ".container { max-width: 1000px; margin: 0 auto; }" ++
              ".upload-box { background: white; padding: 25px; margin: 20px 0; border-radius: 12px; box-shadow: 0 8px 16px rgba(0,0,0,0.1); }" ++
              ".card { background: white; padding: 25px; margin: 20px 0; border-radius: 12px; box-shadow: 0 8px 16px rgba(0,0,0,0.1); list-style: none; border-left: 4px solid #3498db; }" ++
              ".card-header h2 { margin: 0 0 15px 0; color: #2c3e50; font-size: 1.4em; }" ++
              ".stats-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin: 20px 0; }" ++
              ".stat-item { background: #f8f9fa; padding: 15px; border-radius: 8px; display: flex; justify-content: space-between; align-items: center; }" ++
              ".stat-label { font-weight: 600; color: #495057; }" ++
              ".stat-value { font-weight: bold; font-size: 1.2em; color: #007bff; }" ++
              ".protein-section { margin-top: 20px; }" ++
              ".protein-section h3 { color: #495057; margin-bottom: 15px; font-size: 1.1em; }" ++
              ".protein-chain { background: #2c3e50; color: #ecf0f1; padding: 15px; border-radius: 8px; min-height: 50px; display: flex; flex-wrap: wrap; gap: 5px; align-items: center; }" ++
              ".amino-acid { background: #e74c3c; color: white; padding: 4px 8px; border-radius: 4px; font-family: 'Courier New', monospace; font-size: 0.9em; font-weight: bold; }" ++
              ".empty-protein { color: #95a5a6; font-style: italic; }" ++
              ".btn { display: inline-block; padding: 15px 30px; background: linear-gradient(45deg, #3498db, #2980b9); color: white; text-decoration: none; border-radius: 8px; font-weight: bold; transition: all 0.3s; border: none; cursor: pointer; margin-top: 20px; font-size: 1.1em; }" ++
              ".btn:hover { transform: translateY(-2px); box-shadow: 0 5px 15px rgba(52, 152, 219, 0.4); }" ++
              "textarea { border: 2px solid #e9ecef; border-radius: 6px; padding: 10px; font-family: 'Courier New', monospace; }" ++
              "textarea:focus { border-color: #3498db; outline: none; box-shadow: 0 0 5px rgba(52, 152, 219, 0.3); }" ++
              "input[type='file'] { padding: 10px; border: 2px dashed #3498db; border-radius: 6px; background: #f8f9ff; }" ++
              "#results { margin-top: 30px; }" ++
              "</style>"