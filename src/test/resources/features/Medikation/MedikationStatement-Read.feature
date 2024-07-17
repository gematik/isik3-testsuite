@medikation
@mandatory
@MedicationStatement-Read
Feature: Lesen der Ressource MedicationStatement (@MedicationStatement-Read)

  @vorbedingung
  Scenario: Vorbedingung
    Given Testbeschreibung: "Das zu testende System MUSS die angelegte Ressource bei einem HTTP GET auf deren URL korrekt und vollständig zurückgeben (READ)."
    Given Mit den Vorbedingungen:
    """
      - Der Testfall Medication-Read müssen zuvor erfolgreich ausgeführt worden sein.
      - der Testdatensatz muss im zu testenden System gemäß der Vorgaben (manuell) erfasst worden sein.
      - die ID der korrespondierenden FHIR-Ressource zu diesem Testdatensatz muss in der Konfigurationsvariable 'medicationstatement-read-id' hinterlegt sein.

      Legen Sie folgende Medikationsinformation in Ihrem System an:
      Status: aktiv
      Referenziertes Medikament: Das Medikament aus Testfall Medication-Read
      Patient: Beliebig (die verknüpfte Patient-Ressource muss konform zu ISiKPatient sein, bitte die ID in der Konfigurationsvariable 'medication-patient-id' hinterlegen)
      Fallbezug: Beliebig (die verknüpfte Encounter-Ressource muss konform zu ISIKKontaktGesundheitseinrichtung sein, bitte die ID in der Konfigurationsvariable 'medication-encounter-id' hinterlegen)
      Zeitraum: 2021-07-01
      Datum der Feststellung: 2021-07-01
      Grund der Medikation: Beliebig (die verknüpfte Condition-Ressource muss konform zu ISiKDiagnose sein, bitte die ID in der Konfigurationsvariable 'medication-condition-id' hinterlegen)
      Notiz: Testnotiz
      Dosis (Text): Testtext
      Dosis (Instruktion): Instruktionstest
      Dosis (Timing): Morgens, Mittags, AbendsDosis: 1 Brausetablette
    """

  Scenario: Read und Validierung des CapabilityStatements
    Then Get FHIR resource at "http://fhirserver/metadata" with content type "json"
    And CapabilityStatement contains interaction "read" for resource "MedicationStatement"

  Scenario: Read eines Medikaments anhand der ID
    Then Get FHIR resource at "http://fhirserver/MedicationStatement/${data.medicationstatement-read-id}" with content type "xml"
    And FHIR current response body is a valid isik3-medikation resource and conforms to profile "https://gematik.de/fhir/isik/v3/Medikation/StructureDefinition/ISiKMedikationsInformation"
    And resource has ID "${data.medicationstatement-read-id}"
    And TGR current response with attribute "$..status.value" matches "active"
    And TGR current response with attribute "$..note.text.value" matches "Testnotiz"
    And element "medication" references resource with ID "Medication/${data.medication-read-id}" with error message "Das referenzierte Medikament entspricht nicht dem Erwartungswert"
    And element "subject" references resource with ID "Patient/${data.medication-patient-id}" with error message "Der referenzierte Patient entspricht nicht dem Erwartungswert"
    And element "context" references resource with ID "Encounter/${data.medication-encounter-id}" with error message "Referenzierter Fall entspricht nicht dem Erwartungswert"
    And FHIR current response body evaluates the FHIRPath "effective.start.toString().contains('2021-07-01')" with error message 'Der Zeitraum entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "dateAsserted.toString().contains('2021-07-01')" with error message 'Das Datum der Feststellung der Medikationsinformation entspricht nicht dem Erwartungswert'
    And element "reasonReference" references resource with ID "Condition/${data.medication-condition-id}" with error message "Grund der Medikation entspricht nicht dem Erwartungswert"
    And FHIR current response body evaluates the FHIRPath "dosage.where(text = 'Texttest' and patientInstruction = 'Instruktionstest' and timing.repeat.where((when contains 'NOON') and (when contains 'MORN') and (when contains 'EVE')).exists() and doseAndRate.dose.where(value ~ 1 and unit = 'Brausetablette' and system = 'http://unitsofmeasure.org' and code ='1').exists()).exists()" with error message 'Die Dosis entspricht nicht dem Erwartungswert'

    And referenced Patient resource with id "${data.medication-patient-id}" conforms to ISiKPatient profile
    And referenced Encounter resource with id "${data.medication-encounter-id}" conforms to ISiKKontaktGesundheitseinrichtung profile
    And referenced Condition resource with id "${data.medication-condition-id}" conforms to ISiKDiagnose profile