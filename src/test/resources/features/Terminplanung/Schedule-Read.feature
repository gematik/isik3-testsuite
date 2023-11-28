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
      - die ID der korrespondierenden FHIR-Ressource zu diesem Testdatensatz muss in der terminplanung.yaml eingegeben worden sein.

      Legen Sie den folgenden Kalender in Ihrem System an:
      Status: aktiv
      Behandlungstyp: Neurologie
      Fachrichtung: Neurologie
      Akteur: Beliebig (Bitte ID im terminplanung.yaml eingeben)
      Name: Kalender
    """

  Scenario: Read und Validierung des CapabilityStatements
    Then Get FHIR resource at "http://fhirserver/metadata" with content type "json"
    And FHIR current response body evaluates the FHIRPath 'rest.where(mode = "server").resource.where(type = "Schedule" and interaction.where(code = "read").exists()).exists()'

  Scenario: Read eines Kalenders anhand der ID
    Then Get FHIR resource at "http://fhirserver/Schedule/${data.schedule-read-id}" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'id.replaceMatches("/_history/.+","").matches("${data.schedule-read-id}")' with error message 'ID der Ressource entspricht nicht der angeforderten ID'
    And FHIR current response body is a valid CORE resource and conforms to profile "http://hl7.org/fhir/StructureDefinition/Schedule"
    And FHIR current response body is a valid ISIK3 resource and conforms to profile "https://gematik.de/fhir/isik/v3/Terminplanung/StructureDefinition/ISiKKalender"
    And TGR current response with attribute "$..active.value" matches "true"
    And FHIR current response body evaluates the FHIRPath "serviceType.coding.where(code='177' and system = 'http://terminology.hl7.org/CodeSystem/service-type').exists()" with error message 'Der Typ des Kalenders entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "specialty.coding.where(code = '142' and system ='urn:oid:1.2.276.0.76.5.114').exists()" with error message 'Die Fachrichtung entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "actor.where(reference.replaceMatches('/_history/.+','').matches('${data.practitioner-read-id}') and display.exists()).exists()" with error message 'Der Akteur ist nicht vollständig vorhanden'
    And FHIR current response body evaluates the FHIRPath "extension.where(url = 'http://hl7.org/fhir/5.0/StructureDefinition/extension-Schedule.name' and value = 'Kalender').exists()" with error message 'Der Name entspricht nicht dem Erwartungswert'
