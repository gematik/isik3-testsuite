@vitalparameter
@mandatory
@Observation-Read-EKG
Feature: Lesen der Ressource Observation (@Observation-Read-EKG)

  @vorbedingung
  Scenario: Vorbedingung
    Given Testbeschreibung: "Das zu testende System MUSS die angelegte Ressource bei einem HTTP GET auf deren URL korrekt und vollständig zurückgeben (READ)."

    Given Mit den Vorbedingungen:
    """
  - der Testdatensatz muss im zu testenden System gemäß der Vorgaben (manuell) erfasst worden sein.
  - die ID der korrespondierenden FHIR-Ressource zu diesem Testdatensatz muss in der vitalparameter.yaml eingegeben worden sein.

    Testdatensatz (Name: Wert)
    Erfassen Sie ein EKG mit folgenden Daten:
    Status: Abgeschlossen
    Messdaten: Drei Kanal EKG mit Ableitungen nach Einthoven
    Werte: beliebig
    Patient: Beliebig (Bitte ID im vitalparameter.yaml eingeben)
    Kontakt: Beliebig (Bitte ID im vitalparameter.yaml eingeben)
    Gerät: Beliebig"
    """

  Scenario: Read und Validierung des CapabilityStatements
    Then Get FHIR resource at "http://fhirserver/metadata" with content type "json"
    And FHIR current response body evaluates the FHIRPath 'rest.where(mode = "server").resource.where(type = "Observation" and interaction.where(code = "search-type").exists()).exists()'

  Scenario: Read einer Prozedur anhand ihrer ID
    Then Get FHIR resource at "http://fhirserver/Observation/${data.observation-read-ekg-id}" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'id.replaceMatches("/_history/.+","").matches("${data.observation-read-ekg-id}")' with error message 'ID der Ressource entspricht nicht der angeforderten ID'
    And FHIR current response body is a valid CORE resource and conforms to profile "http://hl7.org/fhir/StructureDefinition/Observation"
    And FHIR current response body is a valid ISIK3 resource and conforms to profile "https://gematik.de/fhir/isik/v3/VitalparameterUndKoerpermasze/StructureDefinition/ISiKEkg"
    And TGR current response with attribute "$..status.value" matches "final"
    And FHIR current response body evaluates the FHIRPath "category.coding.where(code = 'procedure' and system = 'http://terminology.hl7.org/CodeSystem/observation-category').exists()" with error message 'Die Kategorie der Observation entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "code.coding.where(code = 'LP6244-0' and system = 'http://loinc.org').exists()" with error message 'Der Code entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "device.reference.replaceMatches('/_history/.+','').matches('Device/${data.device-id}')" with error message 'Referenziertes Gerät entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "subject.reference.replaceMatches('/_history/.+','').matches('Patient/${data.patient-read-id}')" with error message 'Referenzierter Patient entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "encounter.reference.replaceMatches('/_history/.+','').matches('Encounter/${data.encounter-read-in-progress-id}')" with error message 'Referenzierter Fall entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "effective.exists()" with error message 'Die Observation enthält kein Datum'
    And FHIR current response body evaluates the FHIRPath "component.count()>0" with error message 'Es ist keine Komponente enthalten'
    And FHIR current response body evaluates the FHIRPath "component.where(code.coding.system = 'http://loinc.org' and code.coding.code = 'LP7386-8').exists()" with error message 'Es existiert keine Komponente für die erste Ableitung nach Einthoven'
    And FHIR current response body evaluates the FHIRPath "component.where(code.coding.system = 'http://loinc.org' and code.coding.code = 'LP7386-6').exists()" with error message 'Es existiert keine Komponente für die zweite Ableitung nach Einthoven'
    And FHIR current response body evaluates the FHIRPath "component.where(code.coding.system = 'http://loinc.org' and code.coding.code = 'LP7386-4').exists()" with error message 'Es existiert keine Komponente für die dritte Ableitung nach Einthoven'
    And FHIR current response body evaluates the FHIRPath "component.all(value.exists())" with error message 'Nicht jede Komponente enthält Messwerte'
    And FHIR current response body evaluates the FHIRPath "component.all(value.origin.exists())" with error message 'Nicht jede Komponente enthält einen Nullwert'
    And FHIR current response body evaluates the FHIRPath "component.all(value.period.exists())" with error message 'Nicht jede Komponente enthält eine Angabe zu den Abständen zwischen den Messpunkten'
    And FHIR current response body evaluates the FHIRPath "component.all(value.dimensions.exists())" with error message 'Nicht jede Komponente enthält eine Angabe zu der Anzahl der Messpunkte in den Punkten der Zeitreihe'
