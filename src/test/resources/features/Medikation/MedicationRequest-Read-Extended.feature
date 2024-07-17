@medikation
@mandatory
@MedicationRequest-Read-Extended
Feature: Lesen der Ressource MedicationRequest (@MedicationRequest-Read-Extended)

  @vorbedingung
  Scenario: Vorbedingung
    Given Testbeschreibung: "Das zu testende System MUSS die angelegte Ressource bei einem HTTP GET auf deren URL korrekt und vollständig zurückgeben (READ)."
    Given Mit den Vorbedingungen:
    """
      - der Testdatensatz muss im zu testenden System gemäß der Vorgaben (manuell) erfasst worden sein.
      - die ID der korrespondierenden FHIR-Ressourcen zu diesem Testdatensatz muss in der Konfigurationsvariable 'medicationrequest-read-extended-id' hinterlegt sein.

      Legen Sie folgende Medikationsverabreichung in Ihrem System an:
      Status: abgeschlossen
      Ziel der Verordnungsinformation: Order
      Medikament (ATC kodiert mit Display Wert): Acetylcystein
      Patient: Beliebig (die verknüpfte Patient-Ressource muss konform zu ISiKPatient sein, bitte die ID in der Konfigurationsvariable 'medication-patient-id' hinterlegen)
      Patient Identifier: Identifier des verlinkten Patienten (bitte die ID in der Konfigurationsvariable 'medication-patient-identifier' hinterlegen, wird für Suchtests verwendet)
      Verordnende Person: Beliebig (die verknüpfte Practitioner-Ressource muss konform zu ISiKPersonImGesundheitsberuf sein, bitte die ID in der Konfigurationsvariable 'medication-practitioner-id' hinterlegen)
      Verordnende Person Identifier: Identifier der verordnenden Person (bitte die ID in der Konfigurationsvariable 'medication-practitioner-identifier' hinterlegen, wird für Suchtests verwendet)
      Dosierungsangabe (Timing): 2021-07-01
    """

  Scenario: Read und Validierung des CapabilityStatements
    Then Get FHIR resource at "http://fhirserver/metadata" with content type "json"
    And CapabilityStatement contains interaction "read" for resource "MedicationRequest"

  Scenario: Read eines Medikaments anhand der ID
    Then Get FHIR resource at "http://fhirserver/MedicationRequest/${data.medicationrequest-read-extended-id}" with content type "xml"
    And resource has ID "${data.medicationrequest-read-extended-id}"
    And FHIR current response body is a valid isik3-medikation resource and conforms to profile "https://gematik.de/fhir/isik/v3/Medikation/StructureDefinition/ISiKMedikationsVerordnung"
    And TGR current response with attribute "$..status.value" matches "completed"
    And TGR current response with attribute "$..intent.value" matches "order"
    And FHIR current response body evaluates the FHIRPath "medication.coding.where(code = 'V03AB23' and system = 'http://fhir.de/CodeSystem/bfarm/atc' and display = 'Acetylcystein').exists()" with error message 'Das kodierte Medikament entspricht nicht dem Erwartungswert'
    And element "subject" references resource with ID "Patient/${data.medication-patient-id}" with error message "Der referenzierte Patient entspricht nicht dem Erwartungswert"
    And element "requester" references resource with ID "Practitioner/${data.medication-practitioner-id}" with error message "Die verabreichende Person entspricht nicht dem Erwartungswert"
    And FHIR current response body evaluates the FHIRPath "dosageInstruction.timing.event.toString().contains('2021-07-01')" with error message 'Das Erstellungsdatum der Verordnung entspricht nicht dem Erwartungswert'
