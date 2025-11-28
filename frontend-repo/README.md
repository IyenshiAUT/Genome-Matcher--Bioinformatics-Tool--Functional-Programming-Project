# Genome Matcher Frontend

**Frontend Repository for the Genome Matcher Bioinformatics Tool**

## 🌐 Overview

This is the web frontend for the Genome Matcher DNA analysis tool. It provides an intuitive web interface for uploading DNA sequences, running analyses, and viewing mutation detection results.

## 🚀 Features

### 🧬 **DNA Analysis Interface**
- **File Upload**: Upload reference genome and patient DNA files
- **Demo Data**: Pre-loaded sample data for testing
- **Real-time Analysis**: Interactive mutation detection
- **Responsive Design**: Works on desktop, tablet, and mobile

### 📊 **Results Visualization**
- **Risk Assessment**: Color-coded risk levels (Low, Medium, High, Critical)
- **Mutation Details**: Position-specific mutation information
- **Statistical Summary**: Mutation count, risk scores, and levels
- **Patient Comparison**: Side-by-side analysis of multiple patients

### 🎨 **Modern UI/UX**
- **Glass Morphism Design**: Modern backdrop blur effects
- **Smooth Animations**: CSS transitions and loading states
- **Gradient Backgrounds**: Professional scientific aesthetic
- **Interactive Elements**: Hover effects and smooth scrolling

## 📁 **File Structure**

```
frontend-repo/
├── index.html          # Main HTML page
├── styles.css          # CSS styles and animations
├── app.js             # JavaScript application logic
└── README.md          # This documentation
```

## 🛠️ **Technologies Used**

- **HTML5**: Semantic markup and file upload APIs
- **CSS3**: Flexbox, Grid, CSS Variables, Animations
- **Vanilla JavaScript**: ES6+, File Reader API, DOM manipulation
- **Google Fonts**: Inter font family for clean typography

## 🔧 **Setup Instructions**

### **Method 1: Simple File Server**
```bash
# Navigate to frontend directory
cd frontend-repo

# Start a simple HTTP server (Python 3)
python -m http.server 8000

# Or using Node.js
npx serve .

# Open browser to http://localhost:8000
```

### **Method 2: Live Server (VS Code)**
1. Install the "Live Server" extension in VS Code
2. Right-click on `index.html`
3. Select "Open with Live Server"

### **Method 3: Direct File Opening**
- Simply open `index.html` in any modern web browser
- Note: File uploads may be limited due to browser security

## 📖 **Usage Guide**

### **1. Load DNA Data**
- **Upload Files**: Click "Choose Reference File" and "Choose Patient Files"
- **Use Demo**: Click "Load Demo Data" for instant testing
- **File Format**: `.dna` or `.txt` files with DNA sequences (ATCG)

### **2. Run Analysis**
- Click "Analyze DNA Sequences" once data is loaded
- Wait for processing animation to complete
- Results will appear below with detailed mutation information

### **3. Interpret Results**
- **Green Cards**: Healthy patients (no mutations)
- **Yellow/Orange Cards**: Medium to high risk patients
- **Red Cards**: Critical risk patients
- **Mutation List**: Specific base changes and positions

## 🧪 **Demo Data**

The frontend includes built-in demo data:
- **Reference Genome**: `ATCGATCGATCGATCGAAAA` (20 bases)
- **Patient 1**: Healthy (identical to reference)
- **Patient 2**: Critical mutation (A→T at position 0)
- **Patient 3**: Multiple mutations (positions 9 and 19)

## 🔬 **Algorithm Implementation**

The frontend implements simplified versions of the backend algorithms:

### **Mutation Detection**
```javascript
findMutations(reference, patient) {
    const mutations = [];
    for (let i = 0; i < Math.min(reference.length, patient.length); i++) {
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
```

### **Risk Scoring**
```javascript
calculateRiskScore(mutations) {
    const baseScores = { 'High': 15, 'Medium': 8, 'Low': 3 };
    const totalScore = mutations.reduce((sum, mutation) => {
        return sum + (baseScores[mutation.severity] || 5);
    }, 0);
    return Math.round(totalScore / mutations.length * 10) / 10;
}
```

## 🎨 **Design Features**

### **CSS Highlights**
- **Glass Morphism**: `backdrop-filter: blur(10px)`
- **Gradient Backgrounds**: `linear-gradient(135deg, #667eea, #764ba2)`
- **Smooth Animations**: CSS transitions on hover and click
- **Responsive Grid**: CSS Grid and Flexbox for layouts
- **Custom Properties**: CSS variables for consistent theming

### **Interactive Elements**
- **File Upload Styling**: Custom styled file inputs
- **Loading States**: Spinner animations during analysis
- **Hover Effects**: Card lift effects and color changes
- **Smooth Scrolling**: Auto-scroll to results section

## 🔗 **Integration with Backend**

This frontend is designed to work with the Haskell backend:
- **File Formats**: Compatible with backend DNA file formats
- **Algorithm Logic**: Mirrors backend mutation detection
- **Data Structure**: Matches backend data types and results
- **Future Enhancement**: Can be connected via REST API

## 📱 **Browser Compatibility**

- ✅ **Chrome 80+**
- ✅ **Firefox 75+**
- ✅ **Safari 13+**
- ✅ **Edge 80+**
- ✅ **Mobile browsers** (iOS Safari, Chrome Mobile)

## 🔮 **Future Enhancements**

- **API Integration**: Connect to Haskell backend via REST/WebSocket
- **Real-time Updates**: Live analysis progress
- **Data Export**: Download results as JSON/CSV
- **Advanced Visualizations**: DNA sequence alignment views
- **User Authentication**: Multi-user support
- **Database Integration**: Save and load analysis history

## 🤝 **Contributing**

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test in multiple browsers
5. Submit a pull request

## 📄 **License**

This project is part of a Functional Programming course assignment.

---

**Frontend Repository for Genome Matcher v1.0**  
*Bioinformatics DNA Analysis Tool - Web Interface*