@dokumentenaustausch
@medikation
@mandatory
@List-Read
Feature: Lesen der Ressource List (@List-Read)

  @vorbedingung
  Scenario: Vorbedingung
    Given Testbeschreibung: "Das zu testende System MUSS die angelegte Ressource bei einem HTTP GET auf deren URL korrekt und vollständig zurückgeben (READ)."
    Given Mit den Vorbedingungen:
    """
      - Die Testfälle MedicationStatement-Read, Patient-Read, Encounter-Read-In-Progress müssen zuvor erfolgreich ausgeführt worden sein.
      - der Testdatensatz muss im zu testenden System gemäß der Vorgaben (manuell) erfasst worden sein.
      - die ID der korrespondierenden FHIR-Ressource zu diesem Testdatensatz muss in der shared.yaml eingegeben worden sein.

      Erfassen Sie folgende Medikamentenliste (Name: Wert):
      Status: Aktuell
      Listenmodus: Kontinuierlich fortgeschriebene Liste
      Patient: Der Patient aus Testfall Patient-Read
      Kontakt: Der Kontakt aus Testfall Encounter-Read-In-Progress
      Datum: 2021-07-04
      Listeneintrag 1 (Datum): 2021-07-04
      Listeneintrag 1 (Medikationsinformation): Medikationsinformation aus Testfall MedicationStatement-Read
    """

  Scenario: Read und Validierung des CapabilityStatements
    Then Get FHIR resource at "http://fhirserver/metadata" with content type "json"
    And FHIR current response body evaluates the FHIRPath 'rest.where(mode = "server").resource.where(type = "List" and interaction.where(code = "read").exists()).exists()'

  Scenario: Read eines Account anhand der ID
    Then Get FHIR resource at "http://fhirserver/List/${data.list-read-id}" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'id.replaceMatches("/_history/.+","").matches("${data.list-read-id}")' with error message 'ID der Ressource entspricht nicht der angeforderten ID'
    And FHIR current response body is a valid CORE resource and conforms to profile "http://hl7.org/fhir/StructureDefinition/List"
    And FHIR current response body is a valid ISIK3 resource and conforms to profile "https://gematik.de/fhir/isik/v3/Medikation/StructureDefinition/ISiKMedikationsListe"
    And TGR current response with attribute "$..status.value" matches "current"
    And TGR current response with attribute "$..mode.value" matches "working"
    And FHIR current response body evaluates the FHIRPath "code.coding.where(code = 'medications' and system = 'http://terminology.hl7.org/CodeSystem/list-example-use-codes').exists()" with error message 'Der Code entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "subject.reference.replaceMatches('/_history/.+','').matches('Patient/${data.patient-read-id}')" with error message 'Der referenzierte Patient entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "encounter.reference.replaceMatches('/_history/.+','').matches('Encounter/${data.encounter-read-in-progress-id}')" with error message 'Der referenzierte Fall entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "date.toString().contains('2021-07-04')" with error message 'Das Datum entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "entry.where(item.reference.replaceMatches('/_history/.+','').matches('MedicationStatement/${data.medicationstatement-read-id}') and date.toString().contains('2021-07-04')).exists()" with error message 'Der Listeneintrag entspricht nicht dem Erwartungswert'
