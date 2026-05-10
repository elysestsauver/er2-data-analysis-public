# Data Analysis/Codebook/

Codebook materials for the analysis. The CSV codebooks are excluded from the
public repo because they catalog respondent-level variables and survey
structure that pair with the private data.

Expected files:

- `codebook.csv` — variable dictionary (column name → type/category) for the
  primary analysis datasets in `Datasets/`. Two columns: `Variable Name`,
  `Type`.
- `irb_guidelines.csv` — reference of IRB and ethics guidelines, used in
  descriptive sections of the analysis. Six columns: `organization`,
  `ethics_doc`, `return_results`, `type`, `region`, `field`.

The `ER2 Data Codebook.Rmd` notebook reads these files and renders the
codebook in human-readable form. `Data Cleaning Notes.docx` is a working
log of cleaning decisions and pasted R snippets.
