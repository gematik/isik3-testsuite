@basis
@mandatory
@CodeSystem-Search
Feature: Testen von Suchparametern gegen die CodeSystem Ressource (@CodeSystem-Search)

  @vorbedingung
  Scenario: Vorbedingung
    Given Testbeschreibung: "Das zu testende System MUSS die zuvor angelegte Ressource bei einer Suche anhand des Parameters finden und in den Suchergebnissen zurückgeben (SEARCH)."
    Given Mit den Vorbedingungen:
    """
      - Der Testfall CodeSystem-Read muss zuvor erfolgreich ausgeführt worden sein.
    """

  Scenario: Read und Validierung des CapabilityStatements
    Then Get FHIR resource at "http://fhirserver/metadata" with content type "json"
    And FHIR current response body evaluates the FHIRPaths:
    """
      rest.where(mode = "server").resource.where(type = "CodeSystem" and interaction.where(code = "search-type").exists()).exists()
      rest.where(mode = "server").resource.where(type = "CodeSystem" and searchParam.where(name = "_id" and type = "token").exists()).exists()
      rest.where(mode = "server").resource.where(type = "CodeSystem" and searchParam.where(name = "url" and type = "uri").exists()).exists()
      rest.where(mode = "server").resource.where(type = "CodeSystem" and searchParam.where(name = "name" and type = "string").exists()).exists()
      rest.where(mode = "server").resource.where(type = "CodeSystem" and searchParam.where(name = "status" and type = "token").exists()).exists()
      rest.where(mode = "server").resource.where(type = "CodeSystem" and searchParam.where(name = "version" and type = "token").exists()).exists()
      rest.where(mode = "server").resource.where(type = "CodeSystem" and searchParam.where(name = "content-mode" and type = "token").exists()).exists()
    """

  Scenario: Suche nach dem CodeSystem anhand der ID
    Then Get FHIR resource at "http://fhirserver/CodeSystem/?_id=${data.codesystem-read-id}" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.where(id.replaceMatches("/_history/.+","").matches("${data.codesystem-read-id}")).count() = 1' with error message 'Das gesuchte CodeSystem ${data.codesystem-read-id} ist nicht im Responsebundle enthalten'
    And FHIR current response body is a valid CORE resource and conforms to profile "https://hl7.org/fhir/StructureDefinition/Bundle"
    And Check if current response of resource "CodeSystem" is valid ISIK3 and conforms to profile "https://gematik.de/fhir/isik/v3/Basismodul/StructureDefinition/ISiKCodeSystem"

  Scenario Outline: Suche nach CodeSystem anhand <title>
    Then Get FHIR resource at "http://fhirserver/CodeSystem/?<searchParameter>=<searchValue>" with content type "<contentType>"
    And FHIR current response body evaluates the FHIRPath "entry.resource.count() > 0" with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(<searchParameter> = '<searchValue>')" with error message 'Es gibt Suchergebnisse, die nicht dem Kriterium entsprechen'

    Examples:
      | title       | contentType | searchParameter | searchValue                                    |
      | der URL     | xml         | url             | http://example.org/fhir/CodeSystem/TestKatalog |
      | des Namens  | json        | name            | testkatalog                                    |
      | des Status  | json        | status          | active                                         |
      | der Version | json        | version         | 1.0.0                                          |

  Scenario: Suche des CodeSystems anhand der PatientIn
    Then Get FHIR resource at "http://fhirserver/CodeSystem/?content-mode=complete" with content type "xml"
    And FHIR current response body evaluates the FHIRPath "entry.resource.count() > 0" with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(content = 'complete')" with error message 'Es gibt Suchergebnisse, die nicht dem Kriterium entsprechen'
