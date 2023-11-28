@vitalparameter
@mandatory
@Observation-Read-GCS
Feature: Lesen der Ressource Observation (@Observation-Read-GCS)

  @vorbedingung
  Scenario: Vorbedingung
    Given Testbeschreibung: "Das zu testende System MUSS die angelegte Ressource bei einem HTTP GET auf deren URL korrekt und vollständig zurückgeben (READ)."

    Given Mit den Vorbedingungen:
    """
    - der Testdatensatz muss im zu testenden System gemäß der Vorgaben (manuell) erfasst worden sein.
    - die ID der korrespondierenden FHIR-Ressource zu diesem Testdatensatz muss in der vitalparameter.yaml eingegeben worden sein.

    Testdatensatz (Name: Wert)
    Erfassen Sie einen Glasgow Coma Score mit folgenden Daten:
    Status: Abgeschlossen
    Beste verbale Reaktion: 3
    Beste motorische Reaktion: 4
    Öffnen der Augen: 4
    Score Gesamt: 11
    Patient: Beliebig (Bitte ID in vitalparameter.yaml eingeben)
    Kontakt: Beliebig (Bitte ID in vitalparameter.yaml eingeben)
    """

  Scenario: Read und Validierung des CapabilityStatements
    Then Get FHIR resource at "http://fhirserver/metadata" with content type "json"
    And FHIR current response body evaluates the FHIRPath 'rest.where(mode = "server").resource.where(type = "Observation" and interaction.where(code = "search-type").exists()).exists()'

  Scenario: Read einer Observation anhand der ID
    Then Get FHIR resource at "http://fhirserver/Observation/${data.observation-read-gcs-id}" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'id.replaceMatches("/_history/.+","").matches("${data.observation-read-gcs-id}")' with error message 'ID der Ressource entspricht nicht der angeforderten ID'
    And FHIR current response body is a valid CORE resource and conforms to profile "http://hl7.org/fhir/StructureDefinition/Observation"
    And FHIR current response body is a valid ISIK3 resource and conforms to profile "https://gematik.de/fhir/isik/v3/VitalparameterUndKoerpermasze/StructureDefinition/ISiKGCS"
    And TGR current response with attribute "$..status.value" matches "final"
    And FHIR current response body evaluates the FHIRPath "category.coding.where(code = 'vital-signs' and system = 'http://terminology.hl7.org/CodeSystem/observation-category').exists()" with error message 'Die Kategorie der Observation entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "code.coding.where(code = '9269-2' and system = 'http://loinc.org').exists()" with error message 'Der Code entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "subject.reference.replaceMatches('/_history/.+','').matches('Patient/${data.patient-read-id}')" with error message 'Referenzierter Patient entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "encounter.reference.replaceMatches('/_history/.+','').matches('Encounter/${data.encounter-read-in-progress-id}')" with error message 'Referenzierter Fall entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "effective.exists()" with error message 'Die Observation enthält kein Datum'
    And FHIR current response body evaluates the FHIRPath "value.where(value = 11 and code = '1' and unit.exists() and system = 'http://unitsofmeasure.org').exists()" with error message 'Der Wert der Observation entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "component.count()=3" with error message 'Die Anzahl der Komponenten entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "component.all(value.exists())" with error message 'Nicht jede Komponente enthält einen Wert'
    And FHIR current response body evaluates the FHIRPath "component.all(value.code = '1')" with error message 'Nicht jede Komponente enthält den korrekten Code'
    And FHIR current response body evaluates the FHIRPath "component.all(value.system = 'http://unitsofmeasure.org')" with error message 'Nicht jede Komponente enthält das korrekte System'
    And FHIR current response body evaluates the FHIRPath "component.where(code.coding.system = 'http://loinc.org' and code.coding.code = '9267-6').exists()" with error message 'Es existiert keine Komponente für die Motorik der Augen'
    And FHIR current response body evaluates the FHIRPath "component.where(code.coding.system = 'http://loinc.org' and code.coding.code = '9267-6').value.value = 4" with error message 'Es existiert kein Punktwert für die Motorik der Augen'
    And FHIR current response body evaluates the FHIRPath "component.where(code.coding.system = 'http://loinc.org' and code.coding.code = '9268-4').exists()" with error message 'Es existiert keine Komponente für die beste motorische Reaktion'
    And FHIR current response body evaluates the FHIRPath "component.where(code.coding.system = 'http://loinc.org' and code.coding.code = '9268-4').value.value = 4" with error message 'Es existiert kein Punktwert für die beste motorische Reaktion'
    And FHIR current response body evaluates the FHIRPath "component.where(code.coding.system = 'http://loinc.org' and code.coding.code = '9270-0').exists()" with error message 'Es existiert keine Komponente für die beste verbale Reaktion'
    And FHIR current response body evaluates the FHIRPath "component.where(code.coding.system = 'http://loinc.org' and code.coding.code = '9270-0').value.value = 3" with error message 'Es existiert kein Punktwert für die beste verbale Reaktion'
