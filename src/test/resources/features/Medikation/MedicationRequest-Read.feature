@medikation
@mandatory
@MedicationRequest-Read
Feature: Lesen der Ressource MedicationRequest (@MedicationRequest-Read)

  @vorbedingung
  Scenario: Vorbedingung
    Given Testbeschreibung: "Das zu testende System MUSS die angelegte Ressource bei einem HTTP GET auf deren URL korrekt und vollständig zurückgeben (READ)."
    Given Mit den Vorbedingungen:
    """
      - der Testdatensatz muss im zu testenden System gemäß der Vorgaben (manuell) erfasst worden sein.
      - die ID der korrespondierenden FHIR-Ressourcen zu diesem Testdatensatz muss in der Konfigurationsvariable 'medicationrequest-read-id' hinterlegt sein.

      Legen Sie folgende Medikationsverordnung in Ihrem System an:
      Status: abgeschlossen
      Ziel der Verordnungsinformation: Order
      Referenziertes Medikament: Eine ISiKMedikament-Ressource mit ATC-Code V03AB23 (bitte die ID in der Konfiugrationsvariable 'medicationrequest-medication-id' hinterlegen)
      Patient: Beliebig (die verknüpfte Patient-Ressource muss konform zu ISiKPatient sein, bitte die ID in der Konfigurationsvariable 'medication-patient-id' hinterlegen)
      Fallbezug: Beliebig (die verknüpfte Encounter-Ressource muss konform zu ISIKKontaktGesundheitseinrichtung sein, bitte die ID in der Konfigurationsvariable 'medication-encounter-id' hinterlegen)
      Assoziierter Kontakt-Identifier: Identifier des verlinkten Kontaktes
      Erstellungsdatum: 2021-07-01
      Verordnende Person: Beliebig (die verknüpfte Practitioner-Ressource muss konform zu ISiKPersonImGesundheitsberuf sein, bitte die ID in der Konfigurationsvariable 'medication-practitioner-id' hinterlegen)
      Notiz: Testnotiz
      Dosis (Freitext-Dosierungsanweisung): Beliebig (nicht leer)
      Dosis (Besondere Anweisungen für den Patienten): Instruktionstest
      Dosis: 1 Brausetablette
      Dosis (Körperstelle SNOMED CT kodiert): Oral
      Dosis (Verabreichungsrate): 1
      Dosis (Route SNOMED CT kodiert): Oral
      Dosis (Timing): Morgens, Mittags, Abends
      Angeforderte Abgabemenge: 20 Brausetabletten
      Ersatz zulässig: Ja
    """

  Scenario: Read und Validierung des CapabilityStatements
    Then Get FHIR resource at "http://fhirserver/metadata" with content type "json"
    And CapabilityStatement contains interaction "read" for resource "MedicationRequest"

  Scenario: Read eines Medikaments anhand der ID
    Then Get FHIR resource at "http://fhirserver/MedicationRequest/${data.medicationrequest-read-id}" with content type "xml"
    And resource has ID "${data.medicationrequest-read-id}"
    And FHIR current response body is a valid isik3-medikation resource and conforms to profile "https://gematik.de/fhir/isik/v3/Medikation/StructureDefinition/ISiKMedikationsVerordnung"
    And TGR current response with attribute "$..status.value" matches "completed"
    And TGR current response with attribute "$..intent.value" matches "order"
    And TGR current response with attribute "$..note.text.value" matches "Testnotiz"
    And element "medication" references resource with ID "Medication/${data.medicationrequest-medication-id}" with error message "Das referenzierte Medikament entspricht nicht dem Erwartungswert"
    And element "subject" references resource with ID "Patient/${data.medication-patient-id}" with error message "Der referenzierte Patient entspricht nicht dem Erwartungswert"
    And element "encounter" references resource with ID "Encounter/${data.medication-encounter-id}" with error message "Referenzierter Fall entspricht nicht dem Erwartungswert"
    And FHIR current response body evaluates the FHIRPath "encounter.identifier.value = '${data.medication-encounter-identifier}'" with error message 'Der assoziierte Kontakt Identifier entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "authoredOn.toString().contains('2021-07-01')" with error message 'Das Erstellungsdatum der Verordnung entspricht nicht dem Erwartungswert'
    And element "requester" references resource with ID "Practitioner/${data.medication-practitioner-id}" with error message "Die verordnende Person entspricht nicht dem Erwartungswert"

    # The following assertions enable both single and multiple dosage-elements to be used in order to encode repeated application
    And FHIR current response body evaluates the FHIRPath "dosageInstruction.all(site.coding.where(code = '738956005' and system = 'http://snomed.info/sct' and display = 'Oral'))" with error message 'Die Körperstelle der Verabreichung entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "dosageInstruction.all(text.empty().not())" with error message 'Die Freitext-Dosierungsanweisungen entsprechen nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "dosageInstruction.all(patientInstruction = 'Instruktionstest')" with error message 'Besondere Anweisungen für den Patienten entsprechen nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "dosageInstruction.all(doseAndRate.dose.where(value ~ 1 and unit = 'Brausetablette' and system = 'http://unitsofmeasure.org' and code ='1').exists())" with error message 'Angaben zu Dosis und Rate entsprechen nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "(dosageInstruction.timing.repeat.when contains 'MORN') and (dosageInstruction.timing.repeat.when contains 'NOON') and (dosageInstruction.timing.repeat.when contains 'EVE')" with error message 'Wiederholungs-Angaben entsprechen nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "dispenseRequest.quantity.where(value ~ 20 and unit = 'Brausetablette' and system = 'http://unitsofmeasure.org' and code = '1').exists()" with error message 'Die angeforderte Abgabemenge entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "substitution.allowed.value = true"

    And referenced Patient resource with id "${data.medication-patient-id}" conforms to ISiKPatient profile
    And referenced Encounter resource with id "${data.medication-encounter-id}" conforms to ISiKKontaktGesundheitseinrichtung profile
    And referenced Practitioner resource with id "${data.medication-practitioner-id}" conforms to ISiKPersonImGesundheitsberuf profile
    And referenced Medication resource with id "${data.medicationrequest-medication-id}" conforms to ISiKMedication profile