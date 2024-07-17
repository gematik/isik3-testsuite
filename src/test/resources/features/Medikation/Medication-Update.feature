@medikation
@mandatory
@Medication-Update
Feature: Update einer Medication-Ressource (@Medication-Update)

  @vorbedingung
  Scenario: Vorbedingung
    Given Testbeschreibung: "Das zu testende System MUSS die Ressource intern erstellen."
    Given Mit den Vorbedingungen:
      """
        - Der Testfall Medication-Read muss zuvor erfolgreich ausgeführt worden sein.
        - Bitte geben Sie die ID einer beliebigen Medication-Resource, die mit Testdaten aktualisiert werden soll, in der Konfigurationsvariable 'medication-update-id' an.
      """

  Scenario: Read und Validierung des CapabilityStatements
    Then Get FHIR resource at "http://fhirserver/metadata" with content type "json"
    And CapabilityStatement contains interaction "update" for resource "Medication"

  Scenario: Update einer Medication-Ressource
    Given TGR set default header "Content-Type" to "application/fhir+json"
    When TGR send PUT request to "http://fhirserver/Medication/${data.medication-update-id}" with body "!{file('src/test/resources/features/Medikation/fixtures/Medication-Update-Fixture.json')}"
    And TGR find the last request
    Then TGR current response with attribute "$.responseCode" matches "200"
    And TGR send empty GET request to "http://fhirserver/Medication/${data.medication-update-id}"
    And TGR find the last request
    And FHIR current response body evaluates the FHIRPath "amount.numerator.value ~ 100" with error message 'Die Menge (der Dividend) entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "amount.denominator.value ~ 10" with error message 'Die Menge (der Nenner) entspricht nicht dem Erwartungswert'
