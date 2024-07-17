@medikation
@mandatory
@MedicationAdministration-Read-Extended
Feature: Lesen der Ressource MedicationAdministration (@MedicationAdministration-Read-Extended)

  @vorbedingung
  Scenario: Vorbedingung
    Given Testbeschreibung: "Das zu testende System MUSS die angelegte Ressource bei einem HTTP GET auf deren URL korrekt und vollständig zurückgeben (READ)."
    Given Mit den Vorbedingungen:
    """
      - die ID der korrespondierenden FHIR-Ressourcen zu diesem Testdatensatz müssen in der Konfigurationsvariable 'medicationadministration-read-extended-id' hinterlegt sein.

      Legen Sie folgende Medikationsverabreichung in Ihrem System an:
      Status: abgeschlossen
      Medikament (ATC kodiert mit Display Wert): Acetylcystein
      Patient: Beliebig (die verknüpfte Patient-Ressource muss konform zu ISiKPatient sein, bitte die ID in der Konfigurationsvariable 'medication-patient-id' hinterlegen)
      Patient Identifier: Identifier des verlinkten Patienten (bitte die ID in der Konfigurationsvariable 'medication-patient-identifier' hinterlegen, wird für Suchtests verwendet)
      Zeitpunkt: 2021-07-01
      Verabreichende Person: Beliebig (die verknüpfte Practitioner-Ressource muss konform zu ISiKPersonImGesundheitsberuf sein, bitte die ID in der Konfigurationsvariable 'medication-practitioner-id' hinterlegen)
      Verabreichende Person Identifier: Identifier der verlinkten verabreichenden Person (bitte die ID in der Konfigurationsvariable 'medication-practitioner-identifier' hinterlegen, wird für Suchtests verwendet)
    """

  Scenario: Read und Validierung des CapabilityStatements
    Then Get FHIR resource at "http://fhirserver/metadata" with content type "json"
    And CapabilityStatement contains interaction "read" for resource "MedicationAdministration"

  Scenario: Read eines Medikaments anhand der ID
    Then Get FHIR resource at "http://fhirserver/MedicationAdministration/${data.medicationadministration-read-extended-id}" with content type "xml"
    And resource has ID "${data.medicationadministration-read-extended-id}"
    And FHIR current response body is a valid isik3-medikation resource and conforms to profile "https://gematik.de/fhir/isik/v3/Medikation/StructureDefinition/ISiKMedikationsVerabreichung"
    And TGR current response with attribute "$..status.value" matches "completed"
    And FHIR current response body evaluates the FHIRPath "medication.coding.where(code = 'V03AB23' and system = 'http://fhir.de/CodeSystem/bfarm/atc' and display = 'Acetylcystein').exists()" with error message 'Das kodierte Medikament entspricht nicht dem Erwartungswert'
    And element "subject" references resource with ID "Patient/${data.medication-patient-id}" with error message "Der referenzierte Patient entspricht nicht dem Erwartungswert"
    And FHIR current response body evaluates the FHIRPath "effective.toString().contains('2021-07-01')" with error message 'Der Zeitpunkt entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "performer.actor.reference.replaceMatches('/_history/.+','').matches('Practitioner/${data.medication-practitioner-id}$')" with error message 'Die verabreichende Person entspricht nicht dem Erwartungswert'
