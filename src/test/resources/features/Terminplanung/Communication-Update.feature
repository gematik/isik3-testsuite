@terminplanung
@optional
@Communication-Update
Feature: UPDATE einer Communication-Ressource (@Communication-Update)

  @vorbedingung
  Scenario: Vorbedingung
    Given Testbeschreibung: "Das zu testende System MUSS intern ein Update auf die Ressource ausführen."
    Given Mit den Vorbedingungen:
    """
      - Der Testfall Communication-Create muss zuvor erfolgreich ausgeführt worden sein.
      - Bitte geben Sie die ID einer beliebigen Nachricht, die mit Testdaten aktualisiert werden soll, in der Konfigurationsvariable 'communication-update-id' an.
    """

  Scenario: Read und Validierung des CapabilityStatements
    Then Get FHIR resource at "http://fhirserver/metadata" with content type "json"
    And CapabilityStatement contains interaction "update" for resource "Communication"

  Scenario: UPDATE einer Communication-Ressource
    When TGR set default header "Content-Type" to "application/fhir+json"
    And TGR send PUT request to "http://fhirserver/Communication/${data.communication-update-id}" with body "!{file('src/test/resources/features/Terminplanung/fixtures/Communication-Update-Fixture.json')}"
    And TGR find the last request
    Then TGR current response with attribute "$.responseCode" matches "200"
    And TGR send empty GET request to "http://fhirserver/Communication/${data.communication-update-id}"
    And TGR find the last request
    Then FHIR current response body evaluates the FHIRPath "payload.where(content.contains('Update!!! Dies ist die aktualisierte Nachricht aus dem Bestätigungssystem!')).exists()" with error message 'Der schriftliche Inhalt wurde nicht aktualisiert'
    And TGR current response with attribute "$..sent" matches "2023-03-02T15:05:13Z"
