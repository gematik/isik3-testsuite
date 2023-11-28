@medikation
@mandatory
@MedicationStatement-Read
Feature: Lesen der Ressource MedicationStatement (@MedicationStatement-Read)

  @vorbedingung
  Scenario: Vorbedingung
    Given Testbeschreibung: "Das zu testende System MUSS die angelegte Ressource bei einem HTTP GET auf deren URL korrekt und vollständig zurückgeben (READ)."
    Given Mit den Vorbedingungen:
    """
      - Die Testfälle Medication-Read, MedicationAdministration-Read, Patient-Read, Encounter-Read-In-Progress, Condition-Read-Active müssen zuvor erfolgreich ausgeführt worden sein.
      - der Testdatensatz muss im zu testenden System gemäß der Vorgaben (manuell) erfasst worden sein.
      - die ID der korrespondierenden FHIR-Ressourcen zu diesem Testdatensatz müssen in der medikation.yaml eingegeben worden sein.

      Legen Sie folgende Medikationsinformation in Ihrem System an:
      Bestandteil von: Medikationsverabreichung aus Testfall MedicationAdministration-Read
      Status: aktiv
      Referenziertes Medikament: Das Medikament aus Testfall Medication-Read
      Patient: Der Patient aus Testfall Patient-Read
      Fallbezug: Der Kontakt aus Testfall Encounter-Read-In-Progress
      Zeitraum: 2021-07-01
      Datum der Feststellung: 2021-07-01
      Grund der Medikation: Diagnose aus Testfall Condition-Read-Active
      Notiz: Testnotiz
      Dosis (Text): Testtext
      Dosis (Instruktion): Instruktionstest
      Dosis (Timing): Morgens, Mittags, Abends
      Dosis: 1 Brausetablette
    """

  Scenario: Read und Validierung des CapabilityStatements
    Then Get FHIR resource at "http://fhirserver/metadata" with content type "json"
    And FHIR current response body evaluates the FHIRPath 'rest.where(mode = "server").resource.where(type = "MedicationStatement" and interaction.where(code = "read").exists()).exists()'

  Scenario: Read eines Medikaments anhand der ID
    Then Get FHIR resource at "http://fhirserver/MedicationStatement/${data.medicationstatement-read-id}" with content type "xml"
    And FHIR current response body is a valid CORE resource and conforms to profile "http://hl7.org/fhir/StructureDefinition/MedicationStatement"
    And FHIR current response body is a valid ISIK3 resource and conforms to profile "https://gematik.de/fhir/isik/v3/Medikation/StructureDefinition/ISiKMedikationsInformation"
    And FHIR current response body evaluates the FHIRPath 'id.replaceMatches("/_history/.+","").matches("${data.medicationstatement-read-id}")' with error message 'ID der Ressource entspricht nicht der angeforderten ID'
    And FHIR current response body evaluates the FHIRPath "partOf.reference.replaceMatches('/_history/.+','').matches('MedicationAdministration/${data.medicationadministration-read-id}')" with error message 'Die referenzierte Medikamentenverabreichung entspricht nicht dem Erwartungswert'
    And TGR current response with attribute "$..status.value" matches "active"
    And TGR current response with attribute "$..note.text.value" matches "Testnotiz"
    And FHIR current response body evaluates the FHIRPath "medication.reference.replaceMatches('/_history/.+','').matches('Medication/${data.medication-read-id}')" with error message 'Das referenzierte Medikament entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "subject.reference.replaceMatches('/_history/.+','').matches('Patient/${data.patient-read-id}')" with error message 'Der referenzierte Patient entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "context.reference.replaceMatches('/_history/.+','').matches('Encounter/${data.encounter-read-in-progress-id}')" with error message 'Referenzierter Fall entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "effective.start.toString().contains('2021-07-01')" with error message 'Der Zeitraum entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "dateAsserted.toString().contains('2021-07-01')" with error message 'Das Datum der Feststellung der Medikationsinformation entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "reasonReference.reference.replaceMatches('/_history/.+','').matches('Condition/${data.condition-read-active-id}')" with error message 'Grund der Medikation entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "dosage.where(text = 'Texttest' and patientInstruction = 'Instruktionstest' and timing.repeat.where((when contains 'NOON') and (when contains 'MORN') and (when contains 'EVE')).exists() and doseAndRate.dose.where(value = '1' and unit = 'Brausetablette' and system = 'http://unitsofmeasure.org' and code ='1').exists()).exists()" with error message 'Die Dosis entspricht nicht dem Erwartungswert'
