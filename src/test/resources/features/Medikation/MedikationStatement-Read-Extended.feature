@medikation
@mandatory
@MedicationStatement-Read-Extended
Feature: Lesen der Ressource MedicationStatement (Extended) (@MedicationStatement-Read-Extended)

  @vorbedingung
  Scenario: Vorbedingung
    Given Testbeschreibung: "Das zu testende System MUSS die angelegte Ressource bei einem HTTP GET auf deren URL korrekt und vollständig zurückgeben (READ)."
    Given Mit den Vorbedingungen:
    """
      - die ID der korrespondierenden FHIR-Ressourcen zu diesem Testdatensatz muss in der Konfigurationsvariable 'medicationstatement-read-extended-id' hinterlegt sein.

      Legen Sie folgende Medikationsinformation in Ihrem System an:
      Status: aktiv
      Medikament (ATC kodiert mit Display Wert): Acetylcystein
      Patient: Beliebig (die verknüpfte Patient-Ressource muss konform zu ISiKPatient sein, bitte die ID in der Konfigurationsvariable 'medication-patient-id' hinterlegen)
      Patient (interne Aufnahmenummer): Identifies des verlinkten Patienten (bitte in der Konfigurationsvariable 'medication-patient-identifier' hinterlegen, wird für Suchtests verwendet)
      Zeitpunkt: 2022-07-01
      Grund der Medikation: Beliebig (Display-Wert, CodeSystem, Code nicht leer)
      Kontakt/Fallbezug: Beliebig (die verknüpfte Encounter-Ressource muss konform zu ISIKKontaktGesundheitseinrichtung sein, bitte die ID in der Konfigurationsvariable 'medication-encounter-id' hinterlegen)
      Assoziierter Kontakt-Identifier: Identifier des verlinkten Kontaktes (bitte in der Konfigurationsvariable 'medication-encounter-identifier' hinterlegen, wird für Suchtests verwendet)
      Dosierungsangabe Freitext-Dosierungsanweisungen: Dosierung 1
      Dosierungsangabe Wiederholung: Nach Machlzeit
      Dosierungsangabe Frequenz: 2-3 mal pro Tag
      Dosierungsangabe Bedarfsmedikation: Nein
      Dosierungsangabe Körperstelle (SNOMED CT kodiert): Oral
      Dosierungsangabe Route (SNOMED CT kodiert): Oral
      Dosierungsangabe Maximaldosis pro Zeitraum: 600mg/Tag
      Dosierungsangabe Maximaldosis pro Verabreichung: 200mg
    """

  Scenario: Read und Validierung des CapabilityStatements
    Then Get FHIR resource at "http://fhirserver/metadata" with content type "json"
    And CapabilityStatement contains interaction "read" for resource "MedicationStatement"

  Scenario: Read eines Medikaments anhand der ID
    Then Get FHIR resource at "http://fhirserver/MedicationStatement/${data.medicationstatement-read-extended-id}" with content type "xml"
    And resource has ID "${data.medicationstatement-read-extended-id}"
    And FHIR current response body is a valid isik3-medikation resource and conforms to profile "https://gematik.de/fhir/isik/v3/Medikation/StructureDefinition/ISiKMedikationsInformation"
    And TGR current response with attribute "$..status.value" matches "active"
    And FHIR current response body evaluates the FHIRPath "medication.coding.where(code = 'V03AB23' and system = 'http://fhir.de/CodeSystem/bfarm/atc' and display = 'Acetylcystein').exists()" with error message 'Das kodierte Medikament entspricht nicht dem Erwartungswert'
    And element "subject" references resource with ID "Patient/${data.medication-patient-id}" with error message "Der referenzierte Patient entspricht nicht dem Erwartungswert"
    And FHIR current response body evaluates the FHIRPath "effective.toString().contains('2022-07-01')" with error message 'Der Zeitpunkt entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "reasonCode.coding.where(code.empty().not() and system.empty().not() and display.empty().not()).exists()" with error message 'Der Grund der MedikationsInformation ist falsch angegeben'
    
    And FHIR current response body evaluates the FHIRPath "dosage.where(text = 'Dosierung 1').timing.repeat.when = 'PC'" with error message 'Die Dosierungsangabe Wiederholung entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "dosage.where(text = 'Dosierung 1').timing.repeat.frequency = 2 and dosage.where(text = 'Dosierung 1').timing.repeat.frequencyMax = 3 and dosage.where(text = 'Dosierung 1').timing.repeat.period = 1 and dosage.where(text = 'Dosierung 1').timing.repeat.periodUnit = 'd'" with error message 'Die Dosierungsangabe Frequenz entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "dosage.where(text = 'Dosierung 1').asNeeded = false"
    And FHIR current response body evaluates the FHIRPath "dosage.where(text = 'Dosierung 1').site.coding.where(system='http://snomed.info/sct' and code='738956005').exists()" with error message 'Die Dosierungsangabe Körperstelle entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "dosage.where(text = 'Dosierung 1').route.coding.where(system='http://snomed.info/sct' and code='26643006').exists()" with error message 'Die Dosierungsangabe Route entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "dosage.where(text = 'Dosierung 1').maxDosePerPeriod.numerator.value ~ 600 and dosage.where(text = 'Dosierung 1').maxDosePerPeriod.numerator.system = 'http://unitsofmeasure.org' and dosage.where(text = 'Dosierung 1').maxDosePerPeriod.numerator.code = 'mg' and dosage.where(text = 'Dosierung 1').maxDosePerPeriod.numerator.unit = 'mg' and dosage.where(text = 'Dosierung 1').maxDosePerPeriod.denominator.value ~ 1 and dosage.where(text = 'Dosierung 1').maxDosePerPeriod.denominator.system = 'http://unitsofmeasure.org' and dosage.where(text = 'Dosierung 1').maxDosePerPeriod.denominator.code = 'd' and dosage.where(text = 'Dosierung 1').maxDosePerPeriod.denominator.unit = 'Tag'" with error message 'Die Dosierungsangabe Maximaldosis pro Zeitraum entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "dosage.where(text = 'Dosierung 1').maxDosePerAdministration.value ~ 200 and dosage.where(text = 'Dosierung 1').maxDosePerAdministration.system = 'http://unitsofmeasure.org' and dosage.where(text = 'Dosierung 1').maxDosePerAdministration.code = 'mg' and dosage.where(text = 'Dosierung 1').maxDosePerAdministration.unit = 'mg'" with error message 'Die Dosierungsangabe Maximaldosis pro Zeitraum entspricht nicht dem Erwartungswert'

    And referenced Patient resource with id "${data.medication-patient-id}" conforms to ISiKPatient profile
    And referenced Encounter resource with id "${data.medication-encounter-id}" conforms to ISiKKontaktGesundheitseinrichtung profile