# Datasets/

This folder is intentionally empty in the public repo. The actual datasets
contain respondent-level information from RCT participants and are kept
private. The structure below documents what each file is expected to look
like so you can supply equivalent data to run the analysis scripts.

All file paths are referenced relative to the repo root.

## Top-level files

### `codebook.csv`
Variable dictionary mapping each column name in the analysis datasets to its
type/category.

| column | description |
|---|---|
| `Variable Name` | column name as it appears in the analysis datasets |
| `Type` | type/category label (e.g. categorical, numeric, etc.) |

### `irb_guide.csv`
Reference dataset summarizing IRB and ethics guidelines by organization,
used in the descriptive sections of the analysis.

| column | description |
|---|---|
| `organization` | organization or institution name |
| `ethics_doc` | reference to ethics document |
| `return_results` | policy on returning results to participants |
| `type` | organization type |
| `region` | geographic region |
| `field` | research field |

### `kagera_merged.csv`
Primary respondent-level dataset for the Kagera, Tanzania site. SurveyCTO
export with metadata columns (`SubmissionDate`, `starttime`, `endtime`,
`deviceid`, `username`, `duration`, etc.) followed by survey responses.

### `kagera_merged_dce.csv`
Long-format DCE (discrete choice experiment) responses for the Kagera site.

| column | description |
|---|---|
| `location` | site identifier |
| `game_index` | which DCE game/scenario in the sequence |
| `choicenumber` | trial number within the game |
| `game_matrix` | matrix identifier for the choice set |
| `dce_potion` | chosen option (A/B) |
| `PARENT_KEY` | SurveyCTO parent key |
| `KEY` | SurveyCTO row key |
| `SET-OF-dce_game` | repeating-group identifier |

### `dar.csv`
Respondent-level dataset for the Dar es Salaam site (combined across
Mbagala, Tandika, Temeke wards). Includes geographic identifiers
(`districtID`, `wardID`, `villageID`), respondent ID, treatment assignment,
GPS coordinates, and survey responses.

### `dar_dce.csv`
Long-format DCE responses for the Dar site.

### `dardata_controlinfo.csv`
Sampling/control sheet for Dar respondents — pre-loaded contact info,
ward/mtaa identifiers, and replacement-respondent tracking. Columns
prefixed `SEL_` are sample-frame variables.

### `dar_RR-RCT.dta` / `dar_RR-RCT-DCE.dta` / `dar_controlinfo.dta`
Stata-format equivalents of the Dar datasets above. Produced by the
`Datasets/DarDataOutput/` import workflow. The analysis scripts read
these directly via `haven::read_dta()`.

### `scenario_dataset.csv`
Scenario/image pair definitions for the DCE. Each row is one A-vs-B trial
for one respondent. Columns are paired `*.A` / `*.B` for each attribute
(participants, community, policymakers, compensation, researchfunding) with
both a title and an image filename per attribute.

### `scenario_dataset_with_assignments.csv`
Compact assignment lookup mapping `respondent_ID` × `choicenumber` to a
final scenario image and assignment label.

### `scenario_dataset_with_assignments_kenya.csv`
Kenya-only version of the assignment lookup, used by the Kenya scenario-
image-generation script in `Generating Scenario Image Scripts and Assets/`.

### `scenario_dataset_with_assignments_unassigned.xlsx`
Pre-assignment version of the scenario lookup (no `Assignment` column).

## `DarDataOutput/`

Subfolder for SurveyCTO-style import workflow for the three Dar wards
(Mbagala, Tandika, Temeke). Each ward folder is expected to contain:

- `Returning results (RCT participants) - {Ward}.csv` — main survey export
- `Returning results (RCT participants) - {Ward}.dta` — Stata version
- `Returning results (RCT participants) - {Ward}-consented-section8-dce_game.csv` — DCE long-format export
- `Returning results (RCT participants) - {Ward}-consented-section8-dce_game.dta` — Stata version
- `sample.xlsx` / `sample_replacement.xlsx` — sampling frame and replacement tracking

The `import_*.do` scripts in each ward folder import the raw CSVs into
Stata format. Paths in those scripts have been changed to relative (`./`)
so they run from the ward folder.

`raw/` is expected to contain the merged outputs `RR-RCT.dta` and
`RR-RCT-DCE.dta` produced by `Data Preparations.do`.
