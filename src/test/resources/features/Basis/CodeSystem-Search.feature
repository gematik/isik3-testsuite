@basis
@optional
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
    """

  Scenario: Suche nach dem CodeSystem anhand der ID
    Then Get FHIR resource at "http://fhirserver/CodeSystem/?_id=${data.codesystem-read-id}" with content type "xml"
    And response bundle contains resource with ID "${data.codesystem-read-id}" with error message "Das gesuchte CodeSystem ${data.codesystem-read-id} ist nicht im Responsebundle enthalten"
    And FHIR current response body is a valid CORE resource and conforms to profile "https://hl7.org/fhir/StructureDefinition/Bundle"
    And Check if current response of resource "CodeSystem" is valid isik3-basismodul resource and conforms to profile "https://gematik.de/fhir/isik/v3/Basismodul/StructureDefinition/ISiKCodeSystem"

  Scenario: Suche nach CodeSystem anhand der URL
    Then Get FHIR resource at "http://fhirserver/CodeSystem/?url=http%3A%2F%2Fexample.org%2Ffhir%2FCodeSystem%2FTestKatalog" with content type "xml"
    And FHIR current response body evaluates the FHIRPath "entry.resource.count() > 0" with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(url = 'http://example.org/fhir/CodeSystem/TestKatalog')" with error message 'Es gibt Suchergebnisse, diese passen allerdings nicht vollständig zu den Suchkriterien.'