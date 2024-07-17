@vitalparameter
@optional
@Observation-Read-EKG
Feature: Lesen der Ressource Observation (@Observation-Read-EKG)

  @vorbedingung
  Scenario: Vorbedingung
    Given Testbeschreibung: "Das zu testende System MUSS die angelegte Ressource bei einem HTTP GET auf deren URL korrekt und vollständig zurückgeben (READ)."

    Given Mit den Vorbedingungen:
    """
  - der Testdatensatz muss im zu testenden System gemäß der Vorgaben (manuell) erfasst worden sein.
  - die ID der korrespondierenden FHIR-Ressourcen zu diesem Testdatensatz muss in der Konfigurationsvariable 'observation-read-ekg-id' hinterlegt sein.

    Testdatensatz (Name: Wert)
    Erfassen Sie ein EKG mit folgenden Daten:
    Status: Abgeschlossen
    Messdaten: Drei Kanal EKG mit Ableitungen nach Einthoven
    Werte: beliebig
    Patient: Beliebig (die verknüpfte Patient-Ressource muss konform zu ISiKPatient sein, bitte die ID in der Konfigurationsvariable 'observation-read-patient-id' hinterlegen)
    Fallbezug: Beliebig (die verknüpfte Encounter-Ressource muss konform zu ISIKKontaktGesundheitseinrichtung sein, bitte die ID in der Konfigurationsvariable 'observation-read-encounter-id' hinterlegen)
    Gerät: Beliebig (bitte die ID in der Konfigurationsvariable 'device-id' hinterlegen)"
    """

  Scenario: Read und Validierung des CapabilityStatements
    Then Get FHIR resource at "http://fhirserver/metadata" with content type "json"
    And CapabilityStatement contains interaction "read" for resource "Observation"

  Scenario: Read einer Observation anhand ihrer ID
    Then Get FHIR resource at "http://fhirserver/Observation/${data.observation-read-ekg-id}" with content type "xml"
    And resource has ID "${data.observation-read-ekg-id}"
    And FHIR current response body is a valid isik3-vitalparameter resource and conforms to profile "https://gematik.de/fhir/isik/v3/VitalparameterUndKoerpermasze/StructureDefinition/ISiKEkg"
    And TGR current response with attribute "$..status.value" matches "final"
    And FHIR current response body evaluates the FHIRPath "category.coding.where(code = 'procedure' and system = 'http://terminology.hl7.org/CodeSystem/observation-category').exists()" with error message 'Die Kategorie der Observation entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "code.coding.where(code = 'LP6244-0' and system = 'http://loinc.org').exists()" with error message 'Der Code entspricht nicht dem Erwartungswert'
    And element "device" references resource with ID "Device/${data.device-id}" with error message "Referenziertes Gerät entspricht nicht dem Erwartungswert"
    And element "subject" references resource with ID "Patient/${data.observation-read-patient-id}" with error message "Referenzierter Patient entspricht nicht dem Erwartungswert"
    And element "encounter" references resource with ID "Encounter/${data.observation-read-encounter-id}" with error message "Referenzierter Fall entspricht nicht dem Erwartungswert"
    And FHIR current response body evaluates the FHIRPath "effective.exists()" with error message 'Die Observation enthält kein Datum'
    And FHIR current response body evaluates the FHIRPath "component.count()>0" with error message 'Es ist keine Komponente enthalten'
    And FHIR current response body evaluates the FHIRPath "component.where(code.coding.system = 'http://loinc.org' and code.coding.code = 'LP7386-8').exists()" with error message 'Es existiert keine Komponente für die erste Ableitung nach Einthoven'
    And FHIR current response body evaluates the FHIRPath "component.where(code.coding.system = 'http://loinc.org' and code.coding.code = 'LP7386-6').exists()" with error message 'Es existiert keine Komponente für die zweite Ableitung nach Einthoven'
    And FHIR current response body evaluates the FHIRPath "component.where(code.coding.system = 'http://loinc.org' and code.coding.code = 'LP7386-4').exists()" with error message 'Es existiert keine Komponente für die dritte Ableitung nach Einthoven'
    And FHIR current response body evaluates the FHIRPath "component.all(value.exists())" with error message 'Nicht jede Komponente enthält Messwerte'
    And FHIR current response body evaluates the FHIRPath "component.all(value.origin.exists())" with error message 'Nicht jede Komponente enthält einen Nullwert'
    And FHIR current response body evaluates the FHIRPath "component.all(value.period.exists())" with error message 'Nicht jede Komponente enthält eine Angabe zu den Abständen zwischen den Messpunkten'
    And FHIR current response body evaluates the FHIRPath "component.all(value.dimensions.exists())" with error message 'Nicht jede Komponente enthält eine Angabe zu der Anzahl der Messpunkte in den Punkten der Zeitreihe'

    And referenced Patient resource with id "${data.observation-read-patient-id}" conforms to ISiKPatient profile
    And referenced Encounter resource with id "${data.observation-read-encounter-id}" conforms to ISiKKontaktGesundheitseinrichtung profile