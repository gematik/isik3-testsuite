@basis
@optional
@Coverage-Search-Private-Optional
Feature: Testen von KANN-Suchparametern gegen coverage-read-private (@Coverage-Search-Private-Optional)

  @vorbedingung
  Scenario: Vorbedingung
    Given Testbeschreibung: "Das zu testende System MUSS die zuvor angelegte Ressource bei einer Suche anhand des Parameters finden und in den Suchergebnissen zurückgeben (SEARCH)."
    Given Mit den Vorbedingungen:
    """
      - Der Testfall Coverage-Read-Private muss zuvor erfolgreich ausgeführt worden sein.
    """

  Scenario: Read und Validierung des CapabilityStatements
    Then Get FHIR resource at "http://fhirserver/metadata" with content type "json"
    And FHIR current response body evaluates the FHIRPath 'rest.where(mode = "server").resource.where(type = "Coverage" and interaction.where(code = "read").exists()).exists()'
    And FHIR current response body evaluates the FHIRPaths:
    """
      rest.where(mode = "server").resource.where(type = "Coverage" and interaction.where(code = "search-type").exists()).exists()
      rest.where(mode = "server").resource.where(type = "Coverage" and searchParam.where(name = "subscriber" and type = "reference").exists()).exists()
      rest.where(mode = "server").resource.where(type = "Coverage" and searchParam.where(name = "status" and type = "token").exists()).exists()
      rest.where(mode = "server").resource.where(type = "Coverage" and searchParam.where(name = "type" and type = "token").exists()).exists()
      rest.where(mode = "server").resource.where(type = "Coverage" and searchParam.where(name = "_profile" and type = "uri").exists()).exists()
    """

  Scenario: Suche der Coverage anhand des Status
    Then Get FHIR resource at "http://fhirserver/Coverage/?status=active" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(status = 'active')" with error message 'Es gibt Suchergebnisse, die nicht dem Kriterium entsprechen'

    And FHIR current response body is a valid CORE resource and conforms to profile "https://hl7.org/fhir/StructureDefinition/Bundle"
    And Check if current response of resource "Coverage" is valid ISIK3 and conforms to profile "https://gematik.de/fhir/isik/v3/Basismodul/StructureDefinition/ISiKVersicherungsverhaeltnisSelbstzahler"

  Scenario: Suche der Coverage anhand der Art der Versicherung
    Then Get FHIR resource at "http://fhirserver/Coverage/?type=http://fhir.de/CodeSystem/versicherungsart-de-basis%7CSEL" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(type.coding.where(system = 'http://fhir.de/CodeSystem/versicherungsart-de-basis').code = 'SEL')" with error message 'Es gibt Suchergebnisse, die nicht dem Kriterium entsprechen'

  Scenario: Suche der Coverage anhand des Profils
    Then Get FHIR resource at "http://fhirserver/Coverage/?_profile=https://gematik.de/fhir/isik/v3/Basismodul/StructureDefinition/ISiKVersicherungsverhaeltnisSelbstzahler" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(meta.profile = 'https://gematik.de/fhir/isik/v3/Basismodul/StructureDefinition/ISiKVersicherungsverhaeltnisSelbstzahler')" with error message 'Es wurden keine Suchergebnisse gefunden'
