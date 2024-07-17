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
    And response bundle contains resource with ID "${data.slot-read-id}" with error message "Der gesuchte Slot ${data.slot-read-id} ist nicht im Responsebundle enthalten"
    And FHIR current response body is a valid CORE resource and conforms to profile "https://hl7.org/fhir/StructureDefinition/Bundle"
    And Check if current response of resource "Slot" is valid isik3-terminplanung resource and conforms to profile "https://gematik.de/fhir/isik/v3/Terminplanung/StructureDefinition/ISiKTerminblock"

  Scenario: Suche nach dem Termin anhand des Kalenders
    Then Get FHIR resource at "http://fhirserver/Slot/?schedule=${data.schedule-read-id}" with content type "json"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(schedule.where(reference.replaceMatches('/_history/.+','').matches('\\b${data.schedule-read-id}$')).exists())" with error message 'Es gibt Suchergebnisse, diese passen allerdings nicht vollständig zu den Suchkriterien.'

  Scenario: Suche nach dem Termin anhand des Status
    Then Get FHIR resource at "http://fhirserver/Slot/?schedule=${data.schedule-read-id}&status=busy" with content type "json"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(status = 'busy')" with error message 'Es gibt Suchergebnisse, diese passen allerdings nicht vollständig zu den Suchkriterien.'

  Scenario: Suche nach dem Termin anhand des Behandlungsstarts
    Then Get FHIR resource at "http://fhirserver/Slot/?schedule=${data.schedule-read-id}&start=${data.slot-read-start}" with content type "json"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    # The OR expression enables configuration of both full and partial date time values with different precision, e.g. slot-read-start: 2024-01-01, 2024-01-01T13:00:00, 2024-01-01T13:00:00.000, 2024-01-01T13:00:00+01:00
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(start.toString().contains('${data.slot-read-start}') or start ~ @${data.slot-read-start})" with error message 'Es gibt Suchergebnisse, diese passen allerdings nicht vollständig zu den Suchkriterien.'

  Scenario: Chaining-Suche nach den Slots anhand des Behandlers
    Then Get FHIR resource at "http://fhirserver/Slot/?schedule.actor=Practitioner/${data.terminplanung-practitioner-id}" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.where(id.replaceMatches("/_history/.+","").matches("\\b${data.slot-read-id}$")).exists()' with error message 'Der gesuchte Slot ${data.slot-read-id} ist nicht im Responsebundle enthalten'