@medikation
@mandatory
@List-Update
Feature: Update Medikationsliste (@List-Update)

  @vorbedingung
  Scenario: Vorbedingung
    Given Testbeschreibung: "Das zu testende System MUSS die angelegte Ressource bei einem HTTP GET auf deren URL korrekt und vollständig zurückgeben (READ)."
    Given Mit den Vorbedingungen:
    """
      - Die Testfälle MedicationStatement-Read, MedicationStatement-Read-Extended müssen zuvor erfolgreich ausgeführt worden sein.
      - Bitte geben Sie die ID einer beliebigen Medikationsliste, die mit Testdaten aktualisiert werden soll, in der Konfigurationsvariable 'list-update-id' an.
    """

  Scenario: Read und Validierung des CapabilityStatements
    Then Get FHIR resource at "http://fhirserver/metadata" with content type "json"
    And CapabilityStatement contains interaction "update" for resource "List"

  Scenario: UPDATE einer List-Ressource
    When TGR set default header "Content-Type" to "application/fhir+json"
    And TGR send PUT request to "http://fhirserver/List/${data.list-update-id}" with body "!{file('src/test/resources/features/Medikation/fixtures/List-Update-Fixture.json')}"
    And TGR find the last request
    Then TGR current response with attribute "$.responseCode" matches "200"
    And TGR send empty GET request to "http://fhirserver/List/${data.list-update-id}"
    And TGR find the last request
    Then TGR current response with attribute "$.body.date.content" matches "2023-10-01"
    Then FHIR current response body evaluates the FHIRPath "entry.where(item.reference.replaceMatches('/_history/.+','').matches('MedicationStatement/${data.medicationstatement-read-id}$') and date.toString().contains('2023-10-01')).exists()" with error message 'Listeneintrag wurde nicht gefunden'
    Then FHIR current response body evaluates the FHIRPath "entry.where(item.reference.replaceMatches('/_history/.+','').matches('MedicationStatement/${data.medicationstatement-read-extended-id}$') and date.toString().contains('2023-10-01')).exists()" with error message 'Listeneintrag wurde nicht gefunden'