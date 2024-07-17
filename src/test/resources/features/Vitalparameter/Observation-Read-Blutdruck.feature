@vitalparameter
@mandatory
@Observation-Read-Blutdruck
Feature: Lesen der Ressource Observation (@Observation-Read-Blutdruck)

  @vorbedingung
  Scenario: Vorbedingung
    Given Testbeschreibung: "Das zu testende System MUSS die angelegte Ressource bei einem HTTP GET auf deren URL korrekt und vollständig zurückgeben (READ)."

    Given Mit den Vorbedingungen:
    """
    - der Testdatensatz muss im zu testenden System gemäß der Vorgaben (manuell) erfasst worden sein.
    - die ID der korrespondierenden FHIR-Ressourcen zu diesem Testdatensatz muss in der Konfigurationsvariable 'observation-read-blutdruck-id' hinterlegt sein.

    Testdatensatz (Name: Wert)
    Erfassen Sie eine Blutdruck Observation mit folgenden Daten:
    Status: Abgeschlossen
    Systolischer Blutdruck: 107
    Diastolischer Blutdruck: 60
    Patient: Beliebig (die verknüpfte Patient-Ressource muss konform zu ISiKPatient sein, bitte die ID in der Konfigurationsvariable 'observation-read-patient-id' hinterlegen)
    Fallbezug: Beliebig (die verknüpfte Encounter-Ressource muss konform zu ISIKKontaktGesundheitseinrichtung sein, bitte die ID in der Konfigurationsvariable 'observation-read-encounter-id' hinterlegen)
    """

  Scenario: Read und Validierung des CapabilityStatements
    Then Get FHIR resource at "http://fhirserver/metadata" with content type "json"
    And CapabilityStatement contains interaction "read" for resource "Observation"

  Scenario: Read einer Observation anhand ihrer ID
    Then Get FHIR resource at "http://fhirserver/Observation/${data.observation-read-blutdruck-id}" with content type "xml"
    And resource has ID "${data.observation-read-blutdruck-id}"
    And FHIR current response body is a valid isik3-vitalparameter resource and conforms to profile "https://gematik.de/fhir/isik/v3/VitalparameterUndKoerpermasze/StructureDefinition/ISiKBlutdruck"
    And TGR current response with attribute "$..status.value" matches "final"
    And FHIR current response body evaluates the FHIRPath "category.coding.where(code = 'vital-signs' and system = 'http://terminology.hl7.org/CodeSystem/observation-category').exists()" with error message 'Die Kategorie der Observation entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "code.coding.where(code = '85354-9' and system = 'http://loinc.org').exists()" with error message 'Der Code entspricht nicht dem Erwartungswert'
    And element "subject" references resource with ID "Patient/${data.observation-read-patient-id}" with error message "Referenzierter Patient entspricht nicht dem Erwartungswert"
    And element "encounter" references resource with ID "Encounter/${data.observation-read-encounter-id}" with error message "Referenzierter Fall entspricht nicht dem Erwartungswert"
    And FHIR current response body evaluates the FHIRPath "effective.exists()" with error message 'Die Observation enthält kein Datum'
    And FHIR current response body evaluates the FHIRPath "component.count()>=2" with error message 'Die Anzahl der Komponenten entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "component.where(code.coding.system = 'http://loinc.org' and code.coding.code = '8480-6').exists()" with error message 'Es existiert keine Komponente für den systolischen Blutdruck'
    And FHIR current response body evaluates the FHIRPath "component.where(code.coding.system = 'http://loinc.org' and code.coding.code = '8462-4').exists()" with error message 'Es existiert keine Komponente für den diastolischen Blutdruck'
    And FHIR current response body evaluates the FHIRPath "component.select(value.code = 'mm[Hg]').allTrue()" with error message 'Es existiert mindestens eine Komponente mit einem falsch codierten Wert'

    And referenced Patient resource with id "${data.observation-read-patient-id}" conforms to ISiKPatient profile
    And referenced Encounter resource with id "${data.observation-read-encounter-id}" conforms to ISiKKontaktGesundheitseinrichtung profile