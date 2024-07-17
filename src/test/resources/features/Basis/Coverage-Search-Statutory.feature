@basis
@mandatory
@Coverage-Search-Statutory
Feature: Testen von Suchparametern gegen coverage-read-private (@Coverage-Search-Statutory)

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
      rest.where(mode = "server").resource.where(type = "Coverage" and searchParam.where(name = "identifier" and type = "token").exists()).exists()
      rest.where(mode = "server").resource.where(type = "Coverage" and searchParam.where(name = "status" and type = "token").exists()).exists()
      rest.where(mode = "server").resource.where(type = "Coverage" and searchParam.where(name = "type" and type = "token").exists()).exists()
      rest.where(mode = "server").resource.where(type = "Coverage" and searchParam.where(name = "beneficiary" and type = "reference").exists()).exists()
      rest.where(mode = "server").resource.where(type = "Coverage" and searchParam.where(name = "patient" and type = "reference").exists()).exists()
      rest.where(mode = "server").resource.where(type = "Coverage" and searchParam.where(name = "payor" and type = "reference").exists()).exists()
    """

  Scenario: Suche der Coverage-Ressource anhand der ID
    Then Get FHIR resource at "http://fhirserver/Coverage/?_id=${data.coverage-read-statutory-id}" with content type "xml"
    And response bundle contains resource with ID "${data.coverage-read-statutory-id}" with error message "Die gesuchte Diagnose {{coverage-read-statutory-id}} ist nicht im Responsebundle enthalten"
    And FHIR current response body is a valid CORE resource and conforms to profile "https://hl7.org/fhir/StructureDefinition/Bundle"
    And Check if current response of resource "Coverage" is valid isik3-basismodul resource and conforms to profile "https://gematik.de/fhir/isik/v3/Basismodul/StructureDefinition/ISiKVersicherungsverhaeltnisGesetzlich"

  Scenario: Suche nach der Coverage anhand der Versichertennummer
    Then Get FHIR resource at "http://fhirserver/Coverage/?identifier=http://fhir.de/sid/gkv/kvid-10%7CX485231029" with content type "json"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(identifier.where(system='http://fhir.de/sid/gkv/kvid-10' and value='X485231029').exists())" with error message 'Es gibt Suchergebnisse, diese passen allerdings nicht vollständig zu den Suchkriterien.'

  Scenario: Suche nach der Coverage anhand des status
    Then Get FHIR resource at "http://fhirserver/Coverage/?status=active" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(status='active')" with error message 'Es gibt Suchergebnisse, diese passen allerdings nicht vollständig zu den Suchkriterien.'

  Scenario: Suche nach der Coverage anhand des types
    Then Get FHIR resource at "http://fhirserver/Coverage/?type=GKV" with content type "json"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(type.coding.code='GKV')" with error message 'Es gibt Suchergebnisse, diese passen allerdings nicht vollständig zu den Suchkriterien.'

  Scenario: Suche nach der Coverage anhand des beneficiarys
    Then Get FHIR resource at "http://fhirserver/Coverage/?beneficiary=${data.patient-read-id}" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And element "beneficiary" in all bundle resources references resource with ID "${data.patient-read-id}"

  Scenario: Suche nach der Coverage anhand des types (Negativtest)
    Then Get FHIR resource at "http://fhirserver/Coverage/?type=SEL" with content type "json"
    And bundle does not contain resource "Coverage" with ID "${data.coverage-read-statutory-id}" with error message "Es gibt Suchergebnisse, diese passen allerdings nicht vollständig zu den Suchkriterien."
    And FHIR current response body evaluates the FHIRPath "entry.resource.ofType(Coverage).all(type.coding.code='SEL')" with error message 'Es gibt Suchergebnisse, diese passen allerdings nicht vollständig zu den Suchkriterien.'
