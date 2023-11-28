@medikation
@mandatory
@MedicationStatement-Read-Extended
Feature: Lesen der Ressource MedicationStatement (@MedicationStatement-Read-Extended)

  @vorbedingung
  Scenario: Vorbedingung
    Given Testbeschreibung: "Das zu testende System MUSS die angelegte Ressource bei einem HTTP GET auf deren URL korrekt und vollständig zurückgeben (READ)."
    Given Mit den Vorbedingungen:
    """
      - Die Testfälle Patient-Read, Encounter-Read-In-Progress müssen zuvor erfolgreich ausgeführt worden sein.
      - der Testdatensatz muss im zu testenden System gemäß der Vorgaben (manuell) erfasst worden sein.
      - die ID der korrespondierenden FHIR-Ressourcen zu diesem Testdatensatz müssen in der medikation.yaml eingegeben worden sein.

      Legen Sie folgende Medikationsinformation in Ihrem System an:
      Status: aktiv
      Medikament (ATC kodiert mit Display Wert): Acetylcystein
      Patient: Der Patient aus Testfall Patient-Read
      Patient (interne Aufnahmenummer): Identifies des Patienten aus Testfall Patient-Read
      Zeitpunkt: 2022-07-01
      Grund der Medikation (SNOMED-CT codiert): Bronchitis
      Assoziierter Kontakt-Identifier: Identifier des Kontaktes aus Testfall Encounter-Read-In-Progress
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
    And FHIR current response body evaluates the FHIRPath 'rest.where(mode = "server").resource.where(type = "MedicationStatement" and interaction.where(code = "read").exists()).exists()'

  Scenario: Read eines Medikaments anhand der ID
    Then Get FHIR resource at "http://fhirserver/MedicationStatement/${data.medicationstatement-read-extended-id}" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'id.replaceMatches("/_history/.+","").matches("${data.medicationstatement-read-extended-id}")' with error message 'ID der Ressource entspricht nicht der angeforderten ID'
    And FHIR current response body is a valid CORE resource and conforms to profile "http://hl7.org/fhir/StructureDefinition/MedicationStatement"
    And FHIR current response body is a valid ISIK3 resource and conforms to profile "https://gematik.de/fhir/isik/v3/Medikation/StructureDefinition/ISiKMedikationsInformation"
    And TGR current response with attribute "$..status.value" matches "active"
    And FHIR current response body evaluates the FHIRPath "medication.coding.where(code = 'V03AB23' and system = 'http://fhir.de/CodeSystem/bfarm/atc' and display = 'Acetylcystein').exists()" with error message 'Das kodierte Medikament entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "subject.reference.replaceMatches('/_history/.+','').matches('Patient/${data.patient-read-id}')" with error message 'Der referenzierte Patient entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "subject.identifier.value = '${data.subject-identifier}'" with error message 'Die Aufnahmenummer des Patienten entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "effective.toString().contains('2022-07-01')" with error message 'Der Zeitpunkt entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "reasonCode.coding.where(code = '32398004' and system = 'http://snomed.info/sct' and display.contains('Bronchitis')).exists()" with error message 'Der Grund der MedikationsInformation entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "context.identifier.value = '${data.encounter-identifier}'" with error message 'Der assoziierte Kontakt Identifier entspricht nicht dem Erwartungswert'

    And FHIR current response body evaluates the FHIRPath "dosage.where(text = 'Dosierung 1').timing.repeat.when = 'PC'" with error message 'Die Dosierungsangabe Wiederholung entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "dosage.where(text = 'Dosierung 1').timing.repeat.frequency = 2 and dosage.where(text = 'Dosierung 1').timing.repeat.frequencyMax = 3 and dosage.where(text = 'Dosierung 1').timing.repeat.period = 1 and dosage.where(text = 'Dosierung 1').timing.repeat.periodUnit = 'd'" with error message 'Die Dosierungsangabe Frequenz entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "dosage.where(text = 'Dosierung 1').asNeeded = false"
    And FHIR current response body evaluates the FHIRPath "dosage.where(text = 'Dosierung 1').site.coding.where(system='http://snomed.info/sct' and code='738956005').exists()" with error message 'Die Dosierungsangabe Körperstelle entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "dosage.where(text = 'Dosierung 1').route.coding.where(system='http://snomed.info/sct' and code='26643006').exists()" with error message 'Die Dosierungsangabe Route entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "dosage.where(text = 'Dosierung 1').maxDosePerPeriod.numerator.value = 600 and dosage.where(text = 'Dosierung 1').maxDosePerPeriod.numerator.system = 'http://unitsofmeasure.org' and dosage.where(text = 'Dosierung 1').maxDosePerPeriod.numerator.code = 'mg' and dosage.where(text = 'Dosierung 1').maxDosePerPeriod.numerator.unit = 'mg' and dosage.where(text = 'Dosierung 1').maxDosePerPeriod.denominator.value = 1 and dosage.where(text = 'Dosierung 1').maxDosePerPeriod.denominator.system = 'http://unitsofmeasure.org' and dosage.where(text = 'Dosierung 1').maxDosePerPeriod.denominator.code = 'd' and dosage.where(text = 'Dosierung 1').maxDosePerPeriod.denominator.unit = 'Tag'" with error message 'Die Dosierungsangabe Maximaldosis pro Zeitraum entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "dosage.where(text = 'Dosierung 1').maxDosePerAdministration.value = 200 and dosage.where(text = 'Dosierung 1').maxDosePerAdministration.system = 'http://unitsofmeasure.org' and dosage.where(text = 'Dosierung 1').maxDosePerAdministration.code = 'mg' and dosage.where(text = 'Dosierung 1').maxDosePerAdministration.unit = 'mg'" with error message 'Die Dosierungsangabe Maximaldosis pro Zeitraum entspricht nicht dem Erwartungswert'
