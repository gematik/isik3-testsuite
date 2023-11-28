@basis
@dokumentenaustausch
@medikation
@vitalparameter
@optional
@Account-Search-Optional
Feature: Testen von KANN-Suchparametern gegen die Account Ressource (@Account-Search-Optional)

  @vorbedingung
  Scenario: Vorbedingung
    Given Testbeschreibung: "Das zu testende System MUSS die zuvor angelegte Ressource bei einer Suche anhand des Parameters finden und in den Suchergebnissen zurückgeben (SEARCH)."
    Given Mit den Vorbedingungen:
    """
      - Der Testfall Account-Read muss zuvor erfolgreich ausgeführt worden sein.
    """

  Scenario: Read und Validierung des CapabilityStatements
    Then Get FHIR resource at "http://fhirserver/metadata" with content type "xml"
    And FHIR current response body evaluates the FHIRPaths:
    """
      rest.where(mode = "server").resource.where(type = "Account" and interaction.where(code = "search-type").exists()).exists()
      rest.where(mode = "server").resource.where(type = "Account" and searchParam.where(name = "_profile" and type = "uri").exists()).exists()
    """

  Scenario: Suche nach dem Account anhand des Profils
    Then Get FHIR resource at "http://fhirserver/Account/?_profile=https://gematik.de/fhir/isik/v3/Basismodul/StructureDefinition/ISiKAbrechnungsfall" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(meta.profile.contains('https://gematik.de/fhir/isik/v3/Basismodul/StructureDefinition/ISiKAbrechnungsfall'))" with error message 'Es gibt Suchergebnisse, die nicht dem Kriterium entsprechen'
