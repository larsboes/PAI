### Creation Workflow
**Trigger:** "create PDF", "generate PDF", "make PDF", "PDF from data"

**Tools:** reportlab (Python)
**Documentation:** Lines 136-181 (SKILL.md)

**Use Cases:**
- Creating new PDFs from scratch
- Generating reports programmatically
- Multi-page documents with text and graphics
- PDF generation from templates or data

### Merge/Split Workflow
**Trigger:** "merge PDFs", "combine PDFs", "split PDF", "separate pages"

**Tools:** pypdf (Python), qpdf (CLI)
**Documentation:** Lines 46-68 (SKILL.md), Lines 199-211 (qpdf)

**Use Cases:**
- Combining multiple PDFs into one document
- Splitting PDFs into individual pages or ranges
- Reorganizing PDF page order
- Extracting specific page ranges

### Text Extraction Workflow
**Trigger:** "extract text", "PDF to text", "read PDF content"

**Tools:** pdfplumber (Python), pdftotext (CLI)
**Documentation:** Lines 95-103 (pdfplumber), Lines 186-196 (pdftotext)

**Use Cases:**
- Extracting text while preserving layout
- Converting PDFs to plain text
- Batch text extraction from multiple PDFs
- Metadata extraction

### Table Extraction Workflow
**Trigger:** "extract tables", "PDF tables", "table data from PDF"

**Tools:** pdfplumber + pandas (Python)
**Documentation:** Lines 106-133 (SKILL.md)

**Use Cases:**
- Extracting structured table data to Excel/CSV
- Financial data extraction from PDF reports
- Converting PDF tables to dataframes
- Multi-table extraction and combination

### Form Filling Workflow
**Trigger:** "fill PDF form", "PDF form filling", "complete PDF form"

**Tools:** pdf-lib (JavaScript) or pypdf (Python)
**Documentation:** forms.md (complete guide)

**Use Cases:**
- Programmatic form completion
- Batch form processing
- Template-based PDF generation
- Form field population from data sources

### OCR Workflow
**Trigger:** "OCR", "scanned PDF", "extract text from scan", "image to text"

**Tools:** pytesseract + pdf2image (Python)
**Documentation:** Lines 227-244 (SKILL.md)

**Use Cases:**
- Extracting text from scanned documents
- Processing image-based PDFs
- Converting scanned forms to editable text
- Legacy document digitization

### Manipulation Workflow
**Trigger:** "watermark", "password protect", "encrypt PDF", "rotate pages", "extract images"

**Tools:** pypdf (Python), pdfimages (CLI)
**Documentation:** Lines 246-288 (SKILL.md)

**Use Cases:**
- Adding watermarks to PDFs
- Password protection and encryption
- Page rotation and transformation
- Image extraction from PDFs

