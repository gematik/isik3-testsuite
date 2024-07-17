@medikation
@mandatory
@MedicationRequest-Create
Feature: POST einer Medikationsverordnung (@MedicationRequest-Create)

  @vorbedingung
  Scenario: Vorbedingung
    Given Testbeschreibung: "Das zu testende System MUSS die Ressource intern erstellen."
    Given Mit den Vorbedingungen:
      """
        Der Testfall Medication-Read muss zuvor erfolgreich ausgeführt worden sein.
      """

  Scenario: Read und Validierung des CapabilityStatements
    Then Get FHIR resource at "http://fhirserver/metadata" with content type "json"
    And CapabilityStatement contains interaction "create" for resource "MedicationRequest"

  Scenario: POST einer Medikationsverordnung
    Given TGR set default header "Content-Type" to "application/fhir+json"
    When TGR send POST request to "http://fhirserver/MedicationRequest" with body "!{file('src/test/resources/features/Medikation/fixtures/MedicationRequest-Create-Fixture.json')}"
    And TGR find the last request
    Then TGR current response with attribute "$.responseCode" matches "201"
    # TODO Retrieve the resource identified by the location header and assert its attributes