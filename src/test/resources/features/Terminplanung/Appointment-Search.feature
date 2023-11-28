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

  Scenario Outline: Validierung des CapabilityStatements für <searchParamValue>
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
    And FHIR current response body evaluates the FHIRPath 'entry.resource.where(id.replaceMatches("/_history/.+","").matches("${data.appointment-read-id}")).count()=1' with error message 'Der gesuchte Termin ${data.appointment-read-id} ist nicht im Responsebundle enthalten'
    And FHIR current response body is a valid CORE resource and conforms to profile "https://hl7.org/fhir/StructureDefinition/Bundle"
    And Check if current response of resource "Appointment" is valid ISIK3 and conforms to profile "https://gematik.de/fhir/isik/v3/Terminplanung/StructureDefinition/ISiKTermin"

  Scenario: Suche nach dem Termin anhand des Status
    Then Get FHIR resource at "http://fhirserver/Appointment/?status=cancelled" with content type "json"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(status = 'cancelled')" with error message 'Es gibt Suchergebnisse, die nicht dem Kriterium entsprechen'

  Scenario: Suche nach dem Termin anhand des Behandlungstyp
    Then Get FHIR resource at "http://fhirserver/Appointment/?service-type=177" with content type "json"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(serviceType.coding.where(code='177' and system='http://terminology.hl7.org/CodeSystem/service-type').exists())" with error message 'Es gibt Suchergebnisse, die nicht dem Kriterium entsprechen'

  Scenario: Suche nach dem Termin anhand der Fachrichtung
    Then Get FHIR resource at "http://fhirserver/Appointment/?specialty=142" with content type "json"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(specialty.coding.where(code='142' and system='urn:oid:1.2.276.0.76.5.114').exists())" with error message 'Es gibt Suchergebnisse, die nicht dem Kriterium entsprechen'

  Scenario: Suche nach dem Termin anhand des Datums
    Then Get FHIR resource at "http://fhirserver/Appointment/?date=2023-01-01T13:00:00Z" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(start.toString().contains('2023-01-01T13:00:00'))" with error message 'Es gibt Suchergebnisse, die nicht dem Kriterium entsprechen'

  Scenario: Suche nach dem Termin anhand des Terminblocks
    Then Get FHIR resource at "http://fhirserver/Appointment/?slot=${data.slot-read-id}" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(slot.where(reference.replaceMatches('/_history/.+','').matches('${data.slot-read-id}')).exists())" with error message 'Es gibt Suchergebnisse, die nicht dem Kriterium entsprechen'

  Scenario: Suche nach dem Termin anhand des Akteurs
    Then Get FHIR resource at "http://fhirserver/Appointment/?actor=Patient/${data.patient-read-id}" with content type "json"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(participant.where(actor.where(reference.replaceMatches('/_history/.+','').matches('${data.patient-read-id}') and display.exists()).exists()).exists())" with error message 'Es gibt Suchergebnisse, die nicht dem Kriterium entsprechen'
