@medikation
@mandatory
@MedicationStatement-Update
Feature: Update einer MedicationStatement-Ressource (@MedicationStatement-Update)

  @vorbedingung
  Scenario: Vorbedingung
    Given Testbeschreibung: "Das zu testende System MUSS die Ressource intern erstellen."
    Given Mit den Vorbedingungen:
      """
        - Der Testfall Medication-Read muss zuvor erfolgreich ausgeführt worden sein.
        - Bitte geben Sie die ID einer beliebigen MedicationStatement-Resource, die mit Testdaten aktualisiert werden soll, in der Konfigurationsvariable 'medicationstatement-update-id' an.
      """

  Scenario: Read und Validierung des CapabilityStatements
    Then Get FHIR resource at "http://fhirserver/metadata" with content type "json"
    And CapabilityStatement contains interaction "update" for resource "MedicationStatement"

  Scenario: Update einer MedicationStatement-Ressource
    Given TGR set default header "Content-Type" to "application/fhir+json"
    When TGR send PUT request to "http://fhirserver/MedicationStatement/${data.medicationstatement-update-id}" with body "!{file('src/test/resources/features/Medikation/fixtures/MedicationStatement-Update-Fixture.json')}"
    And TGR find the last request
    Then TGR current response with attribute "$.responseCode" matches "200"
    And TGR send empty GET request to "http://fhirserver/MedicationStatement/${data.medicationstatement-update-id}"
    And TGR find the last request
    And TGR current response with attribute "$.body.note.0.text.content" matches "Aktualisierte Testnotiz"
    And TGR current response with attribute "$.body.dosage.0.patientInstruction.content" matches "Aktualisierter Instruktionstest"
    And FHIR current response body evaluates the FHIRPath "dosage.doseAndRate.dose.value = 5" with error message 'Gesamtdosis entspricht nicht dem Erwartungswert'
