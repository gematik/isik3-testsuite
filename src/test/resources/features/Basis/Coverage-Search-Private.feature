@basis
@mandatory
@Coverage-Search-Private
Feature: Testen von Suchparametern gegen coverage-read-private (@Coverage-Search-Private)

  @vorbedingung
  Scenario: Vorbedingung
    Given Testbeschreibung: "Das zu testende System MUSS die zuvor angelegte Ressource bei einer Suche anhand des Parameters finden und in den Suchergebnissen zurückgeben (SEARCH)."
    Given Mit den Vorbedingungen:
    """
      - Der Testfall Coverage-Read-Private muss zuvor erfolgreich ausgeführt worden sein.
    """

  Scenario: Read und Validierung des CapabilityStatements
    Then Get FHIR resource at "http://fhirserver/metadata" with content type "json"
    And CapabilityStatement contains interaction "read" for resource "Coverage"
    And FHIR current response body evaluates the FHIRPaths:
    """
      rest.where(mode = "server").resource.where(type = "Coverage" and interaction.where(code = "search-type").exists()).exists()
      rest.where(mode = "server").resource.where(type = "Coverage" and searchParam.where(name = "_id" and type = "token").exists()).exists()
      rest.where(mode = "server").resource.where(type = "Coverage" and searchParam.where(name = "beneficiary" and type = "reference").exists()).exists()
      rest.where(mode = "server").resource.where(type = "Coverage" and searchParam.where(name = "payor" and type = "reference").exists()).exists()
    """

  Scenario: Suche der Coverage-Ressource anhand der ID
    Then Get FHIR resource at "http://fhirserver/Coverage/?_id=${data.coverage-read-private-id}" with content type "xml"
    And response bundle contains resource with ID "${data.coverage-read-private-id}" with error message "Die gesuchte Diagnose ${data.coverage-read-private-id} ist nicht im Responsebundle enthalten"
    And FHIR current response body is a valid CORE resource and conforms to profile "https://hl7.org/fhir/StructureDefinition/Bundle"
    And Check if current response of resource "Coverage" is valid isik3-basismodul resource and conforms to profile "https://gematik.de/fhir/isik/v3/Basismodul/StructureDefinition/ISiKVersicherungsverhaeltnisSelbstzahler"

  Scenario Outline: Suche nach der Coverage anhand des <title>
    Then Get FHIR resource at "http://fhirserver/Coverage/?<searchParameter>=Patient/<searchValue>" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath 'entry.resource.all(<searchParameter>.reference.replaceMatches("/_history/.+","").matches("\\b${data.patient-read-id}$"))' with error message 'Es gibt Suchergebnisse, diese passen allerdings nicht vollständig zu den Suchkriterien.'

    Examples:
      | title        | searchParameter | searchValue             |
      | beneficiarys | beneficiary     | ${data.patient-read-id} |
      | payors       | payor           | ${data.patient-read-id} |

  Scenario: Suche nach der Coverage anhand des Identifiers des beneficiaries (Chaining)
    Then Get FHIR resource at "http://fhirserver/Coverage/?beneficiary.identifier=${data.patient-read-identifier-system}%7C${data.patient-read-identifier-value}" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And element "beneficiary" in all bundle resources references resource with ID "${data.patient-read-id}"
    