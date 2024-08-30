@terminplanung
@optional
@Communication-Search
Feature: Testen von Suchparametern gegen die Communication Ressource (@Communication-Search)

  @vorbedingung
  Scenario: Vorbedingung
    Given Testbeschreibung: "Das zu testende System MUSS die zuvor angelegte Ressource bei einer Suche anhand des Parameters finden und in den Suchergebnissen zurückgeben (SEARCH)."
    Given Mit den Vorbedingungen:
    """
      - Der Testfall Communication-Read muss zuvor erfolgreich ausgeführt worden sein.
    """

  Scenario: Read und Validierung des CapabilityStatements
    Then Get FHIR resource at "http://fhirserver/metadata" with content type "json"
    And FHIR current response body evaluates the FHIRPaths:
    """
      rest.where(mode = "server").resource.where(type = "Communication" and interaction.where(code = "search-type").exists()).exists()
    """

  Scenario Outline: Validierung der Suchparameter-Definitionen im CapabilityStatement
    And FHIR current response body evaluates the FHIRPaths:
    """
      rest.where(mode = "server").resource.where(type = "Communication" and searchParam.where(name = "<searchParamValue>" and type = "<searchParamType>").exists()).exists()
    """

    Examples:
      | searchParamValue | searchParamType |
      | _id              | token           |
      | subject          | reference       |
      | recipient        | reference       |
      | sender           | reference       |

  Scenario: Suche nach der Nachricht anhand der ID
    Then Get FHIR resource at "http://fhirserver/Communication/?_id=${data.communication-read-id}" with content type "xml"
    And response bundle contains resource with ID "${data.communication-read-id}" with error message "Die gesuchte Nachricht ${data.communication-read-id} ist nicht im Responsebundle enthalten"
    And FHIR current response body is a valid CORE resource and conforms to profile "https://hl7.org/fhir/StructureDefinition/Bundle"
    And Check if current response of resource "Communication" is valid isik3-terminplanung resource and conforms to profile "https://gematik.de/fhir/isik/v3/Terminplanung/StructureDefinition/ISiKNachricht"

  Scenario Outline: Suche nach der Nachricht anhand der Referenzen
    Then Get FHIR resource at "http://fhirserver/Communication/?<searchParameter>=<searchUrl><searchValue>" with content type "<contentType>"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(<reference>.reference.replaceMatches('/_history/.+','').matches('\\b<searchValue>$'))" with error message 'Es gibt Suchergebnisse, diese passen allerdings nicht vollständig zu den Suchkriterien.'

    Examples:
      | contentType | searchParameter | reference | searchUrl     | searchValue                  |
      | xml         | subject         | subject   | Patient/      | ${data.terminplanung-patient-id}      |
      | xml         | patient         | subject   |               | ${data.terminplanung-patient-id}      |
      | json        | recipient       | recipient | Practitioner/ | ${data.terminplanung-practitioner-id} |
      | json        | sender          | sender    | Patient/      | ${data.terminplanung-patient-id}      |
