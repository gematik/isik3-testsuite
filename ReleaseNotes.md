<img align="right" width="250" height="47" src="imgs/gematik_logo.png"/> <br/>

# Release Notes ISiK Stufe 3 Test Suite

## Release 1.1.0 (2024-08-30)

(sync with TITUS test cases v3.4.0)

### added
- Verification of TelematikID and precinct in Practitioner-Read test
- Verification of TelematikID as a search identifier in Practitioner-Search test
- Verification of patientInstruction and timing data in MedicationRequest-Read test

### changed
- Unified search test cases by medication code for MedicationRequest, MedicationAdministration and MedicationStatement resources
- Enabling use of reasonCode apart from reasonReference in MedicationStatement-Read test
- Enabling coding of timing information using multiple dosageInstruction elements in MedicationStatement-Read and MedicationRequest tests
- Enabling use of a dedicated Medication resource in MedicationRequest tests
- Enabling use of arbitrary values in dosage.text for MedicationAdministration and MedicationStatement tests
- Enabling use of arbitrary dates in List tests
- [TIGER Workflow UI](https://gematik.github.io/app-Tiger/Tiger-User-Manual.html#_workflow_ui) now starts by default. Change `lib.activateWorkflowUi` in `tiger.yaml` to `false` to disable it. 

### fixed
- Verification of meta.tag in Appointment-Read test
- UCUM code for Tablette in MedicationUpdate test
- Corrupted HTML reports with Javascript error showing up for testcases with a template in title (e.g. Suche des Medikaments anhand des <title>)

## Release 1.0.0 (2024-07-17)

- initial implementation
