@terminplanung
@optional
@Communication-Create
Feature: POST einer Communication-Ressource (@Communication-Create)

  @vorbedingung
  Scenario: Vorbedingung
    Given Testbeschreibung: "Das zu testende System MUSS die Ressource intern erstellen."
    Given Mit den Vorbedingungen:
    """
      - Der Testfall Communication-Read muss zuvor erfolgreich ausgeführt worden sein.
    """

  Scenario: Read und Validierung des CapabilityStatements
    Then Get FHIR resource at "http://fhirserver/metadata" with content type "json"
    And CapabilityStatement contains interaction "create" for resource "Communication"

  Scenario: POST einer Communication-Ressource
    When TGR set default header "Content-Type" to "application/fhir+json"
    And TGR send POST request to "http://fhirserver/Communication" with body "!{file('src/test/resources/features/Terminplanung/fixtures/Communication-Create-Fixture.json')}"
    And TGR find the last request
    Then TGR current response with attribute "$.responseCode" matches "201"
    # TODO Retrieve the resource identified by the location header and assert its attributes
