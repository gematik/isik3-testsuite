@terminplanung
@mandatory
@Binary-Create
Feature: POST Binary-Ressource (@Binary-Create)

  @vorbedingung
  Scenario: Vorbedingung
    Given Testbeschreibung: "Das zu testende System MUSS die Ressource intern erstellen."
    Given Mit den Vorbedingungen:
    """
      - Keine Vorbedingungen
    """

  Scenario: Read und Validierung des CapabilityStatements
    Then Get FHIR resource at "http://fhirserver/metadata" with content type "json"
    And CapabilityStatement contains interaction "create" for resource "Binary"

  Scenario: POST einer Binary-Ressource
    When TGR set default header "Content-Type" to "application/fhir+json"
    And TGR send POST request to "http://fhirserver/Binary" with body "!{file('src/test/resources/features/Terminplanung/fixtures/Binary-Binary-Create-Fixture.json')}"
    And TGR find the last request
    Then TGR current response with attribute "$.responseCode" matches "20\d"
    # TODO Retrieve the resource identified by the location header and assert its attributes
