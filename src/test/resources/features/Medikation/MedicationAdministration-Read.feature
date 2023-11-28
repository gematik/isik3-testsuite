@medikation
@mandatory
@MedicationAdministration-Read
Feature: Lesen der Ressource MedicationAdministration (@MedicationAdministration-Read)

  @vorbedingung
  Scenario: Vorbedingung
    Given Testbeschreibung: "Das zu testende System MUSS die angelegte Ressource bei einem HTTP GET auf deren URL korrekt und vollständig zurückgeben (READ)."
    Given Mit den Vorbedingungen:
    """
      - der Testdatensatz muss im zu testenden System gemäß der Vorgaben (manuell) erfasst worden sein.
      - die ID der korrespondierenden FHIR-Ressourcen zu diesem Testdatensatz müssen in der medikation.yaml eingegeben worden sein.

      Legen Sie folgende Medikationsverabreichung in Ihrem System an:
      Status: abgeschlossen
      Referenziertes Medikament: Beliebig (ID bitte in medikation.yaml eingeben)
      Patient: Beliebig (ID bitte in medikation.yaml eingeben)
      Kontakt: Beliebig (ID bitte in medikation.yaml eingeben)
      Assoziierter Kontakt-Identifier: Beliebig (Wert bitte in medikation.yaml eingeben)
      Zeitpunkt: 2021-07-01
      Verabreichende Person: Beliebig (ID bitte in medikation.yaml eingeben)
      Grund der Medikation: Beliebig (ID bitte in medikation.yaml eingeben)
      Notiz: Testnotiz
      Dosis (Text): Testtext
      Dosis: 1 Brausetablette
      Dosis (Körperstelle SNOMED CT kodiert): Oral
      Dosis (Verabreichungsrate): 1
      Dosis (Route SNOMED CT kodiert): Oral
    """

  Scenario: Read und Validierung des CapabilityStatements
    Then Get FHIR resource at "http://fhirserver/metadata" with content type "json"
    And FHIR current response body evaluates the FHIRPath 'rest.where(mode = "server").resource.where(type = "MedicationAdministration" and interaction.where(code = "read").exists()).exists()'

  Scenario: Read eines Medikaments anhand der ID
    Then Get FHIR resource at "http://fhirserver/MedicationAdministration/${data.medicationadministration-read-id}" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'id.replaceMatches("/_history/.+","").matches("${data.medicationadministration-read-id}")' with error message 'ID der Ressource entspricht nicht der angeforderten ID'
    And FHIR current response body is a valid CORE resource and conforms to profile "http://hl7.org/fhir/StructureDefinition/MedicationAdministration"
    And FHIR current response body is a valid ISIK3 resource and conforms to profile "https://gematik.de/fhir/isik/v3/Medikation/StructureDefinition/ISiKMedikationsVerabreichung"
    And TGR current response with attribute "$..status.value" matches "completed"
    And TGR current response with attribute "$..note.text.value" matches "Testnotiz"
    And FHIR current response body evaluates the FHIRPath "medication.reference.replaceMatches('/_history/.+','').matches('Medication/${data.medication-read-id}')" with error message 'Das referenzierte Medikament entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "subject.reference.replaceMatches('/_history/.+','').matches('Patient/${data.patient-read-id}')" with error message 'Der referenzierte Patient entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "context.reference.replaceMatches('/_history/.+','').matches('Encounter/${data.encounter-read-in-progress-id}')" with error message 'Referenzierter Fall entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "context.identifier.value = '${data.context-identifier}'" with error message 'Der assoziierte Kontakt Identifier entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "effective.toString().contains('2021-07-01')" with error message 'Der Zeitpunkt entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath " performer.actor.reference.replaceMatches('/_history/.+','').matches('Practitioner/${data.practitioner-read-id}')" with error message 'Die verabreichende Person entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "reasonReference.reference.replaceMatches('/_history/.+','').matches('Condition/${data.condition-read-active-id}')" with error message 'Grund der Medikation entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "dosage.where(text = 'Testtext' and site.coding.where(code = '738956005' and system = 'http://snomed.info/sct' and display = 'Oral').exists() and dose.where(code = '1' and system = 'http://unitsofmeasure.org' and unit = 'Brausetablette' and value = '1').exists() and rate.where(value = '1' and code = '1' and system = 'http://unitsofmeasure.org').exists() and route.coding.where(code = '26643006' and system = 'http://snomed.info/sct').exists()).exists()" with error message 'Die Dosis entspricht nicht dem Erwartungswert'
