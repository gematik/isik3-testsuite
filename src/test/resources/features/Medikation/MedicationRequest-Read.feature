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
      - die ID der korrespondierenden FHIR-Ressourcen zu diesem Testdatensatz müssen in der medikation.yaml eingegeben worden sein.
      
      Legen Sie folgende Medikationsverordnung in Ihrem System an:
      Status: abgeschlossen
      Ziel der Verordnungsinformation: Order
      Referenziertes Medikament: Beliebig (ID bitte in der medikation.yaml eingeben)
      Patient: Beliebig (ID bitte in der medikation.yaml eingeben)
      Kontaktbezug: Beliebig (ID bitte in der medikation.yaml eingeben)
      Assoziierter Kontakt-Identifier: Beliebig (Wert bitte in der medikation.yaml eingeben)
      Erstellungsdatum: 2021-07-01
      Verordnende Person: Beliebig (ID bitte in der medikation.yaml eingeben)
      Notiz: Testnotiz
      Dosis (Text): Testtext
      Dosis: 1 Brausetablette
      Dosis (Körperstelle SNOMED CT kodiert): Oral
      Dosis (Verabreichungsrate): 1
      Dosis (Route SNOMED CT kodiert): Oral
      Angeforderte Abgabemenge: 20 Brausetabletten
      Ersatz zulässig: Ja
    """

  Scenario: Read und Validierung des CapabilityStatements
    Then Get FHIR resource at "http://fhirserver/metadata" with content type "json"
    And FHIR current response body evaluates the FHIRPath 'rest.where(mode = "server").resource.where(type = "MedicationRequest" and interaction.where(code = "read").exists()).exists()'

  Scenario: Read eines Medikaments anhand der ID
    Then Get FHIR resource at "http://fhirserver/MedicationRequest/${data.medicationrequest-read-id}" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'id.replaceMatches("/_history/.+","").matches("${data.medicationrequest-read-id}")' with error message 'ID der Ressource entspricht nicht der angeforderten ID'
    And FHIR current response body is a valid CORE resource and conforms to profile "http://hl7.org/fhir/StructureDefinition/MedicationRequest"
    And FHIR current response body is a valid ISIK3 resource and conforms to profile "https://gematik.de/fhir/isik/v3/Medikation/StructureDefinition/ISiKMedikationsVerordnung"
    And TGR current response with attribute "$..status.value" matches "completed"
    And TGR current response with attribute "$..intent.value" matches "order"
    And TGR current response with attribute "$..note.text.value" matches "Testnotiz"
    And FHIR current response body evaluates the FHIRPath "medication.reference.replaceMatches('/_history/.+','').matches('Medication/${data.medication-read-id}')" with error message 'Das referenzierte Medikament entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "subject.reference.replaceMatches('/_history/.+','').matches('Patient/${data.patient-read-id}')" with error message 'Der referenzierte Patient entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "encounter.reference.replaceMatches('/_history/.+','').matches('Encounter/${data.encounter-read-in-progress-id}')" with error message 'Referenzierter Fall entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "encounter.identifier.value = '${data.encounter-identifier}'" with error message 'Der assoziierte Kontakt Identifier entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "authoredOn.toString().contains('2021-07-01')" with error message 'Das Erstellungsdatum der Verordnung entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "requester.reference.replaceMatches('/_history/.+','').matches('Practitioner/${data.practitioner-read-id}')" with error message 'Die verordnende Person entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "dosageInstruction.where(text = 'Testtext' and site.coding.where(code = '738956005' and system = 'http://snomed.info/sct' and display = 'Oral').exists() and doseAndRate.where(dose.where(code = '1' and system = 'http://unitsofmeasure.org' and unit = 'Brausetablette' and value = '1').exists()).exists()).exists()" with error message 'Die Dosis entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "dispenseRequest.quantity.where(value = 20 and unit = 'Brausetablette' and system = 'http://unitsofmeasure.org' and code = '1').exists()" with error message 'Die angeforderte Abgabemenge entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "substitution.allowed.value = true"
