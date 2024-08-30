@basis
@optional
@Encounter-Search-Optional
Feature: Testen von Suchparametern gegen encounter-read-in-progress (@Encounter-Search-Optional)

  @vorbedingung
  Scenario: Vorbedingung
    Given Testbeschreibung: "Das zu testende System MUSS die zuvor angelegte Ressource bei einer Suche anhand des Parameters finden und in den Suchergebnissen zurückgeben (SEARCH)."
    Given Mit den Vorbedingungen:
    """
      - Der Testfall Encounter-Read-In-Progress muss zuvor erfolgreich mit den optionalen Feldern ausgeführt worden sein.
    """

  Scenario: Read und Validierung des CapabilityStatements
    When Get FHIR resource at "http://fhirserver/metadata" with content type "json"

  Scenario Outline: Validierung der Suchparameter-Definitionen im CapabilityStatement
    Then CapabilityStatement contains definition of search parameter "<searchParamValue>" of type "<searchParamType>" for resource "Encounter"

    Examples:
      | searchParamValue | searchParamType |
      | location         | reference       |
      | service-provider | reference       |

  Scenario: Suche dem Encounter anhand des Ortes
    Then Get FHIR resource at "http://fhirserver/Encounter/?location=Location/${data.encounter-read-in-progress-location}" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath 'entry.resource.all(location.location.reference.replaceMatches("/_history/.+","").matches("\\b${data.encounter-read-in-progress-location}$"))' with error message 'Es gibt Suchergebnisse, diese passen allerdings nicht vollständig zu den Suchkriterien.'
    And FHIR current response body is a valid CORE resource and conforms to profile "https://hl7.org/fhir/StructureDefinition/Bundle"
    And Check if current response of resource "Encounter" is valid isik3-basismodul resource and conforms to profile "https://gematik.de/fhir/isik/v3/Basismodul/StructureDefinition/ISiKKontaktGesundheitseinrichtung"

  Scenario: Suche des Encounters anhand des Versorgers
    Then Get FHIR resource at "http://fhirserver/Encounter/?service-provider=${data.encounter-read-in-progress-service-provider}" with content type "json"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath 'entry.resource.all(serviceProvider.reference.replaceMatches("/_history/.+","").matches("\\b${data.encounter-read-in-progress-service-provider}$"))' with error message 'Es gibt Suchergebnisse, diese passen allerdings nicht vollständig zu den Suchkriterien.'