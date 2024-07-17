@basis
@mandatory
@ValueSet-Search
Feature: Testen von Suchparametern gegen die ValueSet Ressource (@ValueSet-Search)

  @vorbedingung
  Scenario: Vorbedingung
    Given Testbeschreibung: "Das zu testende System MUSS die zuvor angelegte Ressource bei einer Suche anhand des Parameters finden und in den Suchergebnissen zurückgeben (SEARCH)."
    Given Mit den Vorbedingungen:
    """
      - Der Testfall ValueSet-Read muss zuvor erfolgreich ausgeführt worden sein.
    """

  Scenario: Read und Validierung des CapabilityStatements
    Then Get FHIR resource at "http://fhirserver/metadata" with content type "xml"
    And FHIR current response body evaluates the FHIRPaths:
    """
      rest.where(mode = "server").resource.where(type = "ValueSet" and interaction.where(code = "search-type").exists()).exists()
      rest.where(mode = "server").resource.where(type = "ValueSet" and searchParam.where(name = "_id" and type = "token").exists()).exists()
      rest.where(mode = "server").resource.where(type = "ValueSet" and searchParam.where(name = "url" and type = "uri").exists()).exists()
      rest.where(mode = "server").resource.where(type = "ValueSet" and searchParam.where(name = "version" and type = "token").exists()).exists()
      rest.where(mode = "server").resource.where(type = "ValueSet" and searchParam.where(name = "name" and type = "string").exists()).exists()
      rest.where(mode = "server").resource.where(type = "ValueSet" and searchParam.where(name = "status" and type = "token").exists()).exists()
    """

  Scenario: Suche nach ValueSet anhand der ID
    Then Get FHIR resource at "http://fhirserver/ValueSet/?_id=${data.valueset-read-id}" with content type "xml"
    Then TGR find last request to path "/ValueSet/" with "$.path._id.value" matching "${data.valueset-read-id}"
    Then TGR current response with attribute "$.responseCode" matches "200"
    And TGR current response with attribute "$.header.Content-Type" matches "application/fhir+xml;charset=UTF-8"
    And response bundle contains resource with ID "${data.valueset-read-id}" with error message "Das gesuchte ValueSet ${data.valueset-read-id} ist nicht im Responsebundle enthalten"
    And FHIR current response body is a valid CORE resource and conforms to profile "https://hl7.org/fhir/StructureDefinition/Bundle"
    And Check if current response of resource "ValueSet" is valid isik3-basismodul resource and conforms to profile "https://gematik.de/fhir/isik/v3/Basismodul/StructureDefinition/ISiKValueSet"

  Scenario Outline: Suche nach CodeSystem anhand <title>
    Then Get FHIR resource at "http://fhirserver/ValueSet/?<searchParameter>=<searchValue>" with content type "<contentType>"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(<searchParameter> = '<searchValue>')" with error message 'Es gibt Suchergebnisse, diese passen allerdings nicht vollständig zu den Suchkriterien.'

    Examples:
      | title       | contentType | searchParameter | searchValue                                   |
      | der URL     | xml         | url             | http://example.org/fhir/ValueSet/TestValueSet |
      | des Namens  | json        | name            | TestValueSet                                  |
      | des Status  | json        | status          | active                                        |
      | der Version | json        | version         | 1.0.0                                         |
