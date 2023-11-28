@basis
@optional
@Condition-Search-Optional
Feature: Testen von  KANN-Suchparametern gegen condition-read-active (@Condition-Search-Optional)

  @vorbedingung
  Scenario: Vorbedingung
    Given Testbeschreibung: "Das zu testende System MUSS die zuvor angelegte Ressource bei einer Suche anhand des Parameters finden und in den Suchergebnissen zurückgeben (SEARCH)."
    Given Mit den Vorbedingungen:
    """
      - der Testdatensatz muss im zu testenden System gemäß der Vorgaben (manuell) erfasst worden sein.
      Erfassen Sie folgende Diagnose.

      Testdatensatz (Name: Wert)
      Profil: ISiK-Diagnose
      Kategorie: Diagnose im Rahmen eines Kontakts
      Rest: Beliebig"
    """

  Scenario: Read und Validierung des CapabilityStatements
    Then Get FHIR resource at "http://fhirserver/metadata" with content type "json"
    And FHIR current response body evaluates the FHIRPaths:
    """
      rest.where(mode = "server").resource.where(type = "Condition" and interaction.where(code = "search-type").exists()).exists()
      rest.where(mode = "server").resource.where(type = "Condition" and searchParam.where(name = "_profile" and type = "uri").exists()).exists()
      rest.where(mode = "server").resource.where(type = "Condition" and searchParam.where(name = "category" and type = "token").exists()).exists()
    """
    And FHIR current response body is a valid CORE resource and conforms to profile "https://hl7.org/fhir/StructureDefinition/Bundle"
    And Check if current response of resource "Condition" is valid ISIK3 and conforms to profile "https://gematik.de/fhir/isik/v3/Basismodul/StructureDefinition/ISiKDiagnose"

  Scenario: Suche der Diagnose anhand des Profils
    Then Get FHIR resource at "http://fhirserver/Condition/?_profile=https://gematik.de/fhir/isik/v3/Basismodul/StructureDefinition/ISiKDiagnose" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(meta.profile = 'https://gematik.de/fhir/isik/v3/Basismodul/StructureDefinition/ISiKDiagnose')" with error message 'Es gibt Suchergebnisse, die nicht dem Kriterium entsprechen'

  Scenario: Suche der Diagnose anhand des Profils
    Then Get FHIR resource at "http://fhirserver/Condition/?category=encounter-diagnosis" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath 'entry.resource.all(category.coding.where(code = "encounter-diagnosis").exists())' with error message 'Es gibt Suchergebnisse, die nicht dem Kriterium entsprechen'
