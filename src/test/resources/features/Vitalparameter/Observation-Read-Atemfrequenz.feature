@vitalparameter
@mandatory
@Observation-Read-Atemfrequenz
Feature: Lesen der Ressource Observation (@Observation-Read-Atemfrequenz)

  @vorbedingung
  Scenario: Vorbedingung
    Given Testbeschreibung: "Das zu testende System MUSS die angelegte Ressource bei einem HTTP GET auf deren URL korrekt und vollständig zurückgeben (READ)."

    Given Mit den Vorbedingungen:
    """
    - der Testdatensatz muss im zu testenden System gemäß der Vorgaben (manuell) erfasst worden sein.
    - die ID der korrespondierenden FHIR-Ressourcen zu diesem Testdatensatz muss in der Konfigurationsvariable 'observation-read-atemfrequenz-id' hinterlegt sein.

    Testdatensatz (Name: Wert)
    Erfassen Sie eine Atemfrequenz mit folgenden Daten:
    Status: Abgeschlossen
    Wert: 26
    Patient: Beliebig (die verknüpfte Patient-Ressource muss konform zu ISiKPatient sein, bitte die ID in der Konfigurationsvariable 'observation-read-patient-id' hinterlegen)
    Fallbezug: Beliebig (die verknüpfte Encounter-Ressource muss konform zu ISIKKontaktGesundheitseinrichtung sein, bitte die ID in der Konfigurationsvariable 'observation-read-encounter-id' hinterlegen)
    Datum: 2022-01-01")
    """

  Scenario: Read und Validierung des CapabilityStatements
    Then Get FHIR resource at "http://fhirserver/metadata" with content type "json"
    And CapabilityStatement contains interaction "read" for resource "Observation"

  Scenario: Read einer Observation anhand ihrer ID
    Then Get FHIR resource at "http://fhirserver/Observation/${data.observation-read-atemfrequenz-id}" with content type "xml"
    And resource has ID "${data.observation-read-atemfrequenz-id}"
    And FHIR current response body is a valid isik3-vitalparameter resource and conforms to profile "https://gematik.de/fhir/isik/v3/VitalparameterUndKoerpermasze/StructureDefinition/ISiKAtemfrequenz"
    And TGR current response with attribute "$..status.value" matches "final"
    And FHIR current response body evaluates the FHIRPath "category.coding.where(code = 'vital-signs' and system = 'http://terminology.hl7.org/CodeSystem/observation-category').exists()" with error message 'Die Kategorie der Observation entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "code.coding.where(code = '9279-1' and system = 'http://loinc.org').exists()" with error message 'Der Code entspricht nicht dem Erwartungswert'
    And element "subject" references resource with ID "Patient/${data.observation-read-patient-id}" with error message "Referenzierter Patient entspricht nicht dem Erwartungswert"
    And element "encounter" references resource with ID "Encounter/${data.observation-read-encounter-id}" with error message "Referenzierter Fall entspricht nicht dem Erwartungswert"
    And FHIR current response body evaluates the FHIRPath "effective.toString().contains('2022-01-01')" with error message 'Das Datum entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "value.where(value ~ 26 and code = '/min' and unit.exists() and system = 'http://unitsofmeasure.org').exists()" with error message 'Der Wert der Observation entspricht nicht dem Erwartungswert'

    And referenced Patient resource with id "${data.observation-read-patient-id}" conforms to ISiKPatient profile
    And referenced Encounter resource with id "${data.observation-read-encounter-id}" conforms to ISiKKontaktGesundheitseinrichtung profile