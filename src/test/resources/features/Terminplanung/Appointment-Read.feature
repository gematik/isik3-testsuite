@terminplanung
@mandatory
@Appointment-Read
Feature: Lesen der Ressource Appointment (@Appointment-Read)

  @vorbedingung
  Scenario: Vorbedingung
    Given Testbeschreibung: "Das zu testende System MUSS die angelegte Ressource bei einem HTTP GET auf deren URL korrekt und vollständig zurückgeben (READ)."
    Given Mit den Vorbedingungen:
    """
      - Die Testfälle Schedule-Read, Slot-Read müssen zuvor erfolgreich ausgeführt worden sein.
      - der Testdatensatz muss im zu testenden System gemäß der Vorgaben (manuell) erfasst worden sein.
      - die ID der korrespondierenden FHIR-Ressource zu diesem Testdatensatz muss in der Konfigurationsvariable 'appointment-read-id' hinterlegt sein.

      Legen Sie den folgenden Termin als Ersatz für einen beliebigen Termin in Ihrem System an:
      Quelle (falls vom System unterstützt): Extern
      Ersetzter Termin: Beliebig
      Status: storniert
      Stornierungsgrund: Patient
      Behandlungstyp: der Behandlungstyp aus Testfall Schedule-Read
      Fachrichtung: FA Neurologie
      Priorität: Normal
      Start-Zeitpunkt: identisch mit dem Start-Zeitpunkt des Terminblocks aus dem Testfall Slot-Read
      Ende-Zeitpunkt: identisch mit dem Ende-Zeitpunkt des Terminblocks aus dem Testfall Slot-Read
      Referenzierter Terminblock: Der Terminblock aus Testfall Slot-Read
      Patientenanweisung: Bitte nüchtern erscheinen
      Teilnehmer: Beliebig (Bitte ID in der Konfigurationsvariable 'terminplanung-patient-id' hinterlegen, mit Display Wert, die verknüpfte Patient-Ressource muss konform zu ISiKPatient sein)
    """

  Scenario: Read und Validierung des CapabilityStatements
    Then Get FHIR resource at "http://fhirserver/metadata" with content type "json"
    And CapabilityStatement contains interaction "read" for resource "Appointment"

  Scenario: Read eines Kalenders anhand der ID
    Then Get FHIR resource at "http://fhirserver/Appointment/${data.appointment-read-id}" with content type "xml"
    And resource has ID "${data.appointment-read-id}"
    And FHIR current response body is a valid isik3-terminplanung resource and conforms to profile "https://gematik.de/fhir/isik/v3/Terminplanung/StructureDefinition/ISiKTermin"
    And FHIR current response body evaluates the FHIRPath "meta.tag.where(system = 'http://fhir.de/CodeSystem/common-meta-tag-de').all(code = 'external')" with error message 'Der Wert für die Identifikation des Ursprungs entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "extension.where(url = 'http://hl7.org/fhir/5.0/StructureDefinition/extension-Appointment.replaces' and value.reference.exists()).exists()" with error message 'Dieser Termin verweist nicht auf den ersetzten Termin'
    And TGR current response with attribute "$..Appointment.status.value" matches "cancelled"
    And FHIR current response body evaluates the FHIRPath "cancelationReason.coding.where(code = 'pat').exists()" with error message 'Der Stornierungsgrund entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "serviceType.coding.where(code='${data.schedule-read-servicetype-code}' and system = '${data.schedule-read-servicetype-system}').exists()" with error message 'Der Service-Typ des Termins entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "specialty.coding.where(code = '142' and system ='urn:oid:1.2.276.0.76.5.114').exists()" with error message 'Die Fachrichtung entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "priority.extension.where(url = 'https://gematik.de/fhir/isik/v3/Terminplanung/StructureDefinition/ISiKTerminPriorityExtension' and value.coding.where(code = '394848005' and system = 'http://snomed.info/sct').exists()).exists()" with error message 'Die Priorität entspricht nicht dem Erwartungswert'
    # The OR expression enables configuration of both full and partial date time values with different precision, e.g. slot-read-start: 2024-01-01, 2024-01-01T13:00:00, 2024-01-01T13:00:00.000, 2024-01-01T13:00:00+01:00
    And FHIR current response body evaluates the FHIRPath "start.toString().contains('${data.slot-read-start}') or start ~ @${data.slot-read-start}" with error message 'Der Startzeitpunkt entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "end.empty().not()" with error message 'Der Endzeitpunkt des Kalenders entspricht nicht dem Erwartungswert'
    And element "slot" references resource with ID "${data.slot-read-id}" with error message "Der verknüpfte Terminblock entspricht nicht dem Erwartungswert"
    And FHIR current response body evaluates the FHIRPath "patientInstruction.contains('Bitte nüchtern erscheinen')" with error message 'Die Anweisung für den Patienten entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "participant.actor.where(reference.replaceMatches('/_history/.+','').matches('\\b${data.terminplanung-patient-id}$') and display.exists()).exists()" with error message 'Der Teilnehmer entspricht nicht dem Erwartungswert'
