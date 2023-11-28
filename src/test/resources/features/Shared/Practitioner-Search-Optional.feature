@basis
@medikation
@terminplanung
@optional
@Practitioner-Search-Optional
Feature: Lesen der Ressource Practitioner (@Practitioner-Search-Optional)

  @vorbedingung
  Scenario: Vorbedingung
    Given Testbeschreibung: "Das zu testende System MUSS die zuvor angelegte Ressource bei einer Suche anhand des Parameters finden und in den Suchergebnissen zurückgeben (SEARCH)."
    Given Mit den Vorbedingungen:
    """
      - Der Testfall Practitioner-Read muss zuvor erfolgreich ausgeführt worden sein.
    """

  Scenario: Read und Validierung des CapabilityStatements
    Then Get FHIR resource at "http://fhirserver/metadata" with content type "xml"
    And FHIR current response body evaluates the FHIRPaths:
    """
      rest.where(mode = "server").resource.where(type = "Practitioner" and interaction.where(code = "search-type").exists()).exists()
    """

  Scenario Outline: Validierung des CapabilityStatements von <searchParamValue>
    And FHIR current response body evaluates the FHIRPaths:
    """
      rest.where(mode = "server").resource.where(type = "Practitioner" and searchParam.where(name = "<searchParamValue>" and type = "<searchParamType>").exists()).exists()
    """

    Examples:
      | searchParamValue | searchParamType |
      | name             | string          |
      | _profile         | uri             |
      | address          | string          |
      | gender           | token           |

  Scenario: Suche der Practitioner-Ressource anhand des Namens
    Then Get FHIR resource at "http://fhirserver/Practitioner/?name=Musterarzt" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.where(id.replaceMatches('/_history/.+','').matches('${data.practitioner-read-id}')).count() = 1" with error message 'Die gesuchte Person im Gesundheitswesen ${data.practitioner-read-id} ist nicht im Responsebundle enthalten'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(name.family contains 'Musterarzt')" with error message 'Es gibt Suchergebnisse, die nicht dem Kriterium entsprechen'
    And FHIR current response body is a valid CORE resource and conforms to profile "https://hl7.org/fhir/StructureDefinition/Bundle"
    And Check if current response of resource "Practitioner" is valid ISIK3 and conforms to profile "https://gematik.de/fhir/isik/v3/Basismodul/StructureDefinition/ISiKPersonImGesundheitsberuf"

  Scenario: Suche der Practitioner-Ressource anhand der Adresse
    Then Get FHIR resource at "http://fhirserver/Practitioner/?address:contains=Musterweg" with content type "json"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(address.where(line.contains('Musterweg')).count()=1)" with error message 'Es gibt Suchergebnisse, die nicht dem Kriterium entsprechen'

  Scenario: Suche der Practitioner-Ressource anhand des Geschlechts
    Then Get FHIR resource at "http://fhirserver/Practitioner/?gender=male" with content type "json"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(gender = 'male')" with error message 'Es gibt Suchergebnisse, die nicht dem Kriterium entsprechen'

  Scenario: Suche der Practitioner-Ressource anhand des Profils
    Then Get FHIR resource at "http://fhirserver/Practitioner/?_profile=https://gematik.de/fhir/isik/v3/Basismodul/StructureDefinition/ISiKPersonImGesundheitsberuf" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(meta.profile = 'https://gematik.de/fhir/isik/v3/Basismodul/StructureDefinition/ISiKPersonImGesundheitsberuf')" with error message 'Es gibt Suchergebnisse, die nicht dem Kriterium entsprechen'
