@terminplanung
@mandatory
@Appointment-Search
Feature: Testen von Suchparametern gegen die Appointment Ressource (@Appointment-Search)

  @vorbedingung
  Scenario: Vorbedingung
    Given Testbeschreibung: "Das zu testende System MUSS die zuvor angelegte Ressource bei einer Suche anhand des Parameters finden und in den Suchergebnissen zurückgeben (SEARCH)."
    Given Mit den Vorbedingungen:
    """
      - Der Testfall Appointment-Read muss zuvor erfolgreich ausgeführt worden sein.
    """

  Scenario: Read und Validierung des CapabilityStatements
    Then Get FHIR resource at "http://fhirserver/metadata" with content type "json"
    And FHIR current response body evaluates the FHIRPaths:
    """
      rest.where(mode = "server").resource.where(type = "Appointment" and interaction.where(code = "search-type").exists()).exists()
    """

  Scenario Outline: Validierung der Suchparameter-Definitionen im CapabilityStatement
    And FHIR current response body evaluates the FHIRPaths:
    """
      rest.where(mode = "server").resource.where(type = "Appointment" and searchParam.where(name = "<searchParamValue>" and type = "<searchParamType>").exists()).exists()
    """

    Examples:
      | searchParamValue | searchParamType |
      | _id              | token           |
      | status           | token           |
      | service-type     | token           |
      | specialty        | token           |
      | date             | date            |
      | slot             | reference       |
      | actor            | reference       |

  Scenario: Suche nach dem Termin anhand der ID
    Then Get FHIR resource at "http://fhirserver/Appointment/?_id=${data.appointment-read-id}" with content type "xml"
    And response bundle contains resource with ID "${data.appointment-read-id}" with error message "Der gesuchte Termin ${data.appointment-read-id} ist nicht im Responsebundle enthalten"
    And Check if current response of resource "Appointment" is valid isik3-terminplanung resource and conforms to profile "https://gematik.de/fhir/isik/v3/Terminplanung/StructureDefinition/ISiKTermin"

  Scenario: Suche nach dem Termin anhand des Status
    Then Get FHIR resource at "http://fhirserver/Appointment/?status=cancelled" with content type "json"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(status = 'cancelled')" with error message 'Es gibt Suchergebnisse, diese passen allerdings nicht vollständig zu den Suchkriterien.'

  Scenario: Suche nach dem Termin anhand des Behandlungstyp
    Then Get FHIR resource at "http://fhirserver/Appointment/?service-type=${data.schedule-read-servicetype-code}" with content type "json"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(serviceType.coding.where(code='${data.schedule-read-servicetype-code}' and system='${data.schedule-read-servicetype-system}').exists())" with error message 'Es gibt Suchergebnisse, diese passen allerdings nicht vollständig zu den Suchkriterien.'

  Scenario: Suche nach dem Termin anhand der Fachrichtung
    Then Get FHIR resource at "http://fhirserver/Appointment/?specialty=142" with content type "json"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(specialty.coding.where(code='142' and system='urn:oid:1.2.276.0.76.5.114').exists())" with error message 'Es gibt Suchergebnisse, diese passen allerdings nicht vollständig zu den Suchkriterien.'

  Scenario: Suche nach dem Termin anhand des Datums
    Then Get FHIR resource at "http://fhirserver/Appointment/?date=${data.slot-read-start}" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    # The OR expression enables configuration of both full and partial date time values with different precision, e.g. slot-read-start: 2024-01-01, 2024-01-01T13:00:00, 2024-01-01T13:00:00.000, 2024-01-01T13:00:00+01:00
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(start.toString().contains('${data.slot-read-start}') or start ~ @${data.slot-read-start})" with error message 'Es gibt Suchergebnisse, diese passen allerdings nicht vollständig zu den Suchkriterien.'

  Scenario: Suche nach dem Termin anhand des Terminblocks
    Then Get FHIR resource at "http://fhirserver/Appointment/?slot=${data.slot-read-id}" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(slot.where(reference.replaceMatches('/_history/.+','').matches('\\b${data.slot-read-id}$')).exists())" with error message 'Es gibt Suchergebnisse, diese passen allerdings nicht vollständig zu den Suchkriterien.'

  Scenario: Suche nach dem Termin anhand des Akteurs
    Then Get FHIR resource at "http://fhirserver/Appointment/?actor=Patient/${data.terminplanung-patient-id}" with content type "json"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(participant.where(actor.where(reference.replaceMatches('/_history/.+','').matches('\\b${data.terminplanung-patient-id}$') and display.exists()).exists()).exists())" with error message 'Es gibt Suchergebnisse, diese passen allerdings nicht vollständig zu den Suchkriterien.'
