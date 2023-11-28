@basis
@optional
@Procedure-Search-Optional
Feature: Testen von  KANN-Suchparametern (@Procedure-Search-Optional)

  @vorbedingung
  Scenario: Vorbedingung
    Given Testbeschreibung: "Das zu testende System MUSS die zuvor angelegte Ressource bei einer Suche anhand des Parameters finden und in den Suchergebnissen zurückgeben (SEARCH)."
    Given Mit den Vorbedingungen:
    """
      - der Testdatensatz muss im zu testenden System gemäß der Vorgaben (manuell) erfasst worden sein. Erfassen Sie folgende Prozedur.

      Testdatensatz (Name: Wert)
      Profil: ISiK-Prozedur
      Rest: Beliebig"
    """

  Scenario: Read und Validierung des CapabilityStatements
    Then Get FHIR resource at "http://fhirserver/metadata" with content type "xml"
    And FHIR current response body evaluates the FHIRPaths:
    """
      rest.where(mode = "server").resource.where(type = "Procedure" and interaction.where(code = "search-type").exists()).exists()
      rest.where(mode = "server").resource.where(type = "Procedure" and searchParam.where(name = "_profile" and type = "uri").exists()).exists()
    """

  Scenario: Suche der Diagnose anhand des Profils
    Then Get FHIR resource at "http://fhirserver/Procedure/?_profile=https://gematik.de/fhir/isik/v3/Basismodul/StructureDefinition/ISiKProzedur" with content type "xml"
    And FHIR current response body is a valid CORE resource and conforms to profile "https://hl7.org/fhir/StructureDefinition/Bundle"
    And Check if current response of resource "Procedure" is valid ISIK3 and conforms to profile "https://gematik.de/fhir/isik/v3/Basismodul/StructureDefinition/ISiKProzedur"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(meta.profile.contains('https://gematik.de/fhir/isik/v3/Basismodul/StructureDefinition/ISiKProzedur'))" with error message 'Es gibt Suchergebnisse, die nicht dem Kriterium entsprechen'
