@medikation
@mandatory
@MedicationAdministration-Read
Feature: Lesen der Ressource MedicationAdministration (@MedicationAdministration-Read)

  @vorbedingung
  Scenario: Vorbedingung
    Given Testbeschreibung: "Das zu testende System MUSS die angelegte Ressource bei einem HTTP GET auf deren URL korrekt und vollständig zurückgeben (READ)."
    Given Mit den Vorbedingungen:
    """
      - Der Testfall Medication-Read muss zuvor erfolgreich ausgeführt worden sein.
      - der Testdatensatz muss im zu testenden System gemäß der Vorgaben (manuell) erfasst worden sein.
      - die ID der korrespondierenden FHIR-Ressourcen zu diesem Testdatensatz muss in der Konfigurationsvariable 'medicationadministration-read-id' hinterlegt sein.

      Legen Sie folgende Medikationsverabreichung in Ihrem System an:
      Status: abgeschlossen
      Referenziertes Medikament: Medikament aus Testfall Medication-Read
      Patient: Beliebig (die verknüpfte Patient-Ressource muss konform zu ISiKPatient sein, bitte die ID in der Konfigurationsvariable 'medication-patient-id' hinterlegen)
      Kontakt: Beliebig (die verknüpfte Encounter-Ressource muss konform zu ISIKKontaktGesundheitseinrichtung sein, bitte die ID in der Konfigurationsvariable 'medication-encounter-id' hinterlegen)
      Assoziierter Kontakt-Identifier: Identifier des verlinkten Kontaktes (bitte in der Konfigurationsvariable 'medication-encounter-identifier' hinterlegen)
      Zeitpunkt: 2021-07-01
      Verabreichende Person: Beliebig (die verknüpfte Practitioner-Ressource muss konform zu ISiKPersonImGesundheitsberuf sein, bitte die ID in der Konfigurationsvariable 'medication-practitioner-id' hinterlegen)
      Grund der Medikation: Beliebig (die verknüpfte Condition-Ressource muss konform zu ISiKDiagnose sein, bitte die ID in der Konfigurationsvariable 'medication-condition-id' hinterlegen)
      Notiz: Testnotiz
      Dosis (Text): Testtext
      Dosis: 1 Brausetablette
      Dosis (Körperstelle SNOMED CT kodiert): Oral
      Dosis (Verabreichungsrate): 1
      Dosis (Route SNOMED CT kodiert): Oral
    """

  Scenario: Read und Validierung des CapabilityStatements
    Then Get FHIR resource at "http://fhirserver/metadata" with content type "json"
    And CapabilityStatement contains interaction "read" for resource "MedicationAdministration"

  Scenario: Read eines Medikaments anhand der ID
    Then Get FHIR resource at "http://fhirserver/MedicationAdministration/${data.medicationadministration-read-id}" with content type "xml"
    And resource has ID "${data.medicationadministration-read-id}"
    And FHIR current response body is a valid isik3-medikation resource and conforms to profile "https://gematik.de/fhir/isik/v3/Medikation/StructureDefinition/ISiKMedikationsVerabreichung"
    And TGR current response with attribute "$..status.value" matches "completed"
    And TGR current response with attribute "$..note.text.value" matches "Testnotiz"
    And element "medication" references resource with ID "Medication/${data.medication-read-id}" with error message "Das referenzierte Medikament entspricht nicht dem Erwartungswert"
    And element "subject" references resource with ID "Patient/${data.medication-patient-id}" with error message "Der referenzierte Patient entspricht nicht dem Erwartungswert"
    And element "context" references resource with ID "Encounter/${data.medication-encounter-id}" with error message "Referenzierter Fall entspricht nicht dem Erwartungswert"
    And FHIR current response body evaluates the FHIRPath "context.identifier.value = '${data.medication-encounter-identifier}'" with error message 'Der assoziierte Kontakt Identifier entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "effective.toString().contains('2021-07-01')" with error message 'Der Zeitpunkt entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "performer.actor.reference.replaceMatches('/_history/.+','').matches('Practitioner/${data.medication-practitioner-id}$')" with error message 'Die verabreichende Person entspricht nicht dem Erwartungswert'
    And element "reasonReference" references resource with ID "Condition/${data.medication-condition-id}" with error message "Grund der Medikation entspricht nicht dem Erwartungswert"
    And FHIR current response body evaluates the FHIRPath "dosage.where(text = 'Testtext' and site.coding.where(code = '738956005' and system = 'http://snomed.info/sct' and display = 'Oral').exists() and dose.where(code = '1' and system = 'http://unitsofmeasure.org' and unit = 'Brausetablette' and value ~ 1).exists() and route.coding.where(code = '26643006' and system = 'http://snomed.info/sct').exists()).exists()" with error message 'Die Dosis entspricht nicht dem Erwartungswert'
    
    And referenced Patient resource with id "${data.medication-patient-id}" conforms to ISiKPatient profile
    And referenced Encounter resource with id "${data.medication-encounter-id}" conforms to ISiKKontaktGesundheitseinrichtung profile
    And referenced Practitioner resource with id "${data.medication-practitioner-id}" conforms to ISiKPersonImGesundheitsberuf profile
    And referenced Condition resource with id "${data.medication-condition-id}" conforms to ISiKDiagnose profile
