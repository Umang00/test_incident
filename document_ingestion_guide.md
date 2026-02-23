# Best Document Formats for RAG Embeddings

## Executive Summary
**Markdown (.md)** is the absolute best format for RAG embeddings. 
Avoid raw **PDFs** if possible. **Text (.txt)** is acceptable but suboptimal.

## 1. The Hierarchy of Formats

| Rank | Format | Why? |
| :--- | :--- | :--- |
| **1. 👑 Markdown** | **Structure = Meaning.** Headers (`#`, `##`) allow us to chunk data *intelligently* (e.g., "Only split at H2 headers"). This keeps related concepts together. |
| **2. 🥈 HTML** | Good structure (tags), but often "noisy" with CSS/JS and deep nesting that confuses embedding models. |
| **3. 🥉 Plain Text** | Easy to read, but you lose the "skeleton" of the document. You have to chunk by "500 words", which might cut a sentence in half. |
| **4. 💀 PDF** | **The Worst.** PDFs are "pictures of text". They lose reading order, smash tables into gibberish, and have no concept of "headers". |

---

## 2. Why Markdown Wins (The "Chunking" Advantage)

When you embed a document, you must **chunk** it (split it into small pieces).

### ❌ Bad Chunking (PDF/Text)
*   **Method**: "Split every 500 characters."
*   **Result**: 
    > "...in the event of a fire, do NOT..."
    > *(Chunk 1 ends)*
    > *(Chunk 2 starts)*
    > "...use the elevator."
*   **Problem**: If I search "Can I use the elevator?", Chunk 2 says "use the elevator" without the "NOT". **Dangerous.**

### ✅ Good Chunking (Markdown)
*   **Method**: "Split by Header".
*   **Result**:
    ```markdown
    ## Fire Safety
    In the event of a fire, do NOT use the elevator.
    ```
*   **Advantage**: The `## Fire Safety` header is *attached* to the rule. The context is preserved.

---

## 3. Recommended Workflow: "The Markdown Pipeline"

Since most business documents are PDFs, you shouldn't *embed* the PDF directly. **Convert it first.**

1.  **Ingest**: Take PDF / DOCX / HTML.
2.  **Convert to Markdown**: Use a parser that understands layout.
    *   **Free/Open Source**: `PyMuPDF4LLM` (Excellent, fast).
    *   **Paid/SaaS**: `LlamaParse` (State of the art, uses AI to "see" the PDF).
3.  **Embed**: Send the clean Markdown to Voyage AI / Google / Octen.

## 4. Summary for incident-management
Your current setup (Markdown files in the repo) is **already best-practice**. 
*   **Stick to Markdown.** 
*   If you ingest *new* data (e.g., PDFs from vendors), write a script to convert them to Markdown *before* putting them in your `incidents/` folder.
