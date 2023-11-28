@terminplanung
@mandatory
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

  Scenario Outline: Validierung des CapabilityStatements für <searchParamValue>
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
    And FHIR current response body evaluates the FHIRPath 'entry.resource.where(id.replaceMatches("/_history/.+","").matches("${data.communication-read-id}")).count()=1' with error message 'Die gesuchte Nachricht ${data.communication-read-id} ist nicht im Responsebundle enthalten'
    And FHIR current response body is a valid CORE resource and conforms to profile "https://hl7.org/fhir/StructureDefinition/Bundle"
    And Check if current response of resource "Communication" is valid ISIK3 and conforms to profile "https://gematik.de/fhir/isik/v3/Terminplanung/StructureDefinition/ISiKNachricht"

  Scenario Outline: Suche nach der Nachricht anhand des <title>
    Then Get FHIR resource at "http://fhirserver/Communication/?<searchParameter>=<searchUrl><searchValue>" with content type "<contentType>"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(<reference>.reference.replaceMatches('/_history/.+','').matches('<searchValue>'))" with error message 'Es gibt Suchergebnisse, die nicht dem Kriterium entsprechen'

    Examples:
      | title      | contentType | searchParameter | reference | searchUrl     | searchValue                  |
      | Patienten  | xml         | subject         | subject   | Patient/      | ${data.patient-read-id}      |
      | Patienten  | xml         | patient         | subject   |               | ${data.patient-read-id}      |
      | Empfängers | json        | recipient       | recipient | Practitioner/ | ${data.practitioner-read-id} |
      | Senders    | json        | sender          | sender    | Patient/      | ${data.patient-read-id}      |
