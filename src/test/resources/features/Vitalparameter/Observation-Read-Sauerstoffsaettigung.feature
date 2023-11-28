@vitalparameter
@mandatory
@Observation-Read-Sauerstoffsaettigung
Feature: Lesen der Ressource Observation (@Observation-Read-Sauerstoffsaettigung)

  @vorbedingung
  Scenario: Vorbedingung
    Given Testbeschreibung: "Das zu testende System MUSS die angelegte Ressource bei einem HTTP GET auf deren URL korrekt und vollständig zurückgeben (READ)."

    Given Mit den Vorbedingungen:
    """
    - der Testdatensatz muss im zu testenden System gemäß der Vorgaben (manuell) erfasst worden sein.
    - die ID der korrespondierenden FHIR-Ressource zu diesem Testdatensatz muss in der vitalparameter.yaml eingegeben worden sein.

      Testdatensatz (Name: Wert)
      Erfassen Sie folgende Sauerstoffsaettigung:
      Status: Abgeschlossen
      Sauerstoffsaettigung: 98 %
      Patient: Beliebig (Bitte ID in vitalparameter.yaml eingeben)
      Kontakt: Beliebig (Bitte ID in vitalparameter.yaml eingeben)
    """

  Scenario: Read und Validierung des CapabilityStatements
    Then Get FHIR resource at "http://fhirserver/metadata" with content type "json"
    And FHIR current response body evaluates the FHIRPath 'rest.where(mode = "server").resource.where(type = "Observation" and interaction.where(code = "search-type").exists()).exists()'


  Scenario: Read einer Observation anhand der ID
    Then Get FHIR resource at "http://fhirserver/Observation/${data.observation-read-sauerstoffsaettigung-id}" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'id.replaceMatches("/_history/.+","").matches("${data.observation-read-sauerstoffsaettigung-id}")' with error message 'ID der Ressource entspricht nicht der angeforderten ID'
    And FHIR current response body is a valid CORE resource and conforms to profile "http://hl7.org/fhir/StructureDefinition/Observation"
    And FHIR current response body is a valid ISIK3 resource and conforms to profile "https://gematik.de/fhir/isik/v3/VitalparameterUndKoerpermasze/StructureDefinition/ISiKSauerstoffsaettigung"
    And TGR current response with attribute "$..status.value" matches "final"
    And FHIR current response body evaluates the FHIRPath "category.coding.where(code = 'vital-signs' and system = 'http://terminology.hl7.org/CodeSystem/observation-category').exists()" with error message 'Die Kategorie der Observation entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "code.coding.where(code = '2708-6' and system = 'http://loinc.org').exists()" with error message 'Der Code entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "subject.reference.replaceMatches('/_history/.+','').matches('Patient/${data.patient-read-id}')" with error message 'Referenzierter Patient entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "encounter.reference.replaceMatches('/_history/.+','').matches('Encounter/${data.encounter-read-in-progress-id}')" with error message 'Referenzierter Fall entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "effective.exists()" with error message 'Die Observation enthält kein Datum'
    And FHIR current response body evaluates the FHIRPath "value.where(value = 98 and code = '%' and unit.exists() and system = 'http://unitsofmeasure.org').exists()" with error message 'Der Wert der Observation entspricht nicht dem Erwartungswert'