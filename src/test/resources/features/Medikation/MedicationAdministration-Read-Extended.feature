@medikation
@mandatory
@MedicationAdministration-Read-Extended
Feature: Lesen der Ressource MedicationAdministration (@MedicationAdministration-Read-Extended)

  @vorbedingung
  Scenario: Vorbedingung
    Given Testbeschreibung: "Das zu testende System MUSS die angelegte Ressource bei einem HTTP GET auf deren URL korrekt und vollständig zurückgeben (READ)."
    Given Mit den Vorbedingungen:
    """
      - der Testdatensatz muss im zu testenden System gemäß der Vorgaben (manuell) erfasst worden sein.
      - die ID der korrespondierenden FHIR-Ressourcen zu diesem Testdatensatz müssen in der medikation.yaml eingegeben worden sein.

      Legen Sie folgende Medikationsverabreichung in Ihrem System an:
      Status: abgeschlossen
      Medikament (ATC kodiert mit Display Wert): Acetylcystein
      Patient: Beliebig (ID bitte in medikation.yaml eingeben)
      Patient Identifier: Beliebig (Identifier bitte in medikation.yaml eingeben)
      Zeitpunkt: 2021-07-01
      Verabreichende Person: Beliebig (ID bitte in medikation.yaml eingeben)
      Verabreichende Person Identifier: Beliebig (Identifier bitte in medikation.yaml eingeben)
    """

  Scenario: Read und Validierung des CapabilityStatements
    Then Get FHIR resource at "http://fhirserver/metadata" with content type "json"
    And FHIR current response body evaluates the FHIRPath 'rest.where(mode = "server").resource.where(type = "MedicationAdministration" and interaction.where(code = "read").exists()).exists()'

  Scenario: Read eines Medikaments anhand der ID
    Then Get FHIR resource at "http://fhirserver/MedicationAdministration/${data.medicationadministration-read-extended-id}" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'id.replaceMatches("/_history/.+","").matches("${data.medicationadministration-read-extended-id}")' with error message 'ID der Ressource entspricht nicht der angeforderten ID'
    And FHIR current response body is a valid CORE resource and conforms to profile "http://hl7.org/fhir/StructureDefinition/MedicationAdministration"
    And FHIR current response body is a valid ISIK3 resource and conforms to profile "https://gematik.de/fhir/isik/v3/Medikation/StructureDefinition/ISiKMedikationsVerabreichung"
    And TGR current response with attribute "$..status.value" matches "completed"
    And FHIR current response body evaluates the FHIRPath "medication.coding.where(code = 'V03AB23' and system = 'http://fhir.de/CodeSystem/bfarm/atc' and display = 'Acetylcystein').exists()" with error message 'Das kodierte Medikament entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "subject.reference.replaceMatches('/_history/.+','').matches('Patient/${data.patient-read-id}')" with error message 'Der referenzierte Patient entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "subject.identifier.value = '${data.patient-identifier}'" with error message 'Der assoziierte Patienten Identifier entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "effective.toString().contains('2021-07-01')" with error message 'Der Zeitpunkt entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "performer.actor.reference.replaceMatches('/_history/.+','').matches('Practitioner/${data.practitioner-read-id}')" with error message 'Die verabreichende Person entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "performer.actor.identifier.value = '${data.performer-identifier}'" with error message 'Der Identifier der verabreichenden Person entspricht nicht dem Erwartungswert'
