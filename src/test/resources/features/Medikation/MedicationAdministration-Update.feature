@medikation
@mandatory
@MedicationAdministration-Update
Feature: Update einer Medikationsverabreichung (@MedicationAdministration-Update)

  @vorbedingung
  Scenario: Vorbedingung
    Given Testbeschreibung: "Das zu testende System MUSS die Ressource intern erstellen."
    Given Mit den Vorbedingungen:
      """
        - Der Testfall Medication-Read muss zuvor erfolgreich ausgeführt worden sein.
        - Bitte geben Sie die ID einer beliebigen MedicationAdministration-Resource, die mit Testdaten aktualisiert werden soll, in der Konfigurationsvariable 'medicationadministration-update-id' an.
      """

  Scenario: Read und Validierung des CapabilityStatements
    Then Get FHIR resource at "http://fhirserver/metadata" with content type "json"
    And CapabilityStatement contains interaction "update" for resource "MedicationAdministration"

  Scenario: Update einer Medikationsverabreichung
    Given TGR set default header "Content-Type" to "application/fhir+json"
    When TGR send PUT request to "http://fhirserver/MedicationAdministration/${data.medicationadministration-update-id}" with body "!{file('src/test/resources/features/Medikation/fixtures/MedicationAdministration-Update-Fixture.json')}"
    And TGR find the last request
    Then TGR current response with attribute "$.responseCode" matches "200"
    And TGR send empty GET request to "http://fhirserver/MedicationAdministration/${data.medicationadministration-update-id}"
    And TGR find the last request
    And TGR current response with attribute "$.body.note.0.text.content" matches "Aktualisierte Testnotiz"
    And TGR current response with attribute "$.body.dosage.text.content" matches "Aktualisierte Dosierungsangabe"
    Then TGR current response with attribute "$.body.dosage.dose.value.content" matches "5"
    And FHIR current response body evaluates the FHIRPath "dosage.rate.value = 5" with error message 'Ratenangabe entspricht nicht dem Erwartungswert'