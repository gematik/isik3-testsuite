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
      - die ID der korrespondierenden FHIR-Ressource zu diesem Testdatensatz muss im terminplanung.yaml eingegeben worden sein.

      Legen Sie den folgenden Terminblock in Ihrem System an:
      Status: Belegt
      Startzeitpunkt: 01.01.2023 13 Uhr
      Endzeitpunkt: 01.01.2023 14 Uhr
      Kalender: Beliebig (Bitte ID im terminplanung.yaml eingeben)
    """

  Scenario: Read und Validierung des CapabilityStatements
    Then Get FHIR resource at "http://fhirserver/metadata" with content type "json"
    And FHIR current response body evaluates the FHIRPath 'rest.where(mode = "server").resource.where(type = "Slot" and interaction.where(code = "read").exists()).exists()'

  Scenario: Read eines Terminblocks anhand der ID
    Then Get FHIR resource at "http://fhirserver/Slot/${data.slot-read-id}" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'id.replaceMatches("/_history/.+","").matches("${data.slot-read-id}")' with error message 'ID der Ressource entspricht nicht der angeforderten ID'
    And FHIR current response body is a valid CORE resource and conforms to profile "http://hl7.org/fhir/StructureDefinition/Slot"
    And FHIR current response body is a valid ISIK3 resource and conforms to profile "https://gematik.de/fhir/isik/v3/Terminplanung/StructureDefinition/ISiKTerminblock"
    And TGR current response with attribute "$..status.value" matches "busy"
    And FHIR current response body evaluates the FHIRPath "schedule.where(reference.replaceMatches('/_history/.+','').matches('${data.schedule-read-id}')).exists()" with error message 'Der referenzierte Kalender ist nicht korrekt'
    And FHIR current response body evaluates the FHIRPath "start.toString().contains('2023-01-01T13:00:00')" with error message 'Der Startzeitpunkt des Terminblocks entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "end.toString().contains('2023-01-01T14:00:00')" with error message 'Der Endzeitpunkt des Terminblocks entspricht nicht dem Erwartungswert'
