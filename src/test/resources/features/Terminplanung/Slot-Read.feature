@terminplanung
@mandatory
@Slot-Read
Feature: Lesen der Ressource Slot (@Slot-Read)

  @vorbedingung
  Scenario: Vorbedingung
    Given Testbeschreibung: "Das zu testende System MUSS die angelegte Ressource bei einem HTTP GET auf deren URL korrekt und vollständig zurückgeben (READ)."
    Given Mit den Vorbedingungen:
    """
      - der Testdatensatz muss im zu testenden System gemäß der Vorgaben (manuell) erfasst worden sein.
      - die ID der korrespondierenden FHIR-Ressource zu diesem Testdatensatz muss in der Konfigurationsvariable 'slot-read-id' hinterlegt sein.

      Legen Sie den folgenden Terminblock in Ihrem System an:
      Status: Belegt
      Startzeitpunkt: Beliebig in der Zukunft (bitte in der Konfigurationsvariable 'slot-read-start' angeben)
      Endzeitpunkt: Beliebig in der Zukunft
      Kalender: Der Kalender aus Testfall Schedule-Read
    """

  Scenario: Read und Validierung des CapabilityStatements
    Then Get FHIR resource at "http://fhirserver/metadata" with content type "json"
    And CapabilityStatement contains interaction "read" for resource "Slot"

  Scenario: Read eines Terminblocks anhand der ID
    Then Get FHIR resource at "http://fhirserver/Slot/${data.slot-read-id}" with content type "xml"
    And resource has ID "${data.slot-read-id}"
    And FHIR current response body is a valid isik3-terminplanung resource and conforms to profile "https://gematik.de/fhir/isik/v3/Terminplanung/StructureDefinition/ISiKTerminblock"
    And TGR current response with attribute "$..status.value" matches "busy"
    And element "schedule" references resource with ID "${data.schedule-read-id}" with error message "Der referenzierte Kalender ist nicht korrekt"
    # /The OR expression enables configuration of both full and partial date time values with different precision, e.g. slot-read-start: 2024-01-01, 2024-01-01T13:00:00, 2024-01-01T13:00:00.000, 2024-01-01T13:00:00+01:00
    And FHIR current response body evaluates the FHIRPath "start.toString().contains('${data.slot-read-start}') or start ~ @${data.slot-read-start}" with error message 'Der Startzeitpunkt des Terminblocks entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "end.empty().not()" with error message 'Der Endzeitpunkt des Terminblocks ist nicht angegeben'