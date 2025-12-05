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
            "   <input type='file' id='reference' accept='.txt,.fasta,.fa' onchange='readFile(this, \"refContent\")'>",
            "   <textarea id='refContent' placeholder='Reference DNA content will appear here...' style='width: 100%; height: 100px; margin-top: 10px;'></textarea>",
            "</div>",
            "<div class='upload-box'>",
            "   <h3>2. Select Patient DNA Files</h3>", 
            "   <input type='file' id='patients' accept='.txt,.fasta,.fa' multiple onchange='readFiles(this)'>",
            "   <div id='patientFiles'></div>",
            "</div>",
            "<button onclick='analyzeFiles()' class='btn'>Analyze Files</button>",
            "<div id='results'></div>",
            "<script>",
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
            "  Array.from(input.files).forEach((file, index) => {",
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
            "  const patientTextareas = document.querySelectorAll('[id^=\"patient\"]');",
            "  const patients = [];",
            "  patientTextareas.forEach((textarea, index) => {",
            "    if (textarea.value) patients.push({name: `patient${index+1}`, content: textarea.value});",
            "  });",
            "  ",
            "  fetch('/analyze', {",
            "    method: 'POST',",
            "    headers: {'Content-Type': 'application/json'},",
            "    body: JSON.stringify({reference: refContent, patients: patients})",
            "  }).then(response => response.text())",
            "    .then(html => document.getElementById('results').innerHTML = html)",
            "    .catch(error => document.getElementById('results').innerHTML = 'Error: ' + error);",
            "}",
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
styleHeader = pack $ "<style>" ++
              "body { font-family: 'Segoe UI', sans-serif; background: #f4f4f9; padding: 40px; color: #333; }" ++
              "h1 { color: #2c3e50; text-align: center; }" ++
              ".container { max-width: 800px; margin: 0 auto; }" ++
              ".upload-box { background: white; padding: 20px; margin: 20px 0; border-radius: 8px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); }" ++
              ".card { background: white; padding: 20px; margin: 20px 0; border-radius: 8px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); list-style: none; }" ++
              ".btn { display: inline-block; padding: 12px 24px; background: #3498db; color: white; text-decoration: none; border-radius: 5px; font-weight: bold; transition: background 0.3s; border: none; cursor: pointer; margin-top: 20px; }" ++
              ".btn:hover { background: #2980b9; }" ++
              ".protein-box { background: #2c3e50; color: #ecf0f1; padding: 10px; border-radius: 4px; margin-top: 10px; }" ++
              ".protein { font-family: 'Courier New', monospace; letter-spacing: 1px; color: #e74c3c; font-weight: bold; }" ++
              ".stats { display: flex; gap: 20px; }" ++
              "</style>"