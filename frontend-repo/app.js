// Genome Matcher Frontend Application
// Functional Programming Project - Frontend Repository

class GenomeMatcher {
    constructor() {
        this.referenceData = null;
        this.patientData = [];
        this.initializeEventListeners();
    }

    initializeEventListeners() {
        // File input handlers
        document.getElementById('reference-file').addEventListener('change', (e) => {
            this.handleReferenceFile(e.target.files[0]);
        });

        document.getElementById('patient-files').addEventListener('change', (e) => {
            this.handlePatientFiles(Array.from(e.target.files));
        });

        // Demo data loader
        document.getElementById('load-demo').addEventListener('click', () => {
            this.loadDemoData();
        });

        // Analysis button
        document.getElementById('analyze-btn').addEventListener('click', () => {
            this.analyzeSequences();
        });
    }

    async handleReferenceFile(file) {
        if (file) {
            try {
                const content = await this.readFileAsText(file);
                this.referenceData = this.parseDNASequence(content);
                document.getElementById('reference-info').innerHTML = `
                    <div class="file-success">
                        ✅ ${file.name} loaded (${this.referenceData.length} bases)
                    </div>
                `;
                this.checkAnalysisReady();
            } catch (error) {
                this.showError('Failed to load reference file: ' + error.message);
            }
        }
    }

    async handlePatientFiles(files) {
        if (files.length > 0) {
            try {
                this.patientData = [];
                for (const file of files) {
                    const content = await this.readFileAsText(file);
                    const sequence = this.parseDNASequence(content);
                    this.patientData.push({
                        name: file.name,
                        sequence: sequence
                    });
                }
                
                document.getElementById('patient-info').innerHTML = `
                    <div class="file-success">
                        ✅ ${files.length} patient file(s) loaded
                        <ul style="margin-top: 10px; text-align: left;">
                            ${this.patientData.map(p => `<li>${p.name} (${p.sequence.length} bases)</li>`).join('')}
                        </ul>
                    </div>
                `;
                this.checkAnalysisReady();
            } catch (error) {
                this.showError('Failed to load patient files: ' + error.message);
            }
        }
    }

    loadDemoData() {
        // Demo DNA sequences for testing
        const demoReference = "ATCGATCGATCGATCGAAAA";
        const demoPatients = [
            { name: "Patient 1 (Healthy)", sequence: "ATCGATCGATCGATCGAAAA" },
            { name: "Patient 2 (Critical)", sequence: "TTCGATCGATCGATCGAAAA" },
            { name: "Patient 3 (Multiple)", sequence: "ATCGATCGTTCGATCGAATA" }
        ];

        this.referenceData = this.parseDNASequence(demoReference);
        this.patientData = demoPatients.map(p => ({
            name: p.name,
            sequence: this.parseDNASequence(p.sequence)
        }));

        document.getElementById('reference-info').innerHTML = `
            <div class="file-success">
                ✅ Demo reference loaded (${this.referenceData.length} bases)
            </div>
        `;

        document.getElementById('patient-info').innerHTML = `
            <div class="file-success">
                ✅ ${this.patientData.length} demo patients loaded
                <ul style="margin-top: 10px; text-align: left;">
                    ${this.patientData.map(p => `<li>${p.name} (${p.sequence.length} bases)</li>`).join('')}
                </ul>
            </div>
        `;

        this.checkAnalysisReady();
    }

    parseDNASequence(content) {
        // Parse DNA sequence from file content
        return content.toUpperCase()
                     .replace(/[^ATCG]/g, '') // Keep only valid DNA bases
                     .split('');
    }

    checkAnalysisReady() {
        const analyzeBtn = document.getElementById('analyze-btn');
        if (this.referenceData && this.patientData.length > 0) {
            analyzeBtn.disabled = false;
            analyzeBtn.textContent = '🔍 Analyze DNA Sequences';
        }
    }

    async analyzeSequences() {
        const analyzeBtn = document.getElementById('analyze-btn');
        const spinner = document.getElementById('spinner');
        const resultsSection = document.getElementById('results-section');
        const resultsContainer = document.getElementById('results-container');

        // Show loading state
        analyzeBtn.disabled = true;
        spinner.style.display = 'block';
        analyzeBtn.innerHTML = '<span class="spinner" style="display: block;"></span> Analyzing...';

        try {
            // Simulate processing time
            await new Promise(resolve => setTimeout(resolve, 1500));

            // Perform analysis
            const results = this.patientData.map(patient => {
                const mutations = this.findMutations(this.referenceData, patient.sequence);
                const riskScore = this.calculateRiskScore(mutations);
                const riskLevel = this.classifyRisk(riskScore);
                
                return {
                    patientName: patient.name,
                    mutations: mutations,
                    riskScore: riskScore,
                    riskLevel: riskLevel
                };
            });

            // Display results
            this.displayResults(results);
            resultsSection.style.display = 'block';
            resultsSection.scrollIntoView({ behavior: 'smooth' });

        } catch (error) {
            this.showError('Analysis failed: ' + error.message);
        } finally {
            // Reset button state
            analyzeBtn.disabled = false;
            spinner.style.display = 'none';
            analyzeBtn.innerHTML = '🔍 Analyze DNA Sequences';
        }
    }

    findMutations(reference, patient) {
        const mutations = [];
        const minLength = Math.min(reference.length, patient.length);

        for (let i = 0; i < minLength; i++) {
            if (reference[i] !== patient[i]) {
                mutations.push({
                    position: i,
                    original: reference[i],
                    mutated: patient[i],
                    severity: this.determineSeverity(reference[i], patient[i])
                });
            }
        }

        return mutations;
    }

    determineSeverity(original, mutated) {
        // Simplified severity determination based on base change
        const highImpact = [
            ['A', 'T'], ['T', 'A'],  // Purine <-> Pyrimidine
            ['G', 'C'], ['C', 'G']
        ];

        const change = [original, mutated];
        if (highImpact.some(pair => pair[0] === change[0] && pair[1] === change[1])) {
            return 'High';
        } else {
            return 'Medium';
        }
    }

    calculateRiskScore(mutations) {
        if (mutations.length === 0) return 0;
        
        const baseScores = {
            'High': 15,
            'Medium': 8,
            'Low': 3
        };

        const totalScore = mutations.reduce((sum, mutation) => {
            return sum + (baseScores[mutation.severity] || 5);
        }, 0);

        return Math.round(totalScore / mutations.length * 10) / 10;
    }

    classifyRisk(score) {
        if (score > 25) return 'Critical';
        if (score > 15) return 'High';
        if (score > 8) return 'Medium';
        if (score > 0) return 'Low';
        return 'Minimal';
    }

    displayResults(results) {
        const container = document.getElementById('results-container');
        
        container.innerHTML = results.map(result => `
            <div class="result-card">
                <div class="patient-header">
                    <div class="patient-name">${result.patientName}</div>
                    <div class="risk-badge risk-${result.riskLevel.toLowerCase()}">
                        ${result.riskLevel} Risk
                    </div>
                </div>
                
                <div class="mutation-stats">
                    <div class="stat-item">
                        <div class="stat-value">${result.mutations.length}</div>
                        <div class="stat-label">Mutations</div>
                    </div>
                    <div class="stat-item">
                        <div class="stat-value">${result.riskScore}</div>
                        <div class="stat-label">Risk Score</div>
                    </div>
                    <div class="stat-item">
                        <div class="stat-value">${result.riskLevel}</div>
                        <div class="stat-label">Risk Level</div>
                    </div>
                </div>
                
                ${result.mutations.length > 0 ? `
                    <div class="mutations-list">
                        <h4>Detected Mutations:</h4>
                        ${result.mutations.slice(0, 5).map(mutation => `
                            <div class="mutation-item">
                                <span>Position ${mutation.position}: ${mutation.original} → ${mutation.mutated}</span>
                                <span class="severity-${mutation.severity.toLowerCase()}">${mutation.severity}</span>
                            </div>
                        `).join('')}
                        ${result.mutations.length > 5 ? `<p><em>... and ${result.mutations.length - 5} more mutations</em></p>` : ''}
                    </div>
                ` : `
                    <div class="mutations-list">
                        <p style="color: #28a745; text-align: center; font-weight: 500;">✅ No mutations detected - Patient is healthy</p>
                    </div>
                `}
            </div>
        `).join('');
    }

    readFileAsText(file) {
        return new Promise((resolve, reject) => {
            const reader = new FileReader();
            reader.onload = (e) => resolve(e.target.result);
            reader.onerror = () => reject(new Error('Failed to read file'));
            reader.readAsText(file);
        });
    }

    showError(message) {
        // Simple error display - could be enhanced with a modal or toast
        alert('Error: ' + message);
        console.error(message);
    }
}

// Initialize the application when the page loads
document.addEventListener('DOMContentLoaded', () => {
    new GenomeMatcher();
});