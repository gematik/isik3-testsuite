@terminplanung
@mandatory
@Slot-Search
Feature: Testen von Suchparametern gegen die Slot Ressource (@Slot-Search)

  @vorbedingung
  Scenario: Vorbedingung
    Given Testbeschreibung: "Das zu testende System MUSS die zuvor angelegte Ressource bei einer Suche anhand des Parameters finden und in den Suchergebnissen zurückgeben (SEARCH)."
    Given Mit den Vorbedingungen:
    """
      - Der Testfall Slot-Read muss zuvor erfolgreich ausgeführt worden sein.
    """

  Scenario: Read und Validierung des CapabilityStatements
    Then Get FHIR resource at "http://fhirserver/metadata" with content type "xml"
    And FHIR current response body evaluates the FHIRPaths:
    """
      rest.where(mode = "server").resource.where(type = "Slot" and interaction.where(code = "search-type").exists()).exists()
    """

  Scenario Outline: Validierung des CapabilityStatements für <searchParamValue>
    And FHIR current response body evaluates the FHIRPaths:
    """
      rest.where(mode = "server").resource.where(type = "Slot" and searchParam.where(name = "<searchParamValue>" and type = "<searchParamType>").exists()).exists()
    """

    Examples:
      | searchParamValue | searchParamType |
      | _id              | token           |
      | schedule         | reference       |
      | status           | token           |
      | start            | date            |

  Scenario: Suche nach dem Termin anhand der ID
    Then Get FHIR resource at "http://fhirserver/Slot/?_id=${data.slot-read-id}" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.where(id.replaceMatches("/_history/.+","").matches("${data.slot-read-id}")).count() = 1' with error message 'Der gesuchte Slot ${data.slot-read-id} ist nicht im Responsebundle enthalten'
    And FHIR current response body is a valid CORE resource and conforms to profile "https://hl7.org/fhir/StructureDefinition/Bundle"
    And Check if current response of resource "Slot" is valid ISIK3 and conforms to profile "https://gematik.de/fhir/isik/v3/Terminplanung/StructureDefinition/ISiKTerminblock"

  Scenario: Suche nach dem Termin anhand des Kalenders
    Then Get FHIR resource at "http://fhirserver/Slot/?schedule=${data.schedule-read-id}" with content type "json"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(schedule.where(reference.replaceMatches('/_history/.+','').matches('${data.schedule-read-id}')).exists())" with error message 'Es gibt Suchergebnisse, die nicht dem Kriterium entsprechen'

  Scenario: Suche nach dem Termin anhand des Status
    Then Get FHIR resource at "http://fhirserver/Slot/?status=busy" with content type "json"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(status = 'busy')" with error message 'Es gibt Suchergebnisse, die nicht dem Kriterium entsprechen'

  Scenario: Suche nach dem Termin anhand des Behandlungsstarts
    Then Get FHIR resource at "http://fhirserver/Slot/?start=2023-01-01" with content type "json"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(start.toString().contains('2023-01-01T13:00:00'))" with error message 'Es gibt Suchergebnisse, die nicht dem Kriterium entsprechen'
