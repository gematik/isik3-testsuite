@terminplanung
@mandatory
@Appointment-Read
Feature: Lesen der Ressource Appointment (@Appointment-Read)

  @vorbedingung
  Scenario: Vorbedingung
    Given Testbeschreibung: "Das zu testende System MUSS die angelegte Ressource bei einem HTTP GET auf deren URL korrekt und vollständig zurückgeben (READ)."
    Given Mit den Vorbedingungen:
    """
      - der Testdatensatz muss im zu testenden System gemäß der Vorgaben (manuell) erfasst worden sein.
      - die ID der korrespondierenden FHIR-Ressource zu diesem Testdatensatz muss in der Titus UI eingegeben worden sein.

      Legen Sie den folgenden Termin als Ersatz für einen beliebigen Termin in Ihrem System an:
      Quelle: Extern
      Assoziierte Nachricht: die Nachricht aus dem Testfall Communication-Read
      Ersetzter Termin: Beliebig
      Status: storniert
      Stornierungsgrund: Patient
      Behandlungstyp: Neurologie
      Fachrichtung: FA Neurologie
      Priorität: Normal
      Terminzeitpunkt: 01.01.2023 13:00-14:00 Uhr
      Referenzierter Terminblock: Der Terminblock aus Testfall Slot-Read
      Patientenanweisung: Bitte nüchtern erscheinen
      Teilnehmer: Der Patient aus Testfall Patient-Read (Mit Display Wert)
    """

  Scenario: Read und Validierung des CapabilityStatements
    Then Get FHIR resource at "http://fhirserver/metadata" with content type "json"
    And FHIR current response body evaluates the FHIRPath 'rest.where(mode = "server").resource.where(type = "Appointment" and interaction.where(code = "read").exists()).exists()'

  Scenario: Read eines Kalenders anhand der ID
    Then Get FHIR resource at "http://fhirserver/Appointment/${data.appointment-read-id}" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'id.replaceMatches("/_history/.+","").matches("${data.appointment-read-id}")' with error message 'ID der Ressource entspricht nicht der angeforderten ID'
    And FHIR current response body is a valid CORE resource and conforms to profile "http://hl7.org/fhir/StructureDefinition/Appointment"
    And FHIR current response body is a valid ISIK3 resource and conforms to profile "https://gematik.de/fhir/isik/v3/Terminplanung/StructureDefinition/ISiKTermin"
    And FHIR current response body evaluates the FHIRPath "meta.tag.where(code = 'external' and system = 'http://fhir.de/CodeSystem/common-meta-tag-de').exists()" with error message 'Der Wert für die Identifikation des Ursprungs entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "extension.where(url = 'https://gematik.de/fhir/isik/v3/Terminplanung/StructureDefinition/ISiKNachrichtExtension' and value.reference.replaceMatches('/_history/.+','').matches('${data.communication-read-id}')).exists()" with error message 'Die mit diesem Termin assoziierte Nachricht entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "extension.where(url = 'http://hl7.org/fhir/5.0/StructureDefinition/extension-Appointment.replaces' and value.reference.exists()).exists()" with error message 'Dieser Termin verweist nicht auf den ersetzten Termin'
    And TGR current response with attribute "$..Appointment.status.value" matches "cancelled"
    And FHIR current response body evaluates the FHIRPath "cancelationReason.coding.where(code = 'pat').exists()" with error message 'Der Stornierungsgrund entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "serviceType.coding.where(code='177' and system = 'http://terminology.hl7.org/CodeSystem/service-type').exists()" with error message 'Der Service-Typ des Termins entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "specialty.coding.where(code = '142' and system ='urn:oid:1.2.276.0.76.5.114').exists()" with error message 'Die Fachrichtung entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "priority.extension.where(url = 'https://gematik.de/fhir/isik/v3/Terminplanung/StructureDefinition/ISiKTerminPriorityExtension' and value.coding.where(code = '394848005' and system = 'http://snomed.info/sct').exists()).exists()" with error message 'Die Priorität entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "start.toString().contains('2023-01-01T13:00:00')" with error message 'Der Startzeitpunkt entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "end.toString().contains('2023-01-01T14:00:00')" with error message 'Der Endzeitpunkt des Kalenders entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "slot.reference.replaceMatches('/_history/.+','').matches('${data.slot-read-id}')" with error message 'Der verknüpfte Terminblock entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "patientInstruction.contains('Bitte nüchtern erscheinen')" with error message 'Die Anweisung für den Patienten entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "participant.actor.where(reference.replaceMatches('/_history/.+','').matches('${data.patient-read-id}') and display.exists()).exists()" with error message 'Der Teilnehmer entspricht nicht dem Erwartungswert'
