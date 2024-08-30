@medikation
@mandatory
@MedicationRequest-Update
Feature: Update einer Medikationsverordnung (@MedicationRequest-Update)

  @vorbedingung
  Scenario: Vorbedingung
    Given Testbeschreibung: "Das zu testende System MUSS die Ressource intern erstellen."
    Given Mit den Vorbedingungen:
      """
        - Bitte geben Sie die ID einer beliebigen MedicationRequest-Resource, die mit Testdaten aktualisiert werden soll, in der Konfigurationsvariable 'medicationrequest-update-id' an.
      """

  Scenario: Read und Validierung des CapabilityStatements
    Then Get FHIR resource at "http://fhirserver/metadata" with content type "json"
    And CapabilityStatement contains interaction "update" for resource "MedicationRequest"

  Scenario: Update einer Medikationsverordnung
    Given TGR set default header "Content-Type" to "application/fhir+json"
    When TGR send PUT request to "http://fhirserver/MedicationRequest/${data.medicationrequest-update-id}" with body "!{file('src/test/resources/features/Medikation/fixtures/MedicationRequest-Update-Fixture.json')}"
    And TGR find the last request
    Then TGR current response with attribute "$.responseCode" matches "200"
    And TGR send empty GET request to "http://fhirserver/MedicationRequest/${data.medicationrequest-update-id}"
    And TGR find the last request
    And TGR current response with attribute "$.body.note.0.text.content" matches "Aktualisierte Testnotiz"
    And FHIR current response body evaluates the FHIRPath "dosageInstruction.all(text = 'Aktualisierte Dosierungsangabe')" with error message 'Die Freitext-Dosierungsanweisungen entsprechen nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "dispenseRequest.quantity.value = 10" with error message 'Angeforderte Abgabemenge entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "substitution.allowed = false" with error message 'Ersatz zulässig entspricht nicht dem Erwartungswert'
