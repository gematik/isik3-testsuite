@terminplanung
@mandatory
@Schedule-Search
Feature: Testen von Suchparametern gegen die Schedule Ressource (@Schedule-Search)

  @vorbedingung
  Scenario: Vorbedingung
    Given Testbeschreibung: "Das zu testende System MUSS die zuvor angelegte Ressource bei einer Suche anhand des Parameters finden und in den Suchergebnissen zurückgeben (SEARCH)."
    Given Mit den Vorbedingungen:
    """
      - Der Testfall Schedule-Read muss zuvor erfolgreich ausgeführt worden sein.
    """

  Scenario: Read und Validierung des CapabilityStatements
    Then Get FHIR resource at "http://fhirserver/metadata" with content type "xml"
    And FHIR current response body evaluates the FHIRPaths:
    """
      rest.where(mode = "server").resource.where(type = "Schedule" and interaction.where(code = "search-type").exists()).exists()
    """

  Scenario Outline: Validierung der Suchparameter-Definitionen im CapabilityStatement
    And FHIR current response body evaluates the FHIRPaths:
    """
      rest.where(mode = "server").resource.where(type = "Schedule" and searchParam.where(name = "<searchParamValue>" and type = "<searchParamType>").exists()).exists()
    """

    Examples:
      | searchParamValue | searchParamType |
      | _id              | token           |
      | active           | token           |
      | service-type     | token           |
      | specialty        | token           |
      | actor            | reference       |

  Scenario: Suche nach dem Schedule anhand der ID
    Then Get FHIR resource at "http://fhirserver/Schedule/?_id=${data.schedule-read-id}" with content type "xml"
    And response bundle contains resource with ID "${data.schedule-read-id}" with error message "Der gesuchte Schedule ${data.schedule-read-id} ist nicht im Responsebundle enthalten"
    And Check if current response of resource "Schedule" is valid isik3-terminplanung resource and conforms to profile "https://gematik.de/fhir/isik/v3/Terminplanung/StructureDefinition/ISiKKalender"

  Scenario: Suche nach dem Schedule anhand des Status
    Then Get FHIR resource at "http://fhirserver/Schedule/?active=true" with content type "json"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(active = 'true')" with error message 'Es gibt Suchergebnisse, diese passen allerdings nicht vollständig zu den Suchkriterien.'

  Scenario: Suche nach dem Schedule anhand des Behandlungstyp
    Then Get FHIR resource at "http://fhirserver/Schedule/?service-type=${data.schedule-read-servicetype-code}" with content type "json"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(serviceType.coding.where(code='${data.schedule-read-servicetype-code}').exists())" with error message 'Es gibt Suchergebnisse, diese passen allerdings nicht vollständig zu den Suchkriterien.'

  Scenario: Suche nach dem Schedule anhand der Fachrichtung
    Then Get FHIR resource at "http://fhirserver/Schedule/?specialty=142" with content type "json"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(specialty.coding.where(code='142' and system ='urn:oid:1.2.276.0.76.5.114').exists())" with error message 'Es gibt Suchergebnisse, diese passen allerdings nicht vollständig zu den Suchkriterien.'

  Scenario: Suche nach dem Schedule anhand des Akteurs
    Then Get FHIR resource at "http://fhirserver/Schedule/?actor=Practitioner/${data.terminplanung-practitioner-id}" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(actor.where(reference.replaceMatches('/_history/.+','').matches('\\b${data.terminplanung-practitioner-id}$') and display.exists()).exists())" with error message 'Es gibt Suchergebnisse, diese passen allerdings nicht vollständig zu den Suchkriterien.'
