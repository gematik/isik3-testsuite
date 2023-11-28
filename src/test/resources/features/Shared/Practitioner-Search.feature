@basis
@medikation
@terminplanung
@mandatory
@Practitioner-Search
Feature: Lesen der Ressource Practitioner (@Practitioner-Search)

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
      | _id              | token           |
      | identifier       | token           |
      | given            | string          |
      | family           | string          |

  Scenario: Suche der Practitioner-Ressource anhand der ID
    Then Get FHIR resource at "http://fhirserver/Practitioner/?_id=${data.practitioner-read-id}" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.where(id.replaceMatches("/_history/.+","").matches("${data.practitioner-read-id}")).count() = 1' with error message 'Die gesuchte Pracitioner-Ressource ${data.practitioner-read-id} ist nicht im Responsebundle enthalten'
    And FHIR current response body is a valid CORE resource and conforms to profile "https://hl7.org/fhir/StructureDefinition/Bundle"
    And Check if current response of resource "Practitioner" is valid ISIK3 and conforms to profile "https://gematik.de/fhir/isik/v3/Basismodul/StructureDefinition/ISiKPersonImGesundheitsberuf"

  Scenario: Suche der Practitioner-Ressource anhand der LANR
    Then Get FHIR resource at "http://fhirserver/Practitioner/?identifier=https://fhir.kbv.de/NamingSystem/KBV_NS_Base_ANR%7C123456789" with content type "json"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.where(id.replaceMatches('/_history/.+','').matches('${data.practitioner-read-id}')).count()=1" with error message 'Die gesuchte Pracitioner-Ressource ${data.practitioner-read-id} ist nicht im Responsebundle enthalten'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(identifier.where(system='https://fhir.kbv.de/NamingSystem/KBV_NS_Base_ANR' and value='123456789').exists())" with error message 'Es gibt Suchergebnisse, die nicht dem Kriterium entsprechen'

  Scenario: Suche der Practitioner-Ressource anhand des Vornamens
    Then Get FHIR resource at "http://fhirserver/Practitioner/?given=Walter" with content type "json"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(name.given.where($this.startsWith('Walter')).exists())" with error message 'Es gibt Suchergebnisse, die nicht dem Kriterium entsprechen'

  Scenario: Suche der Practitioner-Ressource anhand des Nachnamens
    Then Get FHIR resource at "http://fhirserver/Practitioner/?family=Musterarzt" with content type "json"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(name.family.where($this.startsWith('Musterarzt')).exists())" with error message 'Es gibt Suchergebnisse, die nicht dem Kriterium entsprechen'

  Scenario: Suche der Practitioner-Ressource anhand des Vornamens (Negativtest)
    Then Get FHIR resource at "http://fhirserver/Practitioner/?given=Max" with content type "xml"
    And FHIR current response body evaluates the FHIRPath "entry.resource.where(id.replaceMatches('/_history/.+','').matches('${data.practitioner-read-id}')).count()=0" with error message 'Die  Ressource ${data.practitioner-id} darf hier nicht zurückgegeben werden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(name.given.where($this.startsWith('Max')).exists())" with error message 'Es gibt Suchergebnisse, die nicht dem Kriterium entsprechen'
