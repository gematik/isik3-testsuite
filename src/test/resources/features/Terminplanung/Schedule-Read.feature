@terminplanung
@mandatory
@Schedule-Read
Feature: Lesen der Ressource Schedule (@Schedule-Read)

  @vorbedingung
  Scenario: Vorbedingung
    Given Testbeschreibung: "Das zu testende System MUSS die angelegte Ressource bei einem HTTP GET auf deren URL korrekt und vollständig zurückgeben (READ)."
    Given Mit den Vorbedingungen:
    """
      - der Testdatensatz muss im zu testenden System gemäß der Vorgaben (manuell) erfasst worden sein.
      - die ID der korrespondierenden FHIR-Ressource zu diesem Testdatensatz muss in der Konfigurationsvariable 'schedule-read-id' hinterlegt sein.

      Legen Sie den folgenden Kalender in Ihrem System an:
      Status: aktiv
      Behandlungstyp: Beliebig (bitte das CodeSystem und den Code in den Konfigurationsvariablen 'schedule-read-servicetype-system' und 'schedule-read-servicetype-code' angeben)
      Fachrichtung: Neurologie
      Akteur: Beliebig (die verknüpfte Practitioner-Ressource muss konform zu ISiKPersonImGesundheitsberuf sein, Bitte ID in der Konfigurationsvariable 'terminplanung-practitioner-id' angeben)
      Name: Kalender
    """

  Scenario: Read und Validierung des CapabilityStatements
    Then Get FHIR resource at "http://fhirserver/metadata" with content type "json"
    And CapabilityStatement contains interaction "read" for resource "Schedule"

  Scenario: Read eines Kalenders anhand der ID
    Then Get FHIR resource at "http://fhirserver/Schedule/${data.schedule-read-id}" with content type "xml"
    And resource has ID "${data.schedule-read-id}"
    And FHIR current response body is a valid isik3-terminplanung resource and conforms to profile "https://gematik.de/fhir/isik/v3/Terminplanung/StructureDefinition/ISiKKalender"
    And TGR current response with attribute "$..active.value" matches "true"
    And FHIR current response body evaluates the FHIRPath "serviceType.coding.where(code='${data.schedule-read-servicetype-code}' and system = '${data.schedule-read-servicetype-system}').exists()" with error message 'Der Typ des Kalenders entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "specialty.coding.where(code = '142' and system ='urn:oid:1.2.276.0.76.5.114').exists()" with error message 'Die Fachrichtung entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "actor.where(reference.replaceMatches('/_history/.+','').matches('\\b${data.terminplanung-practitioner-id}$') and display.exists()).exists()" with error message 'Der Akteur ist nicht vollständig vorhanden'
    And FHIR current response body evaluates the FHIRPath "extension.where(url = 'http://hl7.org/fhir/5.0/StructureDefinition/extension-Schedule.name' and value = 'Kalender').exists()" with error message 'Der Name entspricht nicht dem Erwartungswert'
