@medikation
@mandatory
@MedicationAdministration-Create
Feature: POST einer Medikationsverabreichung (@MedicationAdministration-Create)

  @vorbedingung
  Scenario: Vorbedingung
    Given Testbeschreibung: "Das zu testende System MUSS die Ressource intern erstellen."
    Given Mit den Vorbedingungen:
      """
        Der Testfall Medication-Read muss zuvor erfolgreich ausgeführt worden sein.
      """

  Scenario: Read und Validierung des CapabilityStatements
    Then Get FHIR resource at "http://fhirserver/metadata" with content type "json"
    And CapabilityStatement contains interaction "create" for resource "MedicationAdministration"

  Scenario: POST einer Medikationsverabreichung
    Given TGR set default header "Content-Type" to "application/fhir+json"
    When TGR send POST request to "http://fhirserver/MedicationAdministration" with body "!{file('src/test/resources/features/Medikation/fixtures/MedicationAdministration-Create-Fixture.json')}"
    And TGR find the last request
    Then TGR current response with attribute "$.responseCode" matches "201"
    # TODO Retrieve the resource identified by the location header and assert its attributes